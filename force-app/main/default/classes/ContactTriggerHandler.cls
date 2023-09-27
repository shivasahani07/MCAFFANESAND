public class ContactTriggerHandler {
    
    public static void checkDuplicateContact(List<contact> contactList,boolean isUpdate){
        Set<String> contactNumberSet= new Set<String>();
        Map<string,Map<String,contact>> existingContactMap= new Map<string,Map<String,contact>>();

        
        for(Contact contactObject:contactList){
            if(contactObject.Phone!=null){
                contactNumberSet.add(contactObject.Phone);
            }
        }
        
        for(Contact contactObject:[select id,phone,brand__C from contact where phone in:contactNumberSet]){
           Map<String,contact> tempMap= new Map<String,contact>(); 
            
            if(existingContactMap.containsKey(contactObject.phone)){
                tempMap=existingContactMap.get(contactObject.phone);
                tempMap.put(contactObject.Brand__c,contactObject);
                existingContactMap.put(contactObject.phone, tempMap);

            }else{
                tempMap.put(contactObject.Brand__c,contactObject);
                existingContactMap.put(contactObject.phone, tempMap);
            }
            //existingContactMap.put(contactObject.phone,contactObject);
        }
        
        for(Contact newContactObject:contactList){
             Map<String,contact>  existingContactBrandMap=existingContactMap.get(newContactObject.phone);
            
            if(existingContactBrandMap!=null && existingContactBrandMap.containsKey(newContactObject.Brand__c)){
                Contact existingContact=existingContactBrandMap.get(newContactObject.Brand__c);
                
                if(!isUpdate){
                	newContactObject.addError('Contact With same number and brand already exist');
                }else if(isUpdate && existingContact!=null && (newContactObject.Id!=existingContact.Id )) {
                     newContactObject.addError('Contact With same number and brand already exist');

                }
            }
            
            }
        
        existingContactMap.clear();
        for(Contact newContactObject:contactList){
            Map<String,contact> tempMap= new Map<String,contact>(); 
            
            if(existingContactMap.containsKey(newContactObject.phone)){
                tempMap=existingContactMap.get(newContactObject.phone);
                if(tempMap.containsKey(newContactObject.Brand__c)){
                    newContactObject.addError('Duplicate contact can not be inserted');
                }else{
                tempMap.put(newContactObject.Brand__c,newContactObject);
                existingContactMap.put(newContactObject.phone, tempMap);
                }

            }else{
                tempMap.put(newContactObject.Brand__c,newContactObject);
                existingContactMap.put(newContactObject.phone, tempMap);
            }
        }
        
        
        }

    


        
    }