public class CaseTriggerHandler {
    Public Static void assignCaseUsingRoundRobin(List<case> caseList){
        Map<String,Group> caseOriginGroupMap = new Map<String,Group>();
        Map<String,Decimal> userIndexMap= new Map<String,Decimal>();
        // Get the queue user details
        List<Group> queueList = [
            SELECT Id,DeveloperName,
            (Select Id, UserOrGroupId FROM GroupMembers Order By ID ASC)
            FROM Group
            Where Type = 'Queue'AND (DeveloperName = 'Emails_Team' OR DeveloperName = 'Social_Media_Team')
        ];
        for(Group objQueue : queueList){
            caseOriginGroupMap.put(objQueue.DeveloperName,objQueue);
        }
        // Get the index of the last lead assigned user in the queue
        List<Case_Round_Robin_Assignment__c> crrList = Case_Round_Robin_Assignment__c.getall().values();
       for(Case_Round_Robin_Assignment__c objCRR:crrList ){
            userIndexMap.put(objCRR.Name,objCRR.User_Index__c);
        }
        Integer emailUserIndex;
        Integer socialUserIndex;
        String caseTeamLabel;
        List<Case_Round_Robin_Assignment__c> updatedCRRList=new List<Case_Round_Robin_Assignment__c>();
        for (Case objCase : caseList) {
            //system.debug('objCase.First_Time_Updated__c'+objCase.First_Time_Updated__c);
            Long oneMinuteInMilliseconds = 60 * 1000;
            if((Trigger.IsInsert || (objCase!=null && objCase.CreatedDate !=null && objCase.CreatedDate.addSeconds(10) >= system.now()))){
                system.debug('objCase'+objCase.Origin);
                if(objCase.Origin =='Email'){
                    caseTeamLabel = 'Emails_Team';
                }
                
                else if(objCase.Origin=='Facebook' || objCase.Origin=='Twitter'|| 
                        objCase.Origin=='Instagram'){
                            caseTeamLabel = 'Social_Media_Team';
                }
                emailUserIndex = (userIndexMap.get(caseTeamLabel) == null || Integer.valueOf(userIndexMap.get(caseTeamLabel)) < -1) 
                    ? -1 : Integer.valueOf(userIndexMap.get(caseTeamLabel)); 
                system.debug('emailUserIndex'+emailUserIndex);
                if (caseOriginGroupMap.get(caseTeamLabel)!=null && caseOriginGroupMap.get(caseTeamLabel).GroupMembers.size() > 0) {
                    Id queueId = caseOriginGroupMap.get(caseTeamLabel).Id;
                    Integer groupMemberSize = caseOriginGroupMap.get(caseTeamLabel).GroupMembers.size();
                    Integer userIndex =  (emailUserIndex + 1) >= groupMemberSize ? 0 : emailUserIndex + 1;
                    objCase.OwnerId = caseOriginGroupMap.get(caseTeamLabel).GroupMembers.get(userIndex).UserOrGroupId;
                    system.debug('OwnerId'+objCase.OwnerId);
                    //objCase.First_Time_Updated__c = true;
                    if(objCase.Origin =='Email'){
                        emailUserIndex = userIndex;
                    }else{
                        system.debug('userIndex'+userIndex);
                        socialUserIndex = userIndex;
                    }
                    system.debug('socialUserIndex'+socialUserIndex);
                    
                }
            }
        }     
        /* for(Case_Round_Robin_Assignment__c objCrr:crrList){
            if(objCrr.Name =='Emails_Team'){
                objCrr.User_Index__c = emailUserIndex;
            } else if(objCrr.Name =='Social_Media_Team'){
                system.debug('socialUserIndex33'+socialUserIndex);
                objCrr.User_Index__c = socialUserIndex;
            }
            system.debug('objCrr'+objCrr);
            updatedCRRList.add(objCrr);
        }
        if(updatedCRRList.size()>0){
           // update updatedCRRList;
        }*/
    }
    Public Static void updateCasePriority(List<case> caseList){
        List<Ticketing_Rules__c> listTicketRule=[SELECT ID,Ticket_Source__c,Priority__c,Keyword__c,Case_Origin__c FROM Ticketing_Rules__c];
        for(Case objcase: caseList){
            for(Ticketing_Rules__c objTicketingRule:listTicketRule){
                if(objTicketingRule!=null && objcase!=null && objcase.Subject!=null &&
                   objcase.Origin ==objTicketingRule.Case_Origin__c && objcase.Subject.Contains(objTicketingRule.Keyword__c)) {
                       objcase.Priority = objTicketingRule.Priority__c;
                   }
            } 
        }
    }
}