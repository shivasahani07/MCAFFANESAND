public class Mcaffeine_ScheInstagramBatchForMentions implements schedulable {
    public void execute(SchedulableContext sc){
       Mcaffeine_InstagramMentionCreationBatch batch = new Mcaffeine_InstagramMentionCreationBatch();
       Database.executeBatch(batch);
    }
}