@isTest 
public class InstagramPaginatedApisTest {
    private static Id caseRecordTypeId                  = Schema.SObjectType.case.getRecordTypeInfosByName().get('Instagram').getRecordTypeId();
    
    
    
    @isTest
    static void TestgetNextBatchOfPostsFromInsta(){
        Instagram_Api_Details__c fap = new Instagram_Api_Details__c();
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
        
        Case testCase = new Case();
        testCase.RecordTypeId = caseRecordTypeId;
        testCase.Subject = 'Test Case';
        testCase.Post_Id__c = '17841405793087218';
        testCase.Description = 'Test Case Description';
        testCase.Origin = 'Instagram';
        testCase.Brand__c='Hyphen';
        testCase.Mention__c='example_user';
        insert testCase;
        
        Post_Comments__c postComment = new Post_Comments__c(); 
        postComment.Case__c= testCase.Id;
        postComment.Comment_Id__c = '17851087209098192';
        postComment.Replied_Comments__c = 'RepliesWrapper:[data=(ReplyData:[id=17841405793087218, text=Test Reply 1, username=testuser1, timeStamp=2023-07-29T12:34:56+0000,Case__c=caseId])])';
        insert postComment;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InstagramAuthHelperTestMockTest());
        InstagramPaginatedApis.getNextBatchOfPostsFromInsta();
        Test.stopTest();
        
    }
    
    @isTest
    static void TestgetNextBatchOfMentionsFromInsta(){
        Instagram_Api_Details__c fap = new Instagram_Api_Details__c();
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
        
        // Create a test Case record
        Case testCase = new Case();
        testCase.RecordTypeId = caseRecordTypeId;
        testCase.Subject = 'Test Case';
        testCase.Post_Id__c = '17841405793087218';
        testCase.Description = 'Test Case Description';
        testCase.Origin = 'Instagram';
        testCase.Brand__c='Hyphen';
        testCase.Mention__c='example_user';
        insert testCase;
        
        string caseId=testCase.id;
        // Create test data for the Post_Comments__c object
        Post_Comments__c commentRecord = new Post_Comments__c();
        commentRecord.Comment_Id__c = '17851087209098192';
        commentRecord.Replied_Comments__c = 'RepliesWrapper:[data=(ReplyData:[id=17841405793087218, text=@sagarikaranaa its AMAZING, timestamp=2023-07-30T19:15:50+0000, username=kavyajhunjhunwala])]';
        commentRecord.Case__c=caseId;
        insert commentRecord;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InstagramAuthHelperTestMockTest());
        InstagramPaginatedApis.getNextBatchOfMentionsFromInsta();
        Test.stopTest();
        
    }
    
}