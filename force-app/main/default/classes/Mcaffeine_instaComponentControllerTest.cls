@isTest
public class Mcaffeine_instaComponentControllerTest { 
    
    @isTest
    static void testGetRepliesDetails() {
        
        // Create a test Case record
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case Description';
        insert testCase;
        string caseId=testCase.id;
        // Create test data for the Post_Comments__c object
        Post_Comments__c commentRecord = new Post_Comments__c();
        commentRecord.Comment_Id__c = 'TestCommentId';
        commentRecord.Replied_Comments__c = 'RepliesWrapper:[data=(ReplyData:[id=18229403821211947, text=@sagarikaranaa its AMAZING, timestamp=2023-07-30T19:15:50+0000, username=kavyajhunjhunwala])]';
        commentRecord.Case__c=caseId;
        insert commentRecord;
        
        // Call the getRepliesDetails method with the test data
        List<Mcaffeine_instaComponentController.ReplyWrapperRecords> replyList = Mcaffeine_instaComponentController.getRepliesDetails(commentRecord.Comment_Id__c);
    }
    
    @isTest
    static void testGetCaseDetails() {
    
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case Description';
        testcase.Post_Id__c = '18229403821211947';
        testcase.Brand__c = 'mCaffeine';
        insert testCase;
        
        Post_Comments__c commentRecord = new Post_Comments__c();
        commentRecord.Comment_Id__c = '18229403821211947';
        commentRecord.Comment__c = 'Test Comment';
        commentRecord.Post_Url__c = 'https://www.example.com/test-post-url';
        commentRecord.Post_comment_Time__c =string.valueof(Datetime.now());
        commentRecord.Replied_Comments__c = 'RepliesWrapper:[data=(ReplyData:[id=18229403821211947, text=@sagarikaranaa its AMAZING, timestamp=2023-07-30T19:15:50+0000, username=kavyajhunjhunwala])]';
        commentRecord.Case__c = testCase.Id;
        insert commentRecord;
        Mcaffeine_instaComponentController.getCaseDetails(testCase.Id);
        
    }
    
    @isTest
    static void testReplyToComment() {
        // Create a test Case record
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case Description';
        testcase.Brand__c = 'mCaffeine';
        insert testCase;
        
        // Create a test Post_Comments__c record
        Post_Comments__c commentRecord = new Post_Comments__c();
        commentRecord.Comment_Id__c = 'TestCommentId';
        commentRecord.Replied_Comments__c = null; // Simulating no replies
        commentRecord.Case__c = testCase.Id;
        commentRecord.Replied_Comments__c = 'RepliesWrapper:[data=(ReplyData:[id=18229403821211947, text=@sagarikaranaa its AMAZING, timestamp=2023-07-30T19:15:50+0000, username=kavyajhunjhunwala])]';
        insert commentRecord;
        
        // Set the mock for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call the replyToComment method with the test data
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InstagramAuthHelperTestMockTest());
        Mcaffeine_instaComponentController.replyToComment('TestCommentId', 'Test reply message');
        
        Test.stopTest();
        
    }
    
    
    @isTest
    static void testgetUpdateComments (){
        // Create a test Case record
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Description = 'Test Case Description';
        testcase.Brand__c = 'mCaffeine';
        insert testCase;
        
        // Create a test Post_Comments__c record
        Post_Comments__c commentRecord = new Post_Comments__c();
        commentRecord.Comment_Id__c = '18229403821211947';
        commentRecord.Replied_Comments__c = null; // Simulating no replies
        commentRecord.Case__c = testCase.Id;
        //commentRecord.Replied_Comments__c = 'RepliesWrapper:[data=(ReplyData:[id=18229403821211947, text=@sagarikaranaa its AMAZING, timestamp=2023-07-30T19:15:50+0000, username=kavyajhunjhunwala])]';
        insert commentRecord;
        
        Case CaseDetails = [Select id,subject,Description,Type_of_Post__c,Caption__c,POST_URL__c,(Select Comment__c,Comment_Id__c,Replied_Comments__c,Commented_By__c,Post_Url__c,Post_comment_Time__c from Post_Comments__r ) from case where id = :testCase.Id];

        List<Mcaffeine_instaComponentController.instaWrapper> instaWrapperList = Mcaffeine_instaComponentController.getCaseDetails(CaseDetails.Id);
        // Call the getCaseDetails method with the test data
        Test.startTest();
        Mcaffeine_instaComponentController.getUpdatedComments(testCase.Id);
        Test.stopTest();
    }
}