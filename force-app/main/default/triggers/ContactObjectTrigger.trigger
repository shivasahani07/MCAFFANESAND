trigger ContactObjectTrigger on Contact (before insert,before update ) {
    
    Duplicate_Contact_Check__c  duplicateContactTriggerSwitch = Duplicate_Contact_Check__c.getOrgDefaults();


    if(trigger.isbefore && (Trigger.isInsert|| trigger.isUpdate) && duplicateContactTriggerSwitch.Duplicate_Contact_Trigger_Switch__c){
        ContactTriggerHandler.checkDuplicateContact(trigger.new,Trigger.isUpdate,Trigger.oldMap);
    }
    
    
}