    /* Test Class name : twitterSchedularApexTest
* created Date     : 29/07/2023
* Created By       : shubham kumar
* Last Modfied By  : shubham kumar
* Descritpion      : This class schedule the api from twitter to get all recent tweets from the timelines.
Here is the script to schedule the class for every 10 minutes
System.schedule('Get Recent Tweets  Schedular 1', '0 0 * * * ?',  new SchedulegetAllRecentTweetsFromTwitter());
System.schedule('Get Recent Tweets  Schedular 2', '0 10 * * * ?', new SchedulegetAllRecentTweetsFromTwitter());
System.schedule('Get Recent Tweets  Schedular 3', '0 20 * * * ?', new SchedulegetAllRecentTweetsFromTwitter());
System.schedule('Get Recent Tweets  Schedular 4', '0 30 * * * ?', new SchedulegetAllRecentTweetsFromTwitter());
System.schedule('Get Recent Tweets  Schedular 5', '0 40 * * * ?', new SchedulegetAllRecentTweetsFromTwitter());
System.schedule('Get Recent Tweets  Schedular 6', '0 50 * * * ?', new SchedulegetAllRecentTweetsFromTwitter());
*/
    public class Mcaffeine_SchAllRecentTweetsFromTwit implements schedulable {
        public void execute(SchedulableContext sc){
            Mcaffeine_TwitterPaginationBatches.getAdditionalRecentTweets();
        }
    
    }
