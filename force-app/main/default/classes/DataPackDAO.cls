public class DataPackDAO {
    
    //Return DataPack and DataPackObjects
    public static DataPackObject__c retrieveDataPackageObject(String dataPackID, Integer execOrder){
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
        
        System.debug('Return of list ------> '+dataPackInfo);
        return dataPackInfo;
    }
    
    //Retrieve Replication Payload
    public static String retrieveQueryMetadata(Id dataPackageId) {
        DataPackage__c dataPackage = [SELECT Id, Active__c FROM DataPackage__c WHERE Id = :dataPackageId];
        
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


    //Return Active scheduleJobs
    public static List<DataPackExecution__c> retrieveExecutionJobs(ID dataPackID){
        List<DataPackExecution__c> lstScheduleJob =      
            [SELECT Id, Name, PackageName__c, FinishDate__c, ResultDetail__c, StartDate__c, Status__c 
             FROM DataPackExecution__c
             WHERE PackageName__c=: dataPackID 
            ];
        
        return lstScheduleJob;      
    }    
    
}