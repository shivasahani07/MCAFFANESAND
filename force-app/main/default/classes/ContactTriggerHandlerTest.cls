@isTest
public class ContactTriggerHandlerTest {
    
    @testSetup static void methodName() {
		Duplicate_Contact_Check__c csobj=new Duplicate_Contact_Check__c ();
        csobj.Duplicate_Contact_Trigger_Switch__c=true;
        insert csobj;
	}
    
    @isTest
    public static void testCheckDuplicateContact() {
    
                Contact contact1 = new Contact(Phone = '123-456-7890', Brand__c = 'mCaffeine',LastName='A');
                Contact contact2 = new Contact(Phone = '987-654-3210', Brand__c = 'Hyphen',LastName='B');
                Account a=new Account(name='nitin');
        
                Test.startTest();
                insert a;
                contact1.AccountId=a.id;
                contact2.AccountId=a.id;
        		insert contact1;
                insert contact2;
        		List<Contact> listContact= [select  id from contact];
               
                System.assertEquals(listContact.size(),2);    
        	
                Test.stopTest();
         }
    
     @isTest
    public static void testCheckDuplicateContactExeption() {
    
                Contact contact1 = new Contact(Phone = '123-456-7890', Brand__c = 'mCaffeine',LastName='A');
                Contact contact2 = new Contact(Phone = '123-456-7890', Brand__c = 'mCaffeine',LastName='B');
                Account a=new Account(name='nitin');
        
                Test.startTest();
       		 Try{ 
                        insert a;
                        contact1.AccountId=a.id;
                        contact2.AccountId=a.id;
                        insert contact1;
                        insert contact2;
                        List<Contact> listContact= [select  id from contact];
                       
                        System.assertEquals(listContact.size(),2);    
                    
                        Test.stopTest();
             }catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Contact With same number and brand already exist') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
             }
         }
    
         @isTest
    public static void testCheckDuplicateContactInData() {
        
               List<Contact> contactList= new List<contact>();
                for(Integer i=0;i<10;i++){
                    contact con= new Contact();
                    con.firstName='Test'+i;    
                    con.lastName='Test L'+i;
                    con.Brand__C='mCaffeine';
                    con.phone=''+i;
                    contactList.add(con);
                }
                
                    contact con= new Contact();
                    con.firstName='Test 2';  
                    con.lastName='Test L 2';
                    con.Brand__C='mCaffeine';
                    con.phone=''+2;
                    contactList.add(con);
                    
       				 Test.startTest();
        			Try{ 
                       insert(contactList);
                       Test.stopTest();
            	 }catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Duplicate contact can not be inserted') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
             }
                        
        
        
    }

    
    
}