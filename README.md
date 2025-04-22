/**
 * Trigger to prevent deletion of ContentDocument records (notes) associated with objects that have "48C" record types
 */
trigger PreventNotesDeletion on ContentDocument (before delete) {
    // Call handler class to perform the validation logic
    PreventNoteDeletionHandler.validateDeletion(Trigger.old);
}

/**
 * Handler class for note deletion prevention logic
 */
public class PreventNoteDeletionHandler {
    
    /**
     * Validates if notes can be deleted based on association with 48C record types
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
                
                // Check each parent record for "48C" record type
                for (Id parentId : linkedParentIds) {
                    String recordTypeName = recordTypeMap.get(parentId);
                    
                    // If record type contains "48C", prevent deletion
                    if (recordTypeName != null && recordTypeName.contains('48C')) {
                        doc.addError('Cannot delete notes associated with 48C record types.');
                        break;
                    }
                }
            }
        }
    }
    
    /**
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
    
    /**
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

/**
 * Test class for the PreventNotesDeletion trigger
 */
@isTest
public class PreventNotesDeletionTest {
    
    @isTest
    static void testPreventDeletionWith48CRecordType() {
        // Create a test account with a record type that contains "48C"
        // This requires you to have a record type with "48C" in the name
        // Replace 'Account' with appropriate object if needed
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('RecordType_48C_Test').getRecordTypeId();
        
        Account testAccount = new Account(
            Name = 'Test Account',
            RecordTypeId = recordTypeId
        );
        insert testAccount;
        
        // Create a test note
        ContentNote note = new ContentNote();
        note.Title = 'Test Note';
        note.Content = Blob.valueOf('Test Content');
        insert note;
        
        // Link the note to the test account
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = note.Id;
        cdl.LinkedEntityId = testAccount.Id;
        cdl.ShareType = 'V'; // Viewer permission
        insert cdl;
        
        // Query the ContentDocument record that was created for the note
        ContentDocument doc = [SELECT Id FROM ContentDocument WHERE Id = :note.Id];
        
        // Attempt to delete the note via ContentDocument - should be prevented
        Test.startTest();
        Database.DeleteResult result = Database.delete(doc, false);
        Test.stopTest();
        
        // Verify that the deletion was prevented
        System.assertEquals(false, result.isSuccess());
        System.assert(result.getErrors()[0].getMessage().contains('Cannot delete notes associated with 48C record types'));
    }
    
    @isTest
    static void testAllowDeletionWithoutRestriction() {
        // Create a test account with a record type that does NOT contain "48C"
        // Replace with appropriate object and record type if needed
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Regular_RecordType').getRecordTypeId();
        
        Account testAccount = new Account(
            Name = 'Regular Account',
            RecordTypeId = recordTypeId
        );
        insert testAccount;
        
        // Create a test note
        ContentNote note = new ContentNote();
        note.Title = 'Regular Note';
        note.Content = Blob.valueOf('Regular Content');
        insert note;
        
        // Link the note to the test account
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = note.Id;
        cdl.LinkedEntityId = testAccount.Id;
        cdl.ShareType = 'V'; // Viewer permission
        insert cdl;
        
        // Query the ContentDocument record that was created for the note
        ContentDocument doc = [SELECT Id FROM ContentDocument WHERE Id = :note.Id];
        
        // Attempt to delete the note via ContentDocument - should be allowed
        Test.startTest();
        Database.DeleteResult result = Database.delete(doc, false);
        Test.stopTest();
        
        // Verify that the deletion was successful
        System.assertEquals(true, result.isSuccess());
    }
}