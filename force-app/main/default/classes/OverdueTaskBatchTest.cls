@isTest
public with sharing class OverdueTaskBatchTest {
    @isTest
    static void testBatchExecution() {
        TaskService.skipForTest = true;
        List<Task> tasks = new List<Task>{
            new Task(Subject='Past Due', ActivityDate=Date.today().addDays(-1), Status='Not Started'),
            new Task(Subject='Future Due', ActivityDate=Date.today().addDays(1), Status='Not Started'),
            new Task(Subject='Completed', ActivityDate=Date.today().addDays(-2), Status='Completed')
        };
        insert tasks;

        Test.startTest();
        OverdueTaskBatch batch = new OverdueTaskBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        tasks = [SELECT Status FROM Task WHERE Subject = 'Past Due'];
        Assert.areEqual(TaskService.OVERDUE_STATUS, tasks[0].Status);
    }
}