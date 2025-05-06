public with sharing class OverdueTaskBatch implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Status 
            FROM Task 
            WHERE ActivityDate < TODAY 
            AND IsClosed = false
            AND Status != :TaskService.OVERDUE_STATUS
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Task> tasks) {
        for (Task task : tasks) {
            task.Status = TaskService.OVERDUE_STATUS;
        }
        update tasks;
    }

    public void finish(Database.BatchableContext bc) {}
}