In my solutions I use clear Apex without any framework to show my vision without ready-made third-party tools.

# Implement Salesforce Triggers for Expense Management

1. I changed a Total_Amount__c field type from Number to Roll-Up Summary cause it make necessary condition in more simple way.
2. I use batch for a case of a lot Expense_Item__c records. Some batch instance can fault. It is a part of solution for a big records count. Optional we can add error notification. We can use standard DML update without batch in case under limitation record counts.
3. I use AggregateResult because better to have a 2000 limit of group records instead of 50000 for all.
4. Also we can additionally add 2 Roll-Up Summary field and formula to calculate count of all related records and count of approved related records.
5. In the ExpanseBatch, I prefer to use 2 batches to split approved and non-approved records
6. In separate branch https://github.com/skostyhin/BoltFood/tree/Amount-as-Number I made Total_Amount__c recalculation for Numeric type. But, cause of the task did not ask about the reaction to change the amount in the record, this part is not in that solution.

# Making Open Tasks Overdue

Task can be overdue in two ways:
1. We update fields (change status or date). We can use ApexTrigger or Triggered Flow.
We can use Flow. But to show Apex code I chosen Apex Trigger.
2. Date changed by itself. We can use Scheduler or Schedule Flow.
For a weekly or monthly schedule we can use Flow. For per day schedule we have to use Scheduler and Batch.