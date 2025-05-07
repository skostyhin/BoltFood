public with sharing class ExpenseItemHandler {

    public static Boolean skipExpenseRecalculating = false;

    public static void afterInsert(List<Expense_Item__c> newExpenseItems) {
        if (!skipExpenseRecalculating) {
            new ExpenseItemService().recalculateExpenseApprovedFlag(newExpenseItems);
        }        
    }

    public static void afterUpdate(List<Expense_Item__c> newExpenseItems, Map<Id, Expense_Item__c> oldExpenseItemsById) {
        if (!skipExpenseRecalculating) {
            new ExpenseItemService().recalculateExpenseApprovedFlag(newExpenseItems, oldExpenseItemsById);
        }
    }

    public static void beforeDelete(List<Expense_Item__c> oldExpenseItems) {
        if (!skipExpenseRecalculating) {
            new ExpenseItemService().recalculateExpenseApprovedFlagOnDelete(oldExpenseItems);
        }
    }

    public static void afterUndelete(List<Expense_Item__c> newExpenseItems) {
        if (!skipExpenseRecalculating) {    
            new ExpenseItemService().recalculateExpenseApprovedFlag(newExpenseItems);
        }
    }
}