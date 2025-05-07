@isTest
public with sharing class ExpenseTest {

    private static Integer EXPENSE_COUNT = 4;
    private static Integer EXPENSE_ITEM_COUNT = 50;
    private static Integer EXPENSE_AMOUNT = 10;

    @isTest
    public static void createExpensesWithApprovedItems(){
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
        Test.startTest();
            insert items;
        Test.stopTest();
        
        List<Expense__c> resultExpenses = [
            SELECT Id, All_Approved__c, Total_Amount__c, 
            (SELECT Id, Amount__c FROM Expense_Items__r) 
            FROM Expense__c 
            WHERE Id IN :expenseIds];
        Assert.areEqual(EXPENSE_COUNT, resultExpenses.size());
        Assert.areEqual(EXPENSE_ITEM_COUNT, resultExpenses[0].Expense_Items__r.size());
        Assert.areEqual(EXPENSE_ITEM_COUNT * EXPENSE_AMOUNT, resultExpenses[0].Total_Amount__c);
        Assert.isTrue(resultExpenses[0].All_Approved__c);
        
        Decimal totalAmount = 0;
        for (Expense__c expense : resultExpenses) {
            for (Expense_Item__c item : expense.Expense_Items__r) {
                totalAmount += item.Amount__c;
            }            
        }
        Assert.areEqual(EXPENSE_COUNT * EXPENSE_ITEM_COUNT * EXPENSE_AMOUNT, totalAmount);
    }

    @isTest
    public static void createExpenseWithDifferentItems(){
        Expense__c expense = new Expense__c();
        insert expense;
        
        List<Expense_Item__c> items = new List<Expense_Item__c>();
        for (Integer j = 0; j < EXPENSE_ITEM_COUNT; j++) {
            items.add(new Expense_Item__c(
                Expense__c = expense.Id, 
                Amount__c = EXPENSE_AMOUNT,
                Approved__c = j == 0)
            );
        }
                    
        Test.startTest();
            insert items;
        Test.stopTest();
        
        Expense__c resultExpense = [
            SELECT Id, All_Approved__c, Total_Amount__c            
            FROM Expense__c 
            WHERE Id = :expense.Id];
        Assert.areEqual(EXPENSE_AMOUNT, resultExpense.Total_Amount__c);
        Assert.isFalse(resultExpense.All_Approved__c);        
    }

    @isTest
    public static void updateExpenseItemsWithZeroAmount(){
        Expense__c expense = new Expense__c();
        insert expense;
        
        List<Expense_Item__c> items = new List<Expense_Item__c>();
        for (Integer j = 0; j < 2; j++) {
            items.add(new Expense_Item__c(
                Expense__c = expense.Id, 
                Amount__c = EXPENSE_AMOUNT,
                Approved__c = j == 0)
            );
        }
        insert items;
        for (Expense_Item__c item : items) {
            item.Approved__c = !item.Approved__c;
        }
                    
        Test.startTest();
            update items;
        Test.stopTest();
        
        Expense__c resultExpense = [
            SELECT Id, All_Approved__c, Total_Amount__c            
            FROM Expense__c 
            WHERE Id = :expense.Id];
        Assert.areEqual(EXPENSE_AMOUNT, resultExpense.Total_Amount__c);
        Assert.isFalse(resultExpense.All_Approved__c);        
    }

    @isTest
    public static void updateApprovedExpenseByNonApprovedItem(){
        Expense__c expense = new Expense__c();
        insert expense;
        
        List<Expense_Item__c> items = new List<Expense_Item__c>();
        for (Integer j = 0; j < EXPENSE_ITEM_COUNT; j++) {
            items.add(new Expense_Item__c(
                Expense__c = expense.Id, 
                Amount__c = EXPENSE_AMOUNT,
                Approved__c = TRUE)
            );
        }
        insert items;        
        items[0].Approved__c = FALSE;
                            
        Test.startTest();
            update items[0];
        Test.stopTest();
        
        Expense__c resultExpense = [
            SELECT Id, All_Approved__c, Total_Amount__c            
            FROM Expense__c 
            WHERE Id = :expense.Id];
        Assert.areEqual((EXPENSE_ITEM_COUNT - 1) * EXPENSE_AMOUNT, resultExpense.Total_Amount__c);
        Assert.isFalse(resultExpense.All_Approved__c);        
    }

    @isTest
    public static void DeleteApprovedExpenseByNonApprovedItem(){
        Expense__c expense = new Expense__c();
        insert expense;
        
        List<Expense_Item__c> items = new List<Expense_Item__c>();
        for (Integer j = 0; j < EXPENSE_ITEM_COUNT; j++) {
            items.add(new Expense_Item__c(
                Expense__c = expense.Id, 
                Amount__c = EXPENSE_AMOUNT,
                Approved__c = TRUE)
            );
        }
        insert items;        
                                    
        Test.startTest();
            delete items;
        Test.stopTest();
        
        Expense__c resultExpense = [
            SELECT Id, All_Approved__c, Total_Amount__c            
            FROM Expense__c 
            WHERE Id = :expense.Id];
        Assert.areEqual(0, resultExpense.Total_Amount__c);
        Assert.isFalse(resultExpense.All_Approved__c);        
    }

    @isTest
    public static void UndeleteApprovedExpensesItem(){
        Expense__c expense = new Expense__c();
        insert expense;
        
        List<Expense_Item__c> items = new List<Expense_Item__c>();
        for (Integer j = 0; j < EXPENSE_ITEM_COUNT; j++) {
            items.add(new Expense_Item__c(
                Expense__c = expense.Id, 
                Amount__c = EXPENSE_AMOUNT,
                Approved__c = TRUE)
            );
        }
        insert items;        
        delete items;        
                                    
        Test.startTest();
            undelete items;    
        Test.stopTest();
        
        Expense__c resultExpense = [
            SELECT Id, All_Approved__c, Total_Amount__c            
            FROM Expense__c 
            WHERE Id = :expense.Id];            
        Assert.areEqual(EXPENSE_ITEM_COUNT * EXPENSE_AMOUNT, resultExpense.Total_Amount__c);
        Assert.isTrue(resultExpense.All_Approved__c);        
    }

    @isTest
    public static void updateExpensesWithApprovedItems(){
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

        for (Expense__c expense : expenses) {
            expense.All_Approved__c = FALSE;                        
        }

        Test.startTest();
            ExpenseHandler.skipExpenseItemsUpdate = false;
            update expenses;            
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

        for (Expense__c expense : expenses) {
            expense.All_Approved__c = TRUE;            
        }

        Test.startTest();
            ExpenseHandler.skipExpenseItemsUpdate = false;
            update expenses;
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