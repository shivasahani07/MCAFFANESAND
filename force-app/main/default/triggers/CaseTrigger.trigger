trigger CaseTrigger on Case (before insert,after update,before update,after insert) {
    if (trigger.isBefore && trigger.isInsert){
        CaseTriggerHandler.assignCaseUsingRoundRobin(Trigger.New);
        //CaseTriggerHandler.updateCasePriority(Trigger.New);
        //CaseTriggerHandler.updateCaseContact(Trigger.New);
    }
    if (trigger.isBefore && trigger.isUpdate){
        CaseTriggerHandler.assignCaseUsingRoundRobin(Trigger.New);
        for(Case ca:Trigger.new)
        {
            system.debug('Old Value'+Trigger.oldmap.get(ca.id).Brand__c);
            system.debug('New Value'+Trigger.newmap.get(ca.id).Brand__c);
            if(Trigger.oldmap.get(ca.id).Brand__c!=Trigger.newmap.get(ca.id).Brand__c)
            {
                system.debug('true');
            }
            
        }
        //CaseTriggerHandler.updateCasePriority(Trigger.New);
        //CaseTriggerHandler.updateCaseContact(Trigger.New);
    }
    if (trigger.isAfter && trigger.isInsert){
        
       // CaseTriggerHandler.updateCaseContact(Trigger.New);
    }
}