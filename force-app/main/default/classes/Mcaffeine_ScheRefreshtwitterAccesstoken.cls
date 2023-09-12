public class Mcaffeine_ScheRefreshtwitterAccesstoken implements schedulable {
    public void execute(SchedulableContext sc){
        Mcaffeine_TwitterAuthentication.getRefreshedToken();
    }

}