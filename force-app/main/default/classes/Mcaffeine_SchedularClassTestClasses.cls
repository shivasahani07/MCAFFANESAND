
@istest
public class Mcaffeine_SchedularClassTestClasses {
    @istest
    public static void  scheduleHashtag() {
        Test.StartTest();
        Mcaffeine_SchenstagramBatchForHashTags sh1 = new Mcaffeine_SchenstagramBatchForHashTags();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    @istest
    public static void  schedulePosts() {
        Test.StartTest();
        Mcaffeine_ScheduleInstagramBatchForPosts sh1 = new Mcaffeine_ScheduleInstagramBatchForPosts();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    @istest
    public static void  scheduleMentions() {
        Test.StartTest();
        Mcaffeine_ScheInstagramBatchForMentions sh1 = new Mcaffeine_ScheInstagramBatchForMentions();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }
    /*@istest
    public static void  ManageDuplicates() {
        Test.StartTest();
        ScheduleBatchForRemovingDuplicates sh1 = new ScheduleBatchForRemovingDuplicates();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
    }*/
}