public class SchedulegetAllRecentTweetsFromTwitter implements schedulable {
    public void execute(SchedulableContext sc){
        twitterApis.getAllRecentTweetsFromTwitter();
    }

}