/*
* Class name       : Mcaffeine_SchAllRecentTweetsFromTwit / Mcaffeine_SchegetAllMentionsFromTimeLine  /  Mcaffeine_ScheAllTweetsFromTimeLine / Mcaffeine_ScheRefreshtwitterAccesstoken
* created Date     : 25/08/2023
* Created By       : shubham kumar
* Last Modfied By  : shubham kumar
* Descritpion      : This class contains all the test method's for schedulars related to Twitter .
*/
@istest
public class Mcaffeine_twitterSchedularTest {
    @istest
    public static void  AllRecentTweetsFromTwitterTest() {
        Test.StartTest();
        Mcaffeine_SchAllRecentTweetsFromTwit sh1 = new Mcaffeine_SchAllRecentTweetsFromTwit();      
        String sch = '0 30 * * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    
    @istest
    public static void  AllTweetsFromTimeLineTest() {
        Test.StartTest();
        Mcaffeine_ScheAllTweetsFromTimeLine sh1 = new Mcaffeine_ScheAllTweetsFromTimeLine();      
        String sch = '0 30 * * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    
    @istest
    public static void  AllMentionsFromTimeLineTest() {
        Test.StartTest();
        Mcaffeine_SchegetAllMentionsFromTimeLine sh1 = new Mcaffeine_SchegetAllMentionsFromTimeLine();      
        String sch = '0 30 * * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    
    @istest
    public static void  scheduleRefreshAccessToken() {
        Test.StartTest();
        Mcaffeine_ScheRefreshtwitterAccesstoken sh1 = new Mcaffeine_ScheRefreshtwitterAccesstoken();      
        String sch = '0 30 * * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
}