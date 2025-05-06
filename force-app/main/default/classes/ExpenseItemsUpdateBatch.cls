public with sharing class ExpenseItemsUpdateBatch implements Database.Batchable<SObject> {
    private Set<Id> expenseIds;
    private Boolean approved;

    public ExpenseItemsUpdateBatch(Set<Id> expenseIds, Boolean approved) {
        this.expenseIds = expenseIds;
        this.approved = approved;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Expense__c, Approved__c 
            FROM Expense_Item__c 
            WHERE Expense__c IN :this.expenseIds 
            AND Approved__c != :this.approved
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Expense_Item__c> items){
        for (Expense_Item__c item : items) {
            item.Approved__c = this.approved;   
        }
        ExpenseItemHandler.skip = true;
        update items;
    }
    public void finish(Database.BatchableContext bc){
        new ExpenseService().updateExpense(this.expenseIds);
    }
}