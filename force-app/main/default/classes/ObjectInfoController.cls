public  without sharing class ObjectInfoController {

    @AuraEnabled(cacheable=true)
    public static List<ObjectInfo> getObjectList(){

        List<ObjectInfo> ObjectInfoList= new   List<ObjectInfo>();

        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
        String name = objTyp.getDescribe().getName();
       
        if(!name.containsignorecase('history') && !name.containsignorecase('tag')&&
            !name.containsignorecase('share') && !name.containsignorecase('feed')){      
            ObjectInfoList.add(new ObjectInfo(objTyp.getDescribe().getLabel(),objTyp.getDescribe().getName()));
            System.debug( 'Name : ' + name);
        }
        }

        return ObjectInfoList;

    }

    @AuraEnabled(cacheable=true)
    public static List<UserInfoInfo> getAllUsersList(){
         List<UserInfoInfo> userInfoInfoList= new   List<UserInfoInfo>();


        for(user userObject:[SELECT Id,name FROM User ]){
            userInfoInfoList.add(new UserInfoInfo(userObject.name,userObject.Id));

        }

        return userInfoInfoList;


    }

    @AuraEnabled
    public static List<FiledInfoObject> getAccessLeverUserWise(String userId,String objectName){
        System.debug('userId '+userId);
        System.debug('objectName '+objectName);

       // userId='005Hn00000HdGHxIAN';
        List<FiledInfoObject> listFiledInfoObject= new List<FiledInfoObject>();

        Map<String,String> apiNameMap= new Map<String,String>();
        try{
        List<String> DurableIdList= new List<String>();

        for(FieldDefinition FieldDefinitionObject: [SELECT DeveloperName,QualifiedApiName, DurableId FROM FieldDefinition  WHERE EntityDefinitionId =:objectName]){
   
           // if(!FieldDefinitionObject.QualifiedApiName.endsWith('__c') &&  !FieldDefinitionObject.DurableId.endsWith('2')){
                if(!FieldDefinitionObject.DurableId.endsWith('2')){
               //System.debug('QualifiedApiName  ' + FieldDefinitionObject.QualifiedApiName);

                DurableIdList.add(FieldDefinitionObject.DurableId+'.'+userId);
                apiNameMap.put(FieldDefinitionObject.DurableId+'.'+userId,FieldDefinitionObject.QualifiedApiName);
            }
        }
        ///System.debug('Exeption size ' + DurableIdList.size());
        //System.debug('DurableIdList'+JSON.serialize(DurableIdList));

        
      //for(String durId:DurableIdList){

       //System.debug('DurableId durId  ' + durId);

        for(UserFieldAccess UserFieldAccessObject:[SELECT DurableId,IsAccessible,IsCreatable,IsUpdatable FROM UserFieldAccess WHERE DurableId  in : DurableIdList]){
            System.debug('DurableId DurableId  ' + UserFieldAccessObject.DurableId);

            listFiledInfoObject.add(new FiledInfoObject(apiNameMap.get(UserFieldAccessObject.DurableId),UserFieldAccessObject));

        }
     // }
       
        //System.debug('listFieldAccess'+JSON.serialize(listFiledInfoObject));
        }catch(Exception e){
            System.debug('Exeption' );
            System.debug(e.getStackTraceString());
        }

        return  listFiledInfoObject;

    }

    public class ObjectInfo{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String apiName;

        public ObjectInfo(String label,String apiName){
            this.label=label;
            this.apiName=apiName;
            

        }
    }

    public class UserInfoInfo{
        @AuraEnabled
        public String userName;
        @AuraEnabled
        public String userId;

        public UserInfoInfo(String userName,String userId){
            this.userName=userName;
            this.userId=userId;
        }
    }

    Public class FiledInfoObject{
        
        @AuraEnabled
        public String fieldApiName;
        @AuraEnabled
        public UserFieldAccess userFieldAccessObject;

         public FiledInfoObject(String fieldApiName,UserFieldAccess userFieldAccessObject){
            this.fieldApiName=fieldApiName;
            this.userFieldAccessObject=userFieldAccessObject;
        }


    }

}