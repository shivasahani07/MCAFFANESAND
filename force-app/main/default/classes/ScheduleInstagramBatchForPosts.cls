public class ScheduleInstagramBatchForPosts implements schedulable {
    public void execute(SchedulableContext sc){
        InstagramAuthHelper.getAllPostsFromInstaForUserId();
    }
}