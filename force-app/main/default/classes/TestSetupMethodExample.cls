@IsTest(SeeAllData=true)
public class TestSetupMethodExample {
    
    @isTest static void testMethod1() {
        
        User sss=[select id from user where id='005Hn00000HdGHxIAN'];
        system.runAs(sss){
            ObjectInfoController.getAccessLeverUserWise('005Hn00000HdGHxIAN','Order');
            system.assert(true);
        }
        
    }

}