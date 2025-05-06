public with sharing class TaskHandler {
    public static void beforeInsert(List<Task> tasks) {
        new TaskService().overdueTasks(tasks);
    }

    public static void beforeUpdate(List<Task> tasks) {
        new TaskService().overdueTasks(tasks);
    }
}