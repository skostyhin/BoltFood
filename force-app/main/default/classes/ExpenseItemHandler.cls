public with sharing class ExpenseItemHandler {

    public static Boolean skip = false;

    public static void afterInsert(List<Expense_Item__c> newExpenseItems) {
        if (!skip) {
            new ExpenseItemService().updateExpense(newExpenseItems);
        }        
    }

    public static void afterUpdate(List<Expense_Item__c> newExpenseItems, Map<Id, Expense_Item__c> oldExpenseItemsById) {
        if (!skip) {
            new ExpenseItemService().updateExpense(newExpenseItems, oldExpenseItemsById);
        }
    }

    public static void beforeDelete(List<Expense_Item__c> oldExpenseItems) {
        if (!skip) {
            new ExpenseItemService().updateExpenseOnDelete(oldExpenseItems);
        }
    }

    public static void afterUndelete(List<Expense_Item__c> newExpenseItems) {
        if (!skip) {    
            new ExpenseItemService().updateExpense(newExpenseItems);
        }
    }
}