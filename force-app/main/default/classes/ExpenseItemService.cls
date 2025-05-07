public with sharing class ExpenseItemService {

    private Map<Id, Decimal> approvedAmountsById = new Map<Id, Decimal>();
    private Set<Id> approvedIds = new Set<Id>();
    private Set<Id> nonApprovedIds = new Set<Id>();
    private Map<Id, Expense__c> expensesToUpdate = new Map<Id, Expense__c>();
    private Set<Id> deletedIds = new Set<Id>();
   
    public void recalculateExpenseApprovedFlag(List<Expense_Item__c> newExpenseItems) {

        for (Expense_Item__c item : newExpenseItems) {
            this.addApproved(item.Expense__c, item.Approved__c);
            if (item.Approved__c) {
                this.addAmount(item.Expense__c, item.Amount__c);                                
            }             
        }
        
        this.updateExpenseApprovedFlag();                
    }

    public void recalculateExpenseApprovedFlag(List<Expense_Item__c> newExpenseItems, Map<Id, Expense_Item__c> oldExpenseItemsById) {
        
        for (Expense_Item__c item : newExpenseItems) {            
            this.addApproved(item.Expense__c, item.Approved__c);
            if (oldExpenseItemsById.get(item.Id).Approved__c != item.Approved__c) {                                
                this.addAmount(item.Expense__c, item.Amount__c * (item.Approved__c ? 1 : -1));                
            }                        
        }
        
        this.updateExpenseApprovedFlag();
        
    }
    
    public void recalculateExpenseApprovedFlagOnDelete(List<Expense_Item__c> oldExpenseItems) {

        for (Expense_Item__c item : oldExpenseItems) {
            this.addApproved(item.Expense__c, false);
            this.deletedIds.add(item.Id);
            if (item.Approved__c) {
                this.addAmount(item.Expense__c, -item.Amount__c);
            }             
        }
        
        this.updateExpenseApprovedFlag();
        
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

    private void updateExpenseApprovedFlag() {        
        Set<Id> expenseIds = this.getUniqueExpenseIds();        
        if (!expenseIds.isEmpty()) {            
            Set<Id> approvedIds = this.getExpensiveIdsByApproveFlag(expenseIds, true);
            Set<Id> nonApprovedIds = this.getExpensiveIdsByApproveFlag(expenseIds, false);
            
            for (Id expenseId : expenseIds) {
                
                this.expensesToUpdate.put(
                    expenseId, 
                    new Expense__c(
                        Id = expenseId,
                        All_Approved__c = approvedIds.contains(expenseId) && !nonApprovedIds.contains(expenseId)
                    )
                );                    
            }         
        } 
        
        ExpenseHandler.skipExpenseItemsUpdate = true;
        update this.expensesToUpdate.values();
    }

    private Set<Id> getExpensiveIdsByApproveFlag(Set<Id> expenseIds, Boolean approved) {
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
}