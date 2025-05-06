trigger ExpenseItemTrigger on Expense_Item__c (after insert, after update, before delete, after undelete) {
    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            ExpenseItemHandler.beforeDelete(Trigger.old);
        }
    } 
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            ExpenseItemHandler.afterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            ExpenseItemHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isUndelete) {
            ExpenseItemHandler.afterUndelete(Trigger.new);
        }
    }
}