trigger ExpenseTrigger on Expense__c (after update) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            ExpenseHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}