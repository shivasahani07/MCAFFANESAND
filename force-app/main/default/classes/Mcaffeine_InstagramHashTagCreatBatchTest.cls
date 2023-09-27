@isTest
public class Mcaffeine_InstagramHashTagCreatBatchTest {
  @isTest
    static void testBatchExecution() {
        // Create test data
        RecordType caseRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'Instagram' LIMIT 1];
		 Mcaffeine_Instagram_Api_Details__c fap = new Mcaffeine_Instagram_Api_Details__c();
        fap.Name='mcaffeine';
        fap.CLIENT_ID__c='bccbckbcewbcje';
        fap.CLIENT_SECRET__c='cbewciuewcw cweu ciw cwucw';
        fap.REDIRECT_URI__c='bcewcbwecwueicwc c iwcw';
        fap.accessToken__c='bxiueqbcubce ccwebcw cuew';
        fap.basicUrl__c='bcwiuecewucwcuew cew cw cweuc';
        fap.businessUserId__c='bcew ciwu ce ce cuec';
        fap.next_Pagination_Post_Token__c='ncencencienciencnecne';
        fap.next_Pagination_Mention_Token__c='uebfbbcuebcebcucbeubcuecue';
        fap.next_pagination_hashtag_Token__c='jciece ci c e ce c';
        fap.HashTag__c='ubcebwcubcuewcubcuewbcbew'; 
        insert fap;
        // Create a test case record
        Case testCase = new Case(
            Subject = 'Test Case',
            Origin = 'Instagram',
            Brand__c='mCaffeine',
            RecordTypeId = caseRecordType.Id,
            Post_Id__c = '17841405793087218'
        );
        insert testCase;
        
       	Post_Comments__c postComment = new Post_Comments__c(); 
        postComment.Case__c= testCase.Id;
        postComment.Comment_Id__c = 'commentId';
        postComment.Replied_Comments__c = 'RepliesWrapper:[data=(ReplyData:[id=123, text=Test Reply 1, username=testuser1, timeStamp=2023-07-29T12:34:56+0000,Case__c=caseId])])';
        insert postComment;

        // Start the test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InstagramAuthHelperTestMockTest());
        Mcaffeine_InstagramHashTagCreationBatch batch = new Mcaffeine_InstagramHashTagCreationBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Perform assertions based on the expected behavior
        // For example, you can query and assert the inserted/updated records
       // List<Case> casesWithHashTag = [SELECT Id, HashTags__c FROM Case WHERE Id = :testCase.Id];
       
    }

}