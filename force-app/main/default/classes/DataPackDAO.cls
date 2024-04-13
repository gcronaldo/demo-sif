public class DataPackDAO {
    
    //Return DataPack and DataPackObjects
    public static DataPackObject__c retrieveDataPackageObject(String dataPackId, Integer execOrder){
        System.debug('Enter retrieveDataPackageObject --> '+ dataPackID + ' - '+execOrder);
        
        //DataPack Package and Object
        DataPackObject__c dataPackInfo = new DataPackObject__c();
        try{
            dataPackInfo = [SELECT Package__r.Name,Package__c,ObjectName__c, BatchSize__c,PurgeQueryConditional__c,ExecutionOrder__c
                            FROM DataPackObject__c
                            WHERE Package__c= :dataPackID 
                            AND Package__r.Active__c = true 
                            AND PurgeActive__c = true 
                            AND ExecutionOrder__c =:execOrder
                            LIMIT 1
            ];
        } catch(QueryException e) {
            System.debug('Has no record found to data pack info. '+e.getMessage());
        }
        
        return dataPackInfo;
    }
    
    //Retrieve Replication Payload
    public static String retrieveQueryMetadata(Id dataPackageId) {
        DataPackage__c dataPackage = [SELECT Id, Active__c 
                                      FROM DataPackage__c 
                                      WHERE Id = :dataPackageId];

        
        if (!dataPackage.Active__c) {
            return 'This data package is inactive!';
        }
        
        List<DataPackObject__c> dataPackObjects = [
            SELECT Id, ObjectAPIName__c, ReplicationQueryConditional__c, BucketName__c, ExecutionOrder__c, Path__c, BatchSize__c
            FROM DataPackObject__c
            WHERE Package__c = :dataPackageId AND ReplicationActive__c = True
            ORDER BY ExecutionOrder__c
        ];

        List<ReplicationPayloadBuilder.ReplicationPayload> payloads = new List<ReplicationPayloadBuilder.ReplicationPayload>();
        List<DataPackObject__c> toUpdate = new List<DataPackObject__c>();

        for (DataPackObject__c dataPackObject : dataPackObjects) {
            ReplicationPayloadBuilder.ReplicationPayload payload = ReplicationPayloadBuilder.generateReplicationPayload(dataPackObject);
            String payloadJson = JSON.serialize(payload);
            dataPackObject.ReplicationPayload__c = payloadJson;
            toUpdate.add(dataPackObject);
            payloads.add(payload);
        }
        
        if (!toUpdate.isEmpty()) {
            update toUpdate; // DML operation in bulk
        }

        return JSON.serialize(payloads);
    }


    // Return Active execution data pack
    public static List<DataPackExecution__c> retrieveExecutionJobs(Id dataPackId){
        List<DataPackExecution__c> lstScheduleJob =      
            [SELECT Id, Name, PackageName__c, FinishDate__c, ResultDetail__c, StartDate__c, Status__c 
             FROM DataPackExecution__c
             WHERE PackageName__c=: dataPackID 
            ];
        
        return lstScheduleJob;      
    } 
    
    // Update the execution pack to purge conclusion based on package Id. 
    public static void updateExecutionPack(Id dataPackId, Boolean isPurge) {

        try{
            DataPackExecution__c dataPackExecution = [SELECT PurgeConcluded__c, ReplicationConcluded__c
                                                      FROM DataPackExecution__c
                                                      WHERE PackageName__c =: dataPackId
                                                      Limit 1];

            dataPackExecution.PurgeConcluded__c = isPurge ? true : false;
            dataPackExecution.ReplicationConcluded__c = isPurge ? false : true;
            update as user dataPackExecution;
        }
        catch(Exception e) {
            System.debug('Got error updating data pack execution: '+e.getMessage());
        }
    }

    // Retrieve the data pack execution that is open to execute based on package Id. 
    public static DataPackExecution__c retrieveOpenDataPackExecution(Id dataPackId) {
        
        // Return the list of data pack objects from the database. 
        DataPackExecution__c dataPackExecution = new DataPackExecution__c();
        try {
            dataPackExecution = [SELECT PurgeConcluded__c, ReplicationConcluded__c
                                 FROM DataPackExecution__c
                                 WHERE PackageName__c =: dataPackId
                                 AND Status__c =: 'Open'
                                 LIMIT 1];
        } catch(Exception e) {
            System.debug('Got error to found data pack execution. '+e.getMessage());
        }

        return dataPackExecution;
    }

    // Retrieve the data pack execution that is under execution based on package Id. 
    public static DataPackExecution__c retrieveInProgressDataPackExceution(Id dataPackId) {
        
        // Return the list of data pack objects from the database. 
        DataPackExecution__c dataPackExecution = new DataPackExecution__c();
        try {
            dataPackExecution = [SELECT Name, Status__c, PurgeConcluded__c, ReplicationConcluded__c, PackageName__c, StartDate__c
                                 FROM DataPackExecution__c
                                 WHERE PackageName__c =: dataPackId
                                 AND Status__c IN ('Full', 'Purge', 'Replication')
                                 LIMIT 1];
        } catch(Exception e) {
            System.debug('Got error to found data pack execution. '+e.getMessage());
        }

        return dataPackExecution;
    }

    // Validate if the package has enabled purge, data replication or both. 
    public static String validateDataPackageProcess(Id dataPackId) {

        // Return of result. 
        String result;

        // Retrieve data package objects to validate which were set to purge and replication process. 
        List<DataPackObject__c> dataPackObjects = new List<DataPackObject__c>();
        try{
            dataPackObjects = [SELECT PurgeActive__c, ReplicationActive__c
                               FROM DataPackObject__c
                               WHERE Package__c =: dataPackId];
        } 
        catch(Exception e){
            System.debug('Got error retrieving data pack objects. '+e.getMessage());
        }

        // Check which process were selected. 
        Boolean hasReplication = false;
        Boolean hasPurge = false;
        for(DataPackObject__c dpo: dataPackObjects) {
            if(dpo.PurgeActive__c) {
                hasPurge = dpo.PurgeActive__c;
            }
            if(dpo.ReplicationActive__c) {
                hasReplication = dpo.ReplicationActive__c;
            }
        }
        // Return the indication of full process. 
        if(hasPurge && hasReplication) {
            result = 'Full';
        } 
        else if(!hasPurge && hasReplication){
            result = 'Replication';
        }
        else if(hasPurge && !hasReplication){
            result = 'Purge';
        }

        return result;
    }

    // Update data pack execution based on object. 
    public static void updateDataPackExecution(DataPackExecution__c dataPackExecution) {

        try{
            update as user dataPackExecution;
        }
        catch(Exception e) {
            System.debug('Got error updating data pack execution: '+e.getMessage());
        }
    }

    // Retrieve the data package info based on it's Id. 
    public static DataPackage__c retrieveDataPackage(Id dataPackId) {

        // Return the data package from the database. 
        DataPackage__c dataPackage = new DataPackage__c();
        try {
            dataPackage = [SELECT Frequency__c
                           FROM DataPackage__c
                           WHERE Id =: dataPackId
                           LIMIT 1];
        } catch(Exception e) {
            System.debug('Got error to found data pack execution. '+e.getMessage());
        }

        return dataPackage;
    }
 
    // Create data pack execution based on object. 
    public static void createDataPackExecution(DataPackExecution__c dataPackExecution) {

        try{
            insert as user dataPackExecution;
        }
        catch(Exception e) {
            System.debug('Got error updating data pack execution: '+e.getMessage());
        }
    }
    
}