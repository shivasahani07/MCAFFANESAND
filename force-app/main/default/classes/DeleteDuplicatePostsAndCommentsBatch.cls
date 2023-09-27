public class DeleteDuplicatePostsAndCommentsBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String origin = 'Instagram';
        String query = 'Select id,subject,Description,Caption__c,Post_Id__c,(Select Comment__c,Comment_Id__c,case__c,Case__r.Post_Id__c,Commented_By__c,Post_Url__c,Post_comment_Time__c from Post_Comments__r) from case where Origin = :origin and recordTypeId = :caseRecordTypeId';
        return Database.getQueryLocator(query);
    }
    
     public void execute(Database.BatchableContext context, List<case> caseRecordsList) {
       
    }
    
    public void finish(Database.BatchableContext context){
        
    }

}