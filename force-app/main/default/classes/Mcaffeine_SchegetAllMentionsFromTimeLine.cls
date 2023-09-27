/*
* Test Class name : twitterSchedularApexTest
* created Date     : 29/07/2023
* Created By       : shubham kumar
* Last Modfied By  : shubham kumar
* Descritpion      :  This class schedule the api from twitter to get all mentions on the timelines..

Here is the script to schedule the class for every 10 minutes
System.schedule('Twitter Mention 1', '0 0 * * * ?',   new SchedulegetAllMentionsFromTimeLine());
System.schedule('Twitter Mention 2', '0 10 * * * ?',  new SchedulegetAllMentionsFromTimeLine());
System.schedule('Twitter Mention 3', '0 20 * * * ?',  new SchedulegetAllMentionsFromTimeLine());
System.schedule('Twitter Mention 4', '0 30 * * * ?',  new SchedulegetAllMentionsFromTimeLine());
System.schedule('Twitter Mention 5', '0 40 * * * ?',  new SchedulegetAllMentionsFromTimeLine());
System.schedule('Twitter Mention 6', '0 50 * * * ?',  new SchedulegetAllMentionsFromTimeLine());
*/

public class Mcaffeine_SchegetAllMentionsFromTimeLine implements schedulable {
    public void execute(SchedulableContext sc){
        Mcaffeine_TwitterPaginationBatches.getAdditionalMentionsFromTimeLine();
    }
    
}