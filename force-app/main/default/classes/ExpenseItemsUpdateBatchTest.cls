@isTest
public with sharing class ExpenseItemsUpdateBatchTest {

    private static Integer EXPENSE_COUNT = 4;
    private static Integer EXPENSE_ITEM_COUNT = 50;
    private static Integer EXPENSE_AMOUNT = 10;

    @isTest
    static void updateExpensesWithApprovedItems() {
        List<Expense__c> expenses = new List<Expense__c>();
        for (Integer i = 0; i < EXPENSE_COUNT; i++) {
            expenses.add(new Expense__c());
        }
        
        insert expenses;

        Set<Id> expenseIds = new Set<Id>();
        List<Expense_Item__c> items = new List<Expense_Item__c>();
        for (Expense__c expense : expenses) {
            expenseIds.add(expense.Id);
            for (Integer j = 0; j < EXPENSE_ITEM_COUNT; j++) {
                items.add(new Expense_Item__c(
                    Expense__c = expense.Id, 
                    Amount__c = EXPENSE_AMOUNT,
                    Approved__c = TRUE)
                );
            }            
        }
        insert items;

        Set<Id> nonApprovedExpenseIds = new Set<Id>();
        for (Expense__c expense : expenses) {            
            nonApprovedExpenseIds.add(expense.Id);
        }

        Test.startTest();
            Database.executeBatch(new ExpenseItemsUpdateBatch(nonApprovedExpenseIds, false));
        Test.stopTest();
        
        List<Expense__c> resultExpenses = [
            SELECT Id, All_Approved__c, Total_Amount__c, 
            (SELECT Id, Approved__c FROM Expense_Items__r) 
            FROM Expense__c 
            WHERE Id IN :expenseIds];
        Assert.areEqual(EXPENSE_COUNT, resultExpenses.size());
        Assert.areEqual(EXPENSE_ITEM_COUNT, resultExpenses[0].Expense_Items__r.size());
        Assert.areEqual(0, resultExpenses[0].Total_Amount__c);        
        
        for (Expense__c expense : resultExpenses) {
            for (Expense_Item__c item : expense.Expense_Items__r) {
                Assert.isFalse(item.Approved__c);                        
            }            
        }       
    }

    @isTest
    public static void updateExpensesWithNonapprovedItems(){
        List<Expense__c> expenses = new List<Expense__c>();
        for (Integer i = 0; i < EXPENSE_COUNT; i++) {
            expenses.add(new Expense__c());
        }
        
        insert expenses;

        Set<Id> expenseIds = new Set<Id>();
        List<Expense_Item__c> items = new List<Expense_Item__c>();
        for (Expense__c expense : expenses) {
            expenseIds.add(expense.Id);
            for (Integer j = 0; j < EXPENSE_ITEM_COUNT; j++) {
                items.add(new Expense_Item__c(
                    Expense__c = expense.Id, 
                    Amount__c = EXPENSE_AMOUNT,
                    Approved__c = FALSE)
                );
            }
            
        }
        insert items;

        Set<Id> approvedExpenseIds = new Set<Id>();
        for (Expense__c expense : expenses) {            
            approvedExpenseIds.add(expense.Id);
        }

        Test.startTest();
            Database.executeBatch(new ExpenseItemsUpdateBatch(approvedExpenseIds, true));
        Test.stopTest();
        
        List<Expense__c> resultExpenses = [
            SELECT Id, All_Approved__c, Total_Amount__c, 
            (SELECT Id, Approved__c FROM Expense_Items__r) 
            FROM Expense__c 
            WHERE Id IN :expenseIds];
        Assert.areEqual(EXPENSE_COUNT, resultExpenses.size());
        Assert.areEqual(EXPENSE_ITEM_COUNT, resultExpenses[0].Expense_Items__r.size());
        Assert.areEqual(EXPENSE_ITEM_COUNT * EXPENSE_AMOUNT, resultExpenses[0].Total_Amount__c);        
        
        for (Expense__c expense : resultExpenses) {
            for (Expense_Item__c item : expense.Expense_Items__r) {
                Assert.IsTrue(item.Approved__c);                        
            }            
        }        
    }
}