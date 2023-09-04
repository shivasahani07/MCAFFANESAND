public class Mcaffeine_SchenstagramBatchForHashTags implements schedulable {
    private static Mcaffeine_Instagram_Api_Details__c fap = Mcaffeine_Instagram_Api_Details__c.getInstance();	
    private static final String hashTag         = fap.HashTag__c;
    public void execute(SchedulableContext sc){
         Mcaffeine_InstagramHashTagCreationBatch batch = new Mcaffeine_InstagramHashTagCreationBatch();
         Database.executeBatch(batch);
    }
}