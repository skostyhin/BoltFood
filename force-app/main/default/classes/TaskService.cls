public with sharing class TaskService {

    public static final String OVERDUE_STATUS = 'Overdue';

    public void overdueTasks(List<Task> tasks) {
        for (Task task : tasks) {
            if (!task.IsClosed && task.ActivityDate != null 
                && task.ActivityDate < Date.today()
                && task.Status != OVERDUE_STATUS){
                task.Status = OVERDUE_STATUS;
            }
        }   
    }
}