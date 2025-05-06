public with sharing class TaskService {

    public static final String OVERDUE_STATUS = 'Overdue';
    @TestVisible
    private static Boolean skipForTest = false;

    public void overdueTasks(List<Task> tasks) {
        if (skipForTest) return;
        for (Task task : tasks) {
            if (!task.IsClosed && task.ActivityDate != null 
                && task.ActivityDate < Date.today()
                && task.Status != OVERDUE_STATUS){
                task.Status = OVERDUE_STATUS;
            }
        }   
    }
}