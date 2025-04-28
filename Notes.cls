public class PreventNoteDeletionHandler {
    
    // Custom metadata list or custom setting could replace this
    // This makes it easy to add new record types without changing the code
    private static final Set<String> PROTECTED_RECORD_TYPES = new Set<String>{
        '48C',      // Matches any record type containing 48C, including Eco48C
        '30D',
        'Test'
    };
    
    /*
     * Validates if notes can be deleted based on association with protected record types
     * @param documentsToDelete List of ContentDocument records being deleted
    */
    public static void validateDeletion(List<ContentDocument> documentsToDelete) {
        // Set to collect all ContentDocument IDs
        Set<Id> contentDocumentIds = new Set<Id>();
        
        // Map the ContentDocument ID to the ContentDocument record for easy access later
        Map<Id, ContentDocument> contentDocumentMap = new Map<Id, ContentDocument>();
        
        // Populate the sets with data from documents being deleted
        for (ContentDocument doc : documentsToDelete) {
            // We only care about notes (FileType = 'SNOTE')
            if (doc.FileType == 'SNOTE') {
                contentDocumentIds.add(doc.Id);
                contentDocumentMap.put(doc.Id, doc);
            }
        }
        
        // If no notes are being deleted, exit early
        if (contentDocumentIds.isEmpty()) {
            return;
        }
        
        // Query ContentDocumentLinks to find relationships between notes and parent records
        List<ContentDocumentLink> contentLinks = [
            SELECT Id, ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE ContentDocumentId IN :contentDocumentIds
        ];
        
        // Set to collect parent record IDs that notes are linked to
        Set<Id> parentRecordIds = new Set<Id>();
        
        // Map to track which notes are linked to which parent records
        Map<Id, Set<Id>> noteToParentMap = new Map<Id, Set<Id>>();
        
        // Process content links to identify parent records
        for (ContentDocumentLink link : contentLinks) {
            // Store the parent record ID
            parentRecordIds.add(link.LinkedEntityId);
            
            // Track which notes are linked to which parent records
            if (!noteToParentMap.containsKey(link.ContentDocumentId)) {
                noteToParentMap.put(link.ContentDocumentId, new Set<Id>());
            }
            noteToParentMap.get(link.ContentDocumentId).add(link.LinkedEntityId);
        }
        
        // Exit early if no parent records found
        if (parentRecordIds.isEmpty()) {
            return;
        }
        
        // Store record type information for all parent records
        Map<Id, String> recordTypeMap = new Map<Id, String>();
        
        // Query to get record type information for each parent object type
        // We need to dynamically determine object types from the IDs
        Map<String, Set<Id>> objectTypeToIdsMap = groupRecordsByObjectType(parentRecordIds);
        
        // For each object type, query for record type information
        for (String objectType : objectTypeToIdsMap.keySet()) {
            // Skip processing if the object doesn't support record types
            if (!supportsRecordTypes(objectType)) {
                continue;
            }
            
            Set<Id> objectIds = objectTypeToIdsMap.get(objectType);
            String query = 'SELECT Id, RecordTypeId, RecordType.DeveloperName FROM ' + objectType + ' WHERE Id IN :objectIds';
            
            try {
                // Execute the dynamic query
                for (SObject record : Database.query(query)) {
                    String recordTypeName = (String)((record.getSObject('RecordType') != null) ? 
                                          record.getSObject('RecordType').get('DeveloperName') : null);
                    
                    if (recordTypeName != null) {
                        recordTypeMap.put((Id)record.get('Id'), recordTypeName);
                        System.debug('Record ID: ' + record.get('Id') + ' has RecordType: ' + recordTypeName);
                    }
                }
            } catch (Exception e) {
                // If the query fails, continue with other objects
                System.debug('Error querying record type for ' + objectType + ': ' + e.getMessage());
            }
        }
        
        // Check each document being deleted
        for (ContentDocument doc : documentsToDelete) {
            // Skip if not a note or not in our filtered list
            if (!contentDocumentMap.containsKey(doc.Id)) {
                continue;
            }
            
            // If the document is linked to any parent records
            if (noteToParentMap.containsKey(doc.Id)) {
                Set<Id> linkedParentIds = noteToParentMap.get(doc.Id);
                
                // Check each parent record for protected record types
                for (Id parentId : linkedParentIds) {
                    String recordTypeName = recordTypeMap.get(parentId);
                    if (recordTypeName == null) continue;
                    
                    // Check if this record type should be protected
                    String matchedType = isProtectedRecordType(recordTypeName);
                    
                    if (matchedType != null) {
                        doc.addError('Cannot delete notes associated with protected record type: ' + recordTypeName);
                        System.debug('BLOCKING deletion of note: ' + doc.Id + ' linked to record with protected type: ' + recordTypeName);
                        break;
                    }
                }
            }
        }
    }
    
    /*
     * Checks if a record type should be protected based on our configuration
     * @param recordTypeName The name of the record type to check
     * @return The matched protected type or null if not protected
    */
    private static String isProtectedRecordType(String recordTypeName) {
        if (recordTypeName == null) return null;
        
        // Check if the record type matches any in our protected list
        for (String protectedType : PROTECTED_RECORD_TYPES) {
            if (recordTypeName.contains(protectedType)) {
                return protectedType;
            }
        }
        
        return null;
    }
    
    /*
     * Groups record IDs by their object type
     * @param recordIds Set of record IDs to group
     * @return Map of object type to set of record IDs
    */
    private static Map<String, Set<Id>> groupRecordsByObjectType(Set<Id> recordIds) {
        Map<String, Set<Id>> result = new Map<String, Set<Id>>();
        
        for (Id recordId : recordIds) {
            String objectType = recordId.getSObjectType().getDescribe().getName();
            
            if (!result.containsKey(objectType)) {
                result.put(objectType, new Set<Id>());
            }
            
            result.get(objectType).add(recordId);
        }
        
        return result;
    }
    
    /*
     * Checks if the given object type supports record types
     * @param objectType Object type name to check
     * @return Boolean indicating if the object supports record types
    */
    private static Boolean supportsRecordTypes(String objectType) {
        try {
            // Get the schema for the object
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectType);
            if (sObjectType == null) {
                return false;
            }
            
            // Check if the object supports record types
            return sObjectType.getDescribe().isCreateable() && 
                   sObjectType.getDescribe().fields.getMap().containsKey('RecordTypeId');
        } catch (Exception e) {
            return false;
        }
    }
}
