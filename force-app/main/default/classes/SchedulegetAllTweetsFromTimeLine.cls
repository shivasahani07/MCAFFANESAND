public class SchedulegetAllTweetsFromTimeLine implements schedulable {
    public void execute(SchedulableContext sc){
        twitterApis.getAllTweetsFromTimeLine();
    }

}