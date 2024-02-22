@isTest
private class AccountTriggerHandlerTest {
    
    private static String accountName = 'Sample';
    @TestSetup
    static void setupData(){
        Profile profilerecord = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        //Create user
        user usr = TestDataUtility.createUser(profilerecord.id,'testuser@sqx.com');
        list<PermissionSet> PermissionSetList = [SELECT Id FROM PermissionSet WHERE Name = 'Account_Records_Access_to_AccountManager' LIMIT 1];
        if(PermissionSetList.size()>0){
            PermissionSetAssignment ps = new PermissionSetAssignment();
            ps.AssigneeId = usr.id;
            ps.PermissionSetId = PermissionSetList[0].Id; 
            insert ps;
        }
    }
    
    @isTest
    private static void testHandleAfterInsert() {
        // Create test data
        Account testAccount = TestDataUtility.createAccount(accountName,false);
        testAccount.Type = 'Customer';
        testAccount.Active__c = true;
        testAccount.AccountActivationSummary__c = 'test';
        testAccount.CompanyEmail__c = 'test@example.com';
        testAccount.Phone = '1234567890';
        insert testAccount;
        // Verify that contact is created
        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :testAccount.Id];
        System.assertEquals(1, contacts.size(), 'Contact should be created after account insertion');
    }
    
    @isTest
    private static void testHandleAfterUpdate() {
        // Create test data
        Account testAccount = TestDataUtility.createAccount(accountName,false);
        testAccount.Type = 'Customer';
        testAccount.Active__c = false;
        testAccount.AccountActivationSummary__c = 'test';
        testAccount.CompanyEmail__c = 'test@example.com';
        testAccount.Phone = '1234567890';
        insert testAccount;
        
        // Update the test account to be active
        testAccount.Active__c = true;
        testAccount.AccountActivationSummary__c = 'test';
        testAccount.Type = 'Customer'; // Change the Type
        update testAccount;
        
        // Verify that contact is created
        List<Contact> contacts = [SELECT Id FROM Contact WHERE AccountId = :testAccount.Id];
        System.assertEquals(1, contacts.size(), 'Contact should be created after account update');
    }
}