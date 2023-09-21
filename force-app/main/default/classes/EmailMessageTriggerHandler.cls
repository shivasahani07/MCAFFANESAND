public class EmailMessageTriggerHandler {
    
    Public Static void updateBrandandContact(List<EmailMessage> msgList){
        set<id> mCaffId=new set<id>();
        List<Case> caseList=new List<Case>();
        for(EmailMessage em:msgList)
        {
            if(em.ToAddress=='testtechila@gmail.com' && em.ParentId!=Null)
            {
                mCaffId.add(em.ParentId);
            }
        }
        if(!mCaffId.isEmpty())
        {
            caseList=[Select id,Subject,Description,SuppliedEmail,Brand__c From Case where id IN: mCaffId];
            if(!caseList.isEmpty())
            {
                updateCaseContact(caseList,'mCaffeine');
            }
        }
    }
    
     Public Static Void updateCaseContact(List<case> caseList, string brandname){
        Map<String,Case> caseAndEmailMap = new Map<String,Case>();
        List<Contact> conList = new List<Contact>();

        for(Case objCase : caseList){
            objCase.Brand__c=brandname;
            system.debug('Subject---->'+objCase.Subject);
            if(objCase!=null && objCase.Subject!=null && objCase.Subject.Contains('New customer message on') && objCase.Description!=null){
                
                String[] lines = objCase.Description.split('\n');
                Boolean isEmailSection = false;
                String email = '';
                system.debug('objCase.Description---->'+objCase.Description);
                for (String line : lines) {
                    if (line.contains('Email:')) {
                        isEmailSection = true;
                    } else if (isEmailSection && !String.isBlank(line)) {
                        String emailPrefix = '<mailto:';
                        String emailSuffix = '>';
                        
                        Integer emailStartIdx = line.indexOf(emailPrefix);
                        Integer emailEndIdx = line.indexOf(emailSuffix);
                        
                        if (emailStartIdx != -1 && emailEndIdx != -1) {
                            email = line.substring(0, emailStartIdx).trim();
                            break;
                        }
                    }
                }
                system.debug('email---->'+email);
                if (!String.isBlank(email) && isEmail(email)) {
                    if(!caseAndEmailMap.containsKey(email)){
                        caseAndEmailMap.put(email, objCase);
                        objCase.SuppliedEmail = email;
                        
                    }
                }
                
            }else{
                if(!caseAndEmailMap.containsKey(objCase.SuppliedEmail)){
                    caseAndEmailMap.put(objCase.SuppliedEmail, objCase);
                }
            }
            
        }
        system.debug('caseAndEmailMap---->'+caseAndEmailMap);
       if(caseAndEmailMap!=null){
            List<Contact> contactList = [SELECT Id,Email FROM Contact WHERE Email IN: caseAndEmailMap.keySet() AND Brand__c=:brandname];
            Map<String,Contact> contactEmailMap = New Map<String,Contact>();
            for(Contact objContact: contactList){
                if(!contactEmailMap.containsKey(objContact.Email)){
                    contactEmailMap.put(objContact.Email, objContact);
                }
            }
            
            Map<String,Contact> updatedContactEmailMap = New Map<String,Contact>();
            List<Case> updatedCaseList = new List<Case>();
            for(Case ObjectCase : caseList){
                if(contactEmailMap!=null && contactEmailMap.get(ObjectCase.SuppliedEmail)!=null ){
                    ObjectCase.ContactId = contactEmailMap.get(ObjectCase.SuppliedEmail).Id;
                    // updatedCaseList.add(ObjectCase);
                }else{
                    //system.debug('ObjectCase.SuppliedEmail'+ObjectCase.SuppliedEmail);
                    if(ObjectCase.SuppliedEmail!=null && ObjectCase.SuppliedEmail.contains('@')){
                        Contact objCon = new Contact();
                        objCon.LastName = ObjectCase.SuppliedEmail.split('@')[0];
                        objCon.Email = ObjectCase.SuppliedEmail;
                        conList.add(objCon);
                        if(!updatedContactEmailMap.containsKey(ObjectCase.SuppliedEmail)){
                            updatedContactEmailMap.put(ObjectCase.SuppliedEmail,objCon);
                        }
                    }
                }
            }
            if(updatedContactEmailMap.size() > 0){
                try {
                    insert updatedContactEmailMap.values();
                } catch (DmlException ex) {
                    system.debug('ex'+ex);
                }
            }
            for(Case ObjectCase : caseList){
                if(updatedContactEmailMap!=null && updatedContactEmailMap.get(ObjectCase.SuppliedEmail)!=null ){
                    ObjectCase.ContactId = updatedContactEmailMap.get(ObjectCase.SuppliedEmail).Id;
                }
            }
        }
    }
    public static Boolean isEmail(String input) {
        String emailPattern = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        return Pattern.matches(emailPattern, input);
    }

}