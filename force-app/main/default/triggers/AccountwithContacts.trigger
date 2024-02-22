trigger AccountwithContacts on Account (Before insert,Before Update,After insert,After Update) {
    
    if (Trigger.isBefore) {
        AccountTriggerHandler.validateAccountAccess(Trigger.new, Trigger.oldMap);
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            AccountTriggerHandler.handleAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            AccountTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }


}