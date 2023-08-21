public class DuplicateCaseDeletionBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    List<Case> ExistingCaseRecords = new List<Case>();
    private static Id caseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Instagram').getRecordTypeId();
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String origin = 'Instagram';
        String query = 'Select id,subject,Description,Caption__c,Post_Id__c from case where Origin = :origin and recordTypeId = :caseRecordTypeId';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<case> caseRecordsList) {
        
        for(case caseRec : caseRecordsList){
            ExistingCaseRecords.add(caseRec);
        }
        
    }
    
    public void finish(Database.BatchableContext context){
        Map<String, Id> tweetIdToCaseIdMap = new Map<String, Id>();
        for (Case caseRecord : ExistingCaseRecords) {
            tweetIdToCaseIdMap.put(caseRecord.Post_Id__c, caseRecord.Id);
        }
        List<Id> casesToDelete = new List<Id>();
        for (Case caseRecord : ExistingCaseRecords) {
            if (caseRecord.Id != tweetIdToCaseIdMap.get(caseRecord.Post_Id__c)) {
                casesToDelete.add(caseRecord.Id);
            }
        }
        system.debug('casesToDelete'+casesToDelete.size());
        if (!casesToDelete.isEmpty()) {
            delete [SELECT Id FROM Case WHERE Id IN :casesToDelete];
        }
    }
}