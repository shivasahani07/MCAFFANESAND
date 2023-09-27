trigger ContactObjectTrigger on Contact (before insert,before update ) {

    if(trigger.isbefore && (Trigger.isInsert|| trigger.isUpdate)){
        ContactTriggerHandler.checkDuplicateContact(trigger.new,Trigger.isUpdate);
    }
    
    
}