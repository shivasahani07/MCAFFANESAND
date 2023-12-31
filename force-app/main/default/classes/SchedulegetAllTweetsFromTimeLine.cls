/*
* Test Class name : twitterSchedularApexTest
* created Date     : 29/07/2023
* Created By       : shubham kumar
* Last Modfied By  : shubham kumar
* Descritpion      : This class schedule the api from twitter to get all tweet on the timelines.
Here is the script to schedule the class for every 10 minutes
System.schedule('Get Tweets From TimeLine Schedular 1', '0 0 * * * ?',  new SchedulegetAllTweetsFromTimeLine());
System.schedule('Get Tweets From TimeLine Schedular 2', '0 10 * * * ?', new SchedulegetAllTweetsFromTimeLine());
System.schedule('Get Tweets From TimeLine Schedular 3', '0 20 * * * ?', new SchedulegetAllTweetsFromTimeLine());
System.schedule('Get Tweets From TimeLine Schedular 4', '0 30 * * * ?', new SchedulegetAllTweetsFromTimeLine());
System.schedule('Get Tweets From TimeLine Schedular 5', '0 40 * * * ?', new SchedulegetAllTweetsFromTimeLine());
System.schedule('Get Tweets From TimeLine Schedular 6', '0 50 * * * ?', new SchedulegetAllTweetsFromTimeLine());
*/
public class SchedulegetAllTweetsFromTimeLine implements schedulable {
    public void execute(SchedulableContext sc){
        TwitterPaginationBatches.getAllAdditionalTweetsFromTimeline();
    }
}