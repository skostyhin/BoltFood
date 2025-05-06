@isTest
public with sharing class OverdueTaskTest {

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

    @isTest
    static void testScheduler() {
        Test.startTest();
            OverdueTaskScheduler scheduler = new OverdueTaskScheduler();
            String cron = '0 0 0 * * ?';
            String jobId = System.schedule('Test Schedule', cron, scheduler);
        Test.stopTest();

        CronTrigger cronTrigger = [
			SELECT Id, CronExpression, TimesTriggered, NextFireTime
			FROM CronTrigger 
			WHERE id = :jobId
		];

        Assert.areEqual(cron, cronTrigger.CronExpression);
        Assert.areEqual(0, cronTrigger.TimesTriggered);
    }

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