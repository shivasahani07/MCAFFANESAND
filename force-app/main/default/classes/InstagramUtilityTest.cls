@isTest
public class InstagramUtilityTest {
    static testmethod void getAllDetailsOfMedia_test(){  
        Case caseRec = new Case();
        caseRec.Post_Id__c = 'tweetId';
        insert caserec;
        
        Post_Comments__c postComment = new Post_Comments__c();
        postComment.Case__c= caserec.Id;
        postComment.Comment_Id__c = 'commentId';
        insert postComment;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InstagramAuthHelperTestMockTest());
        InstagramUtilityClass.getInstaBusinessUserId();
        Test.stopTest();
    }
    
    static testmethod void getAllDetailsOfComments_test(){  
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InstagramAuthHelperTestMockTest());
        InstagramUtilityClass.getMediaIdFromCommentId('INSTA');
        Test.stopTest();
    }
    
    
    public static InstagramMediaResponseWrapper getCommentWrapper(InstagramMediaResponseWrapper mediaResponse){
        List<InstagramMediaResponseWrapper.cls_data> commentsData = new List<InstagramMediaResponseWrapper.cls_data>();
        
         // Comment 1
        InstagramMediaResponseWrapper.cls_data comment1 = new InstagramMediaResponseWrapper.cls_data();
        comment1.text = 'Awesome picture!';
        comment1.username = 'user1';
        comment1.id = 'comment1_id';
        comment1.commentId = 'comment1_comment_id';
        comment1.timestamp = 'comment1_timestamp';

        // Add replies to comment 1
        List<InstagramMediaResponseWrapper.ReplyData> replies1 = new List<InstagramMediaResponseWrapper.ReplyData>();
        InstagramMediaResponseWrapper.ReplyData reply1 = new InstagramMediaResponseWrapper.ReplyData();
        reply1.text = 'Thanks!';
        reply1.username = 'user2';
        reply1.id = 'reply1_id';
        reply1.timestamp = 'reply1_timestamp';
        replies1.add(reply1);
        comment1.replies = new InstagramMediaResponseWrapper.RepliesWrapper();
        comment1.replies.data = replies1;

        // Comment 2
        InstagramMediaResponseWrapper.cls_data comment2 = new InstagramMediaResponseWrapper.cls_data();
        comment2.text = 'Beautiful!';
        comment2.username = 'user3';
        comment2.id = 'comment2_id';
        comment2.commentId = 'comment2_comment_id';
        comment2.timestamp = 'comment2_timestamp';

        // Add replies to comment 2
        List<InstagramMediaResponseWrapper.ReplyData> replies2 = new List<InstagramMediaResponseWrapper.ReplyData>();
        InstagramMediaResponseWrapper.ReplyData reply2 = new InstagramMediaResponseWrapper.ReplyData();
        reply2.text = 'Thank you!';
        reply2.username = 'user1';
        reply2.id = 'reply2_id';
        reply2.timestamp = 'reply2_timestamp';
        replies2.add(reply2);
        comment2.replies = new InstagramMediaResponseWrapper.RepliesWrapper();
        comment2.replies.data = replies2;

        // Add comments to the commentsData list
        commentsData.add(comment1);
        commentsData.add(comment2);

        // Set the commentsData to the mediaResponse
        mediaResponse.comments = new InstagramMediaResponseWrapper.cls_comments();
        mediaResponse.comments.data = commentsData;
        return mediaResponse;
    }
}