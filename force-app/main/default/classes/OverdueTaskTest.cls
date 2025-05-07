@isTest
public with sharing class OverdueTaskTest {
    @isTest
    static void testInsertTriggerLogic() {
        Task task = new Task(Subject='Trigger Test', ActivityDate=Date.today().addDays(-1), Status='Not Started');

        Test.startTest();
            insert task;
        Test.stopTest();

        task = [SELECT Status FROM Task WHERE Id = :task.Id];
        Assert.areEqual(TaskService.OVERDUE_STATUS , task.Status);
    }

    @isTest
    static void testUpdateTriggerLogic() {
        Task task = new Task(Subject='Trigger Test', ActivityDate=Date.today().addDays(1), Status='Not Started');
        insert task;

        Test.startTest();
            task.ActivityDate = Date.today().addDays(-1);
            update task;
        Test.stopTest();

        task = [SELECT Status FROM Task WHERE Id = :task.Id];
        Assert.areEqual(TaskService.OVERDUE_STATUS, task.Status);
    }
}