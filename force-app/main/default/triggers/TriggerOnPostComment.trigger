trigger TriggerOnPostComment on Post_Comments__c (before insert,after insert) {
    if(trigger.IsInsert && trigger.IsAfter){
       // UserNotification.notifyUserOnNewComment(trigger.new);
    }

}