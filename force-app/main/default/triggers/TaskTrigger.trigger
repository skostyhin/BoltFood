trigger TaskTrigger on Task (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            TaskHandler.beforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            TaskHandler.beforeUpdate(Trigger.new);
        }
    } 
}