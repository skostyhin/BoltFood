@isTest
public with sharing class OverdueTaskSchedulerTest {
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
}