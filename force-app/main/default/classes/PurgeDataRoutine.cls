/*
 * Name: PurgeDataRoutine
 * Description: execute the purge data. 
*/ 
public without sharing class PurgeDataRoutine implements Database.Batchable<SObject> {

    // Expected input parameters 
    private String jobName;
    private String query;
    private Integer executionOrder;
    private String packageName;
    
    public PurgeDataRoutine(String jobName, String query, Integer executionOrder, String packageName) {
        this.jobName = jobName;
        this.query = query;
        this.executionOrder = executionOrder;
        this.packageName = packageName;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        delete scope;
    }

    public void finish(Database.BatchableContext bc) {
        scheduleNextJob();
    }

    private void scheduleNextJob() {

        // Query custom metadata records
        Integer exeOrder = this.executionOrder + 1;
        DataPurgeSetup__mdt[] dps = [SELECT MasterLabel, BatchSize__c, Query__c, Active__c, ExecutionOrder__c, PackageExecution__c
                                     FROM DataPurgeSetup__mdt
                                     WHERE Active__c =: true
                                     AND PackageExecution__c =: this.packageName
                                     AND ExecutionOrder__c =: exeOrder
                                     LIMIT 1];
        
        if (!dps.isEmpty()) {

            // Retrieve parameters for batch job
            String query = dps[0].Query__c;
            String jobName = dps[0].MasterLabel;
            Integer batchSize = Integer.valueOf(dps[0].BatchSize__c);
            
            // Prepare the next batch job
            PurgeDataRoutine job = new PurgeDataRoutine(jobName, query, exeOrder, this.packageName);
            
            // Create the next batch job to run immediately
            Database.executeBatch(job, batchSize);
        }
        
        
        // Notify users about job completion
        Set<String> recipients = new Set<String>{'005am000000ckUsAAI'};
        String dummyId = '000000000000000AAA';
        String bodyMsg = this.jobName + ' completed.';
        CustomNotificationFromApex.notifyUsers(recipients, dummyId, this.packageName, bodyMsg);
    }
}