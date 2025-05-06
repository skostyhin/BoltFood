public with sharing class OverdueTaskScheduler implements Schedulable{
    public void execute(SchedulableContext sc) {
        OverdueTaskBatch batch = new OverdueTaskBatch();
        Database.executeBatch(batch, 200);
    }
}