global class TicketEmailServiceBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator('SELECT Id,Name FROM Lead Limit 1');
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
     	TicketEmailService.testemail('test');
    }

   global void finish(Database.BatchableContext BC){
   }
}