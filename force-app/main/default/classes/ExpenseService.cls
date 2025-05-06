
public with sharing class ExpenseService {

    public void updateExpenseItems(List<Expense__c> newExpenses, Map<Id, Expense__c> oldExpensesById) {
        Set<Id> approvedExpenseIds = new Set<Id>();
        Set<Id> nonApprovedExpenseIds = new Set<Id>();
        for (Expense__c newExpense : newExpenses) {
            if (newExpense.All_Approved__c != oldExpensesById.get(newExpense.Id).All_Approved__c) {
                if (newExpense.All_Approved__c) {
                    approvedExpenseIds.add(newExpense.Id);
                } else {
                    nonApprovedExpenseIds.add(newExpense.Id);
                }
            }
        }
            
        if (!approvedExpenseIds.isEmpty()) {
            Database.executeBatch(new ExpenseItemsUpdateBatch(approvedExpenseIds, true));
        }
        if (!nonApprovedExpenseIds.isEmpty()) {                
            Database.executeBatch(new ExpenseItemsUpdateBatch(nonApprovedExpenseIds, false));
        }            
    }   
}