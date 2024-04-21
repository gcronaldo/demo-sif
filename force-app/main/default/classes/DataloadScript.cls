/*
 * Name: DataloadScript
 * Description: create a test data on stage objects. 
*/ 
public with sharing class DataloadScript implements Database.Batchable<Integer> {

    private Integer quantity;
    private Integer processedRecords = 0;

    public DataloadScript(Integer quantity) {
        this.quantity = quantity;
    }

    public Iterable<Integer> start(Database.BatchableContext context) {
        List<Integer> numbers = new List<Integer>();
        for (Integer i = 0; i < Math.min(quantity - processedRecords, 50000); i++) {
            numbers.add(i);
        }
        return numbers;
    }

    public void execute(Database.BatchableContext context, List<Integer> scope) {
        List<Account> accounts = new List<Account>();
        for (Integer i : scope) {
            Account acc = new Account();
            String accountInput = 'Pseudo Account ' + i;
            String accountKey = RandomStringUtil.generateRandomString(accountInput);
            acc.Name = 'Pseudo Account - ' + accountKey.substring(1, 10);
            acc.External_ID__c = accountKey;
            accounts.add(acc);
        }
        processedRecords += scope.size();
        insert accounts;
    }

    public void finish(Database.BatchableContext context) {
        if (processedRecords < quantity) {
            Integer remainingRecords = quantity - processedRecords;
            DataloadScript nextBatch = new DataloadScript(remainingRecords);
            Database.executeBatch(nextBatch);
        } else {
            System.debug('Batch execution completed.');
        }
    }
}   