public with sharing class ExpenseHandler {

    public static Boolean skipExpenseItemsUpdate = false;

    public static void afterUpdate(List<Expense__c> newExpenses, Map<Id, Expense__c> oldExpensesById) {
        if (!skipExpenseItemsUpdate) {
            new ExpenseService().updateExpenseItems(newExpenses, oldExpensesById);
        }        
    }
}