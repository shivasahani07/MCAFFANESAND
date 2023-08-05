public class ScheduleInstagramBatchForMentions implements schedulable {
    public void execute(SchedulableContext sc){
        InstagramAuthHelper.getAllMentionsFromInstaForUserId();
    }
}