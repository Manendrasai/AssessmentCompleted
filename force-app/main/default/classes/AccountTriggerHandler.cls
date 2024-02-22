public class AccountTriggerHandler {
    
    public static void validateAccountAccess(List<Account> newAccounts, Map<Id,Account>oldMap){
        boolean AccountRecordsPermissionSet = doesRunningUserHavePermission();
        if(oldMap != null){
            for(Account acc:newAccounts){
                if(!oldMap.get(acc.Id).Active__c && acc.Active__c && acc.Type == 'Customer' && !AccountRecordsPermissionSet) {
                    acc.addError('You don not have permission to activate the account');
                }
            }
        }
        else{
            for(Account acc:newAccounts){
                if(acc.Type == 'Customer' && !AccountRecordsPermissionSet) {
                    acc.addError('You don not have permission to create the account');
                }
            }
        }
    }
    
    public static void handleAfterInsert(List<Account> newAccounts) {
        List<Contact> newContacts = new List<Contact>();
        Set<String> accountNameSetList = New Set<String>();
        Map<String,Contact> contactRepresentativeMap = New Map<String,Contact>();
        for(Account acc : newAccounts) {
            accountNameSetList.add(acc.Name+' Customer Representative');
        }
        
        for(Contact con:[SELECT Id,Name FROM Contact WHERE Name IN:accountNameSetList]){
            contactRepresentativeMap.put(con.Name,con);
        }

        for(Account acc : newAccounts) {
            if(acc.Type == 'Customer' && acc.Active__c == true) {
                // Check if there's no existing contact associated with the account
                if(contactRepresentativeMap.get(acc.Name+' Customer Representative') == Null) {
						// Create a new contact with mapping details
                        Contact newContact = new Contact(
                            AccountId = acc.Id,
                            FirstName = acc.Name,
                            LastName = 'Customer Representative',
                            Email = acc.CompanyEmail__c,
                            Phone = acc.Phone
                        );
                        newContacts.add(newContact);
				}
            }
        }
        // Check the newContacts list is not empty
        if(!newContacts.isEmpty()) { 
            insert newContacts;
            
        }
    }
    
    public static void handleAfterUpdate(List<Account> updatedAccounts, Map<Id, Account> oldMap) {
        List<Contact> newContacts = new List<Contact>();
        for(Account acc : updatedAccounts) {
            Account oldAccount = oldMap.get(acc.Id);
            // Check the account was previously inactive and is now active
            if(!oldAccount.Active__c && acc.Active__c && acc.Type == 'Customer') {
                // Check if there's no existing contact associated with the account
                Integer existingContact = [SELECT COUNT() FROM Contact WHERE AccountId = :acc.Id];
                if(existingContact == 0) {
                    // Create a new contact with mapping details
                    Contact newContact = new Contact(
                        AccountId = acc.Id,
                        FirstName = acc.Name,
                        LastName = 'Customer Representative',
                        Email = acc.CompanyEmail__c,
                        Phone = acc.Phone
                    );
                    newContacts.add(newContact);
                }
            }
        }
        // Check the newContacts list is not empty
        if(!newContacts.isEmpty()) { 
            insert newContacts;
        }
    }
    
    //Check the runnig user have permissionset is assigned
    //inputs: permissonset name
    //output: boolean 
    public static Boolean doesRunningUserHavePermission(){
        List<PermissionSetAssignment> psas = [ select Id from PermissionSetAssignment where PermissionSetId IN ( select Id from PermissionSet where Name = 'Account_Records_Access_to_AccountManager') and AssigneeId= :UserInfo.getUserId()];
        return psas.size() > 0;
    }
}