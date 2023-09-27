/*
Here is the script to schedule the class for every 10 minutes
System.schedule('Post Schedular 1', '0 0 * * * ?',  new ScheduleNextBatchForMentions());
System.schedule('Post Schedular 2', '0 10 * * * ?', new ScheduleNextBatchForMentions());
System.schedule('Post Schedular 3', '0 20 * * * ?', new ScheduleNextBatchForMentions());
System.schedule('Post Schedular 4', '0 30 * * * ?', new ScheduleNextBatchForMentions());
System.schedule('Post Schedular 5', '0 40 * * * ?', new ScheduleNextBatchForMentions());
System.schedule('Post Schedular 6', '0 50 * * * ?', new ScheduleNextBatchForMentions());
*/

public class ScheduleNextBatchForMentions implements schedulable {
    public void execute(SchedulableContext sc){
        twitterApis.getAllRecentTweetsFromTwitter();
    }
    
}