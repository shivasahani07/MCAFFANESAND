public class SchedulegetAllMentionsFromTimeLine implements schedulable {
    public void execute(SchedulableContext sc){
        twitterApis.getAllMentionsFromTimeLine();
    }
    
}