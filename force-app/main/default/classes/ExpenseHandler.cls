public with sharing class ExpenseHandler {

    public static Boolean skip = false;

    public static void afterUpdate(List<Expense__c> newExpenses, Map<Id, Expense__c> oldExpensesById) {
        if (!skip) {
            new ExpenseService().updateExpenseItems(newExpenses, oldExpensesById);
        }        
    }
}