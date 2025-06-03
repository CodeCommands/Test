# Salesforce Knowledge Management Revamp Demo Script

## Introduction

Good morning/afternoon everyone. Today, I'm excited to share with you our revamped knowledge management framework in Salesforce. We've made significant improvements to streamline how our five business units create, approve, and publish knowledge articles, moving from a development-dependent process to a more empowered, user-driven approach.

## Current State of Knowledge Management

Let me start by explaining our current knowledge article management process:

### Current Process Flow

1. **Request Initiation**: Application owners identify a need for a new knowledge article and add it to the development team's backlog.

2. **Development Environment Creation**: Our development team creates the knowledge article in the lowest environment (DEV).

3. **Verification Cycle**: The application team reviews and validates the knowledge article in the DEV environment.

4. **Deployment Pipeline**: Once approved, the development team deploys the knowledge article through the entire environment pipeline (DEV → QA → UAT → PROD).

5. **Publication**: The article finally becomes available to internal or external users only after completing the full deployment cycle.

### Current Challenges

This approach has several pain points:

* **Development Dependency**: Application teams must rely on the development team's availability to create or modify articles.

* **Deployment Cycle Limitations**: Articles can only be published following the predetermined deployment schedules.

* **Time to Market**: There's a significant delay between identifying the need for knowledge content and having it available to users.

* **Resource Utilization**: Our technical resources spend time on content management tasks rather than focusing on application development.

* **Limited Ownership**: Application teams lack direct control over their knowledge content lifecycle.

## Our New Revamped Process

We've redesigned our knowledge management approach with three key user personas and a streamlined workflow:

### New User Personas

1. **Knowledge Users**: End-users who access and consume knowledge articles.

2. **Knowledge Contributors**: Subject matter experts from application teams who can create new knowledge articles and submit them for approval. They cannot directly publish content.

3. **Knowledge Publishers**: Designated approvers who review, provide feedback, approve, and publish knowledge articles. They have full article lifecycle management capabilities.

### New Process Flow

1. **Article Creation**: Knowledge Contributors create articles directly in the production environment using our new Salesforce interface.

2. **Submission for Approval**: Once an article is ready, Contributors submit it through our automated approval process.

3. **Review and Feedback**: Knowledge Publishers receive approval notifications through Salesforce queues.

4. **Approval or Revision**: Publishers either approve the article for publication or send it back with feedback for revisions.

5. **Publication**: Approved articles are immediately published to the appropriate audiences without requiring a development deployment.

## Technical Implementation Details

To support this new framework, we've implemented several technical enhancements:

### 1. Record Types

We've created separate record types in the Knowledge object for each of our five business units:
* Application A Record Type
* Application B Record Type
* Application C Record Type
* Application D Record Type
* Application E Record Type

This ensures clear separation between applications while maintaining a unified knowledge base.

### 2. Data Categories Restructuring

We've reorganized our data categories to create a more intuitive hierarchy that aligns with our business structure and improves searchability.

### 3. Approval Process Automation

We've implemented:
* Custom approval processes for each business unit
* Automated notification flows
* Queue-based approval assignments
* Status tracking throughout the article lifecycle

### 4. Permission Sets and Profiles

We've created dedicated permission sets to define the three user personas, ensuring appropriate access controls:
* Knowledge User permissions
* Knowledge Contributor permissions
* Knowledge Publisher permissions

## Live Demonstration

[Note: This section would include a live walkthrough of the actual Salesforce implementation]

Let me demonstrate how the new process works:

1. I'll log in as a Knowledge Contributor and create a new article
2. I'll show how to select the appropriate record type and categories
3. I'll submit the article for approval
4. I'll switch to a Publisher account to show the approval process
5. I'll demonstrate publication and how it immediately appears to users

## Key Benefits of the New Approach

Our revamped knowledge management framework delivers several significant benefits:

### 1. Empowered Business Units

* Application teams now have direct control over their knowledge content
* No need to wait for development team availability
* Self-service article creation and management

### 2. Accelerated Time to Market

* Articles can be published as soon as they're approved
* No dependency on deployment schedules
* Critical information reaches users faster

### 3. Resource Optimization

* Development team can focus on technical work
* Subject matter experts directly contribute their knowledge
* Publishers ensure quality control

### 4. Improved Governance

* Clear approval workflows ensure content quality
* Record types maintain organizational boundaries
* Structured data categories improve findability

### 5. Scalability

* Framework accommodates all five business units
* Can easily expand to include additional applications
* Consistent process across the organization

## Implementation Timeline and Next Steps

We have successfully implemented this framework and are now ready to roll it out across all business units. Our implementation plan includes:

1. User training sessions for Contributors and Publishers
2. Migration of existing knowledge articles to the new structure
3. Gradual phase-out of the old process
4. Continuous improvement based on user feedback

## Conclusion

Our revamped knowledge management framework transforms how we create and maintain knowledge articles across our five applications. By empowering application teams, streamlining approvals, and eliminating deployment dependencies, we're making knowledge management faster, more efficient, and more responsive to business needs.

Thank you for your attention. I'm happy to answer any questions you may have about the new framework.

## Q&A Preparation

[Note: Prepare answers for anticipated questions]

* How will we migrate existing articles?
* What training will be provided to users?
* How do we handle article versions and updates?
* What happens when an article needs to be retired?





// Replace with your actual Integration User Id
Id integrationUserId = '005XXXXXXXXXXXX';

// Step 1: Query Funding Requests with RecordType 'ECO48C'
List<Outfunds_funding_reequest__c> fundingRequests = [
    SELECT Id, Name
    FROM Outfunds_funding_reequest__c
    WHERE RecordType.DeveloperName = 'ECO48C'
];

Set<Id> fundingRequestIds = new Set<Id>();
Map<Id, String> requestIdToName = new Map<Id, String>();
for (Outfunds_funding_reequest__c fr : fundingRequests) {
    fundingRequestIds.add(fr.Id);
    requestIdToName.put(fr.Id, fr.Name);
}

// Step 2: Get ContentDocumentLinks for those records
List<ContentDocumentLink> cdlList = [
    SELECT ContentDocumentId, LinkedEntityId
    FROM ContentDocumentLink
    WHERE LinkedEntityId IN :fundingRequestIds
];

Set<Id> linkedContentDocIds = new Set<Id>();
Map<Id, Id> docIdToRequestId = new Map<Id, Id>();
for (ContentDocumentLink cdl : cdlList) {
    linkedContentDocIds.add(cdl.ContentDocumentId);
    docIdToRequestId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
}

// Step 3: Get ContentVersions uploaded by Integration User
List<ContentVersion> versions = [
    SELECT ContentDocumentId
    FROM ContentVersion
    WHERE ContentDocumentId IN :linkedContentDocIds
    AND CreatedById = :integrationUserId
];

Set<Id> validContentDocIds = new Set<Id>();
for (ContentVersion ver : versions) {
    validContentDocIds.add(ver.ContentDocumentId);
}

// Step 4: Fetch ContentDocuments matching filtered IDs
List<ContentDocument> docs = [
    SELECT Id, Title, FileExtension, ContentSize
    FROM ContentDocument
    WHERE Id IN :validContentDocIds
];

// Step 5: Group by Funding Request Name
Map<String, List<ContentDocument>> groupedResults = new Map<String, List<ContentDocument>>();
for (ContentDocument doc : docs) {
    Id requestId = docIdToRequestId.get(doc.Id);
    String requestName = requestIdToName.get(requestId);
    if (String.isNotBlank(requestName)) {
        if (!groupedResults.containsKey(requestName)) {
            groupedResults.put(requestName, new List<ContentDocument>());
        }
        groupedResults.get(requestName).add(doc);
    }
}

// Step 6: Debug Output
for (String name : groupedResults.keySet()) {
    System.debug('Funding Request: ' + name);
    for (ContentDocument d : groupedResults.get(name)) {
        System.debug('    Title: ' + d.Title + ', Extension: ' + d.FileExtension + ', Size: ' + d.ContentSize);
    }
}