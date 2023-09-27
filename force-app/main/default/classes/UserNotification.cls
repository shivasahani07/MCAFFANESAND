public class UserNotification {
    
    Public Static void notifyUserOnNewComment(List<Post_Comments__c> newCommentsList){
        for(Post_Comments__c pcmnts:newCommentsList ){
             customUsrNotification(pcmnts.id,'New_Comment');
        }
		  
    }
    
    Public Static void customUsrNotification(String setTargetId,String CustomNotificationName){
    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    notification.setBody('This is body of the custom notification!');
    notification.setTitle('Hi this is first notification sent using apex!');
    notification.setSenderId(Userinfo.getUserId());
    CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName =:CustomNotificationName];
    notification.setNotificationTypeId(type.id);
    notification.setTargetId(setTargetId); // target object id
    notification.send(new Set<String> { Userinfo.getUserId()});
    }

}