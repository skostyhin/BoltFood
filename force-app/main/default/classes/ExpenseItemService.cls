public with sharing class ExpenseItemService {

    private Map<Id, Decimal> approvedAmountsById = new Map<Id, Decimal>();
    private Set<Id> approvedIds = new Set<Id>();
    private Set<Id> nonApprovedIds = new Set<Id>();
    private Map<Id, Expense__c> expensesToUpdate = new Map<Id, Expense__c>();
    private Set<Id> deletedIds = new Set<Id>();
   
    public void updateExpense(List<Expense_Item__c> newExpenseItems) {

        for (Expense_Item__c item : newExpenseItems) {
            this.addApproved(item.Expense__c, item.Approved__c);
            if (item.Approved__c) {
                this.addAmount(item.Expense__c, item.Amount__c);                                
            }             
        }
        
        this.updateExpense();                
    }

    public void updateExpense(List<Expense_Item__c> newExpenseItems, Map<Id, Expense_Item__c> oldExpenseItemsById) {
        
        for (Expense_Item__c item : newExpenseItems) {            
            this.addApproved(item.Expense__c, item.Approved__c);
            if (oldExpenseItemsById.get(item.Id).Approved__c != item.Approved__c) {                                
                this.addAmount(item.Expense__c, item.Amount__c * (item.Approved__c ? 1 : -1));                
            }                        
        }
        
        this.updateExpense();
        
    }
    
    public void updateExpenseOnDelete(List<Expense_Item__c> oldExpenseItems) {

        for (Expense_Item__c item : oldExpenseItems) {
            this.addApproved(item.Expense__c, false);
            this.deletedIds.add(item.Id);
            if (item.Approved__c) {
                this.addAmount(item.Expense__c, -item.Amount__c);
            }             
        }
        
        this.updateExpense();
        
    }

    private void addAmount(Id expenseId, Decimal amount) {
        if (!this.approvedAmountsById.containsKey(expenseId)){
            this.approvedAmountsById.put(expenseId, 0);
        }
        this.approvedAmountsById.put(expenseId, this.approvedAmountsById.get(expenseId) + amount);
    }

    private void addApproved(Id expenseId, Boolean approved) {
        if (approved) {
            this.approvedIds.add(expenseId);
        } else {
            this.nonApprovedIds.add(expenseId);
        }
    }

    private Set<Id> getUniqueExpenseIds() {
        Set<Id> uniqueToSet1 = new Set<Id>(this.approvedIds);
        Set<Id> uniqueToSet2 = new Set<Id>(this.nonApprovedIds);

        uniqueToSet1.removeAll(this.nonApprovedIds);
        uniqueToSet2.removeAll(this.approvedIds);

        Set<Id> uniqueIds = new Set<Id>();
        uniqueIds.addAll(uniqueToSet1);
        uniqueIds.addAll(uniqueToSet2);

        return uniqueIds;
    }

    private void updateExpense() {
        this.prepareExpensesByAmount();
        this.prepareExpensesByApproved();
        
        ExpenseHandler.skip = true;
        update this.expensesToUpdate.values();
    }

    private void prepareExpensesByAmount() {
        
        this.removeEmptyAmounts();
        if (!this.approvedAmountsById.isEmpty()) {            
            List<Expense__c> expenses = [
                SELECT Id, Total_Amount__c 
                FROM Expense__c 
                WHERE Id IN :this.approvedAmountsById.keySet()
            ];        

            for (Expense__c expense : expenses) {                
                Decimal currentAmount = expense.Total_Amount__c == null ? 0 : expense.Total_Amount__c;
                Decimal additionalAmount = this.approvedAmountsById.get(expense.Id);
                Decimal newAmount = currentAmount + additionalAmount;
                this.expensesToUpdate.put(expense.Id, 
                    new Expense__c(
                        Id = expense.Id,
                        Total_Amount__c  = newAmount
                    )
                );                
            }
            
        }
        
    }

    private Set<Id> getExpensiveIdsByApprove(Set<Id> expenseIds, Boolean approved) {
        Set<Id> resultIds = new Set<Id>();
        AggregateResult[] groupedResults = [
                SELECT Expense__c
                FROM Expense_Item__c 
                WHERE Expense__c IN :expenseIds                 
                AND Approved__c = :approved
                AND Id NOT IN :this.deletedIds
                GROUP BY Expense__c
            ];

        for (AggregateResult result : groupedResults) {
            resultIds.add((Id) result.get('Expense__c'));                
        }    
        return resultIds;

    }

    private void prepareExpensesByApproved() {
       
        Set<Id> expenseIds = this.getUniqueExpenseIds();        
        if (!expenseIds.isEmpty()) {            
            Set<Id> approvedIds = this.getExpensiveIdsByApprove(expenseIds, true);
            Set<Id> nonApprovedIds = this.getExpensiveIdsByApprove(expenseIds, false);
            
            for (Id expenseId : expenseIds) {
                Expense__c expense;
                if (this.expensesToUpdate.containsKey(expenseId)) {
                    expense = this.expensesToUpdate.get(expenseId);
                } else {
                    expense = new Expense__c(Id = expenseId);
                }
                if (approvedIds.contains(expenseId) && !nonApprovedIds.contains(expenseId)) {
                    expense.All_Approved__c = true;
                } else {
                    expense.All_Approved__c = false;                        
                }
                this.expensesToUpdate.put(expenseId, expense);                    
            }         
        }        
    }

    private void removeEmptyAmounts() {
        Set<Id> expenseIdsWithEmptyAmount = new Set<Id>();
                
        for (Id expenseId : this.approvedAmountsById.keySet()) {
            if (this.approvedAmountsById.get(expenseId) == 0) {
                expenseIdsWithEmptyAmount.add(expenseId);
            }
        }
        if (!expenseIdsWithEmptyAmount.isEmpty()) {
            for (Id expenseId : expenseIdsWithEmptyAmount) {
                this.approvedAmountsById.remove(expenseId);
            }
        }
    }
}