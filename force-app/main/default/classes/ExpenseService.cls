
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

    public void updateExpense(Set<Id> expenseIds) {
        List<Expense__c> expensesToUpdate = new List<Expense__c>();
        AggregateResult[] groupedResults = [
            SELECT Expense__c, SUM(Amount__c) totalAmount
            FROM Expense_Item__c 
            WHERE Expense__c IN :expenseIds 
            AND Approved__c = TRUE
            GROUP BY Expense__c
        ];

        for (AggregateResult result : groupedResults) {
            Decimal totalAmount = (Decimal) result.get('totalAmount');
            expensesToUpdate.add(new Expense__c(
                Id = (Id) result.get('Expense__c'),
                Total_Amount__c = totalAmount
            ));
            expenseIds.remove((Id) result.get('Expense__c'));
        }

        if (!expenseIds.isEmpty()) {
            for (Id expenseId : expenseIds) {
                expensesToUpdate.add(new Expense__c(
                    Id = expenseId,
                    Total_Amount__c = 0
                ));
            }
        }

        if (!expensesToUpdate.isEmpty()) {
            ExpenseItemHandler.skip = true;
            update expensesToUpdate;
        }             
    }    
}