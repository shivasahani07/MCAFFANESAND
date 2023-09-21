trigger EmailMessageTrigger on EmailMessage (after insert) {
    
    if (trigger.isAfter && trigger.isInsert){
        system.debug('Trigger Called');
       //EmailMessageTriggerHandler.updateBrandandContact(Trigger.New);
    }
}