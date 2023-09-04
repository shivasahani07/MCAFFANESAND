
public class Mcaffeine_ScheduleInstagramBatchForPosts implements schedulable {
    public void execute(SchedulableContext sc){
        Mcaffeine_InstagramPostCreationBatch batch = new Mcaffeine_InstagramPostCreationBatch();
        Database.executeBatch(batch);
    }
}

