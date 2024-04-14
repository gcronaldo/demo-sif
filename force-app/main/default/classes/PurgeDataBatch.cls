public without sharing class PurgeDataBatch implements Database.Batchable<SObject> {
    
    private String jobName;
    private String query;
    private Integer executionOrder;
    private String dataPackID;
    private Integer batchSize;
    
    public purgeDataBatch(String jobName, String query, Integer executionOrder,Integer batchSize,String dataPackID){
        this.jobName = jobName;
        this.query = query;
        this.executionOrder = executionOrder;
        this.dataPackID = dataPackID;
        this.batchSize = batchSize;
        System.Debug('query: '+this.query);
        System.Debug('ID: '+this.dataPackID);
        System.Debug('executionOrder '+this.executionOrder);
        System.Debug('batchSize '+this.batchSize);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        delete scope;
    }

    public void finish(Database.BatchableContext bc) {
        scheduleNextJob();
        notifyUser();
    }

    private void scheduleNextJob() {

        // Query custom metadata records
        Integer execOrder = this.executionOrder + 1;
        
        //Query next Job Object
        DataPackObject__c nextDataPack = DataPackDAO.retrieveDataPackageObject(this.dataPackID,execOrder);
        
        //Check if object is empty
        //Get package and the next object from same package
        if (nextDataPack.Package__c == null){
            System.debug('Expected at least one Package for execution');  
            updateExecutionPack();  
                    
        } else{
            String jobName = 'JOB_'+nextDataPack.Package__r.Name+'_'+nextDataPack.ObjectName__c;
            PurgeDataBatch job = new PurgeDataBatch(jobName,nextDataPack.PurgeQueryConditional__c,Integer.valueOf(nextDataPack.ExecutionOrder__c),Integer.valueOf(nextDataPack.BatchSize__c),nextDataPack.Package__c);

            // Create the next batch job to run immediately
            Database.executeBatch(job, Integer.valueOf(nextDataPack.BatchSize__c));
        } 
        
    }

    // Notify users about job completion
    private void notifyUser() {
        Id userId = UserInfo.getUserId();
        Set<String> recipients = new Set<String>{userId};
        String dummyId = '000000000000000AAA';
        String bodyMsg = this.jobName + ' completed.';
        CustomNotificationFromApex.notifyUsers(recipients, dummyId, this.jobName, bodyMsg);
    }

    private void updateExecutionPack() {
        DataPackController.concludePurgeProcess(this.dataPackID);
    }
    
}