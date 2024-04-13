/*
 * Name: DataPackSetupController
 * Description: Handle the DML operations from DataPackSetup components to Salesforce. 
 */ 
public with sharing class DataPackSetupController {
    
    // Parse and sabe the data package, pack objects and pack execution. 
    @AuraEnabled
    public static void saveDataPackRecords(String dataPackJson){

        // Parse the input data. 
        DataPackWrapper dataPack = (DataPackWrapper) JSON.deserialize(dataPackJson, DataPackWrapper.class);
        System.debug('packData --> '+dataPack.packData);

        // Prepare and create pack data.
        DataPackage__c dp = new DataPackage__c();
        dp.Active__c = true;
        String[] scheduleParts = dataPack.packData.schedule.split(':');
        Integer hour = Integer.valueOf(scheduleParts[0]);
        Integer minute = Integer.valueOf(scheduleParts[1]);
        Integer second = Integer.valueOf(scheduleParts[2]);
        dp.Schedule__c = Time.newInstance(hour, minute, second, 0);
        dp.Name = dataPack.packData.packName;
        dp.Frequency__c = dataPack.packData.frequency;

        try{
            insert as user dp;
        } catch(Exception e) {
            System.debug('Got error dp --> '+e);
        }
        
        // Prepare objects data. 
        List<ObjectData> objects = dataPack.objects;
        List<DataPackObject__c> dataPackObjects = new List<DataPackObject__c>();
        for (ObjectData objectData : objects) {
            DataPackObject__c dpo = new DataPackObject__c();
            SYstem.debug('objectData  ---> '+objectData);
            dpo.Name = objectData.objectName;
            dpo.ObjectAPIName__c = objectData.objectName;
            dpo.ObjectName__c = objectData.objectName;
            dpo.ReplicationActive__c = objectData.replicationSelected;
            dpo.PurgeActive__c = objectData.purgeSelected;
            dpo.ExecutionOrder__c = Integer.valueOf(objectData.executionOrder);
            dpo.ReplicationQueryConditional__c = objectData.queryConditional;
            dpo.BucketName__c = objectData.bucketName;
            dpo.LoadScreenSize__c = String.isBlank(objectData.screenSizeLoad) ? 0 : Integer.valueOf(objectData.screenSizeLoad);
            dpo.Path__c = objectData.path;
            dpo.BatchSize__c = String.isBlank(objectData.batchSize) ? 0 : Integer.valueOf(objectData.batchSize);
            dpo.PurgeQueryConditional__c = objectData.queryConditionalPurge;
            dpo.Package__c = dp.Id;
            dataPackObjects.add(dpo);
        }

        try {
            insert as user dataPackObjects;
        } catch(Exception e) {
            System.debug('Got error dataPackObjects --> '+e);
        }

        // Prepare pack execution. 
        DataPackExecution__c dpe = new DataPackExecution__c();
        dpe.Name = dp.Name;
        dpe.PackageName__c = dp.Id;
        // Provisory date only for test proposal. This should be removed further. 
        DateTime dt = ScheduleSetupDatatime.createScheduleDatetime(dp.Schedule__c, dp.Frequency__c);
        DateTime decreasedDateTime = dt.addDays(-1);
        dpe.StartDate__c = decreasedDateTime;

        try {
            insert as user dpe;
        } catch(Exception e) {
            System.debug('Got error dpe --> '+e);
        }
    }

    // Wrapper class for JSON data
    public class DataPackWrapper {
        @AuraEnabled public DataPackData packData;
        @AuraEnabled public List<ObjectData> objects;
    }
    
    // Inner class for pack data
    public class DataPackData {
        @AuraEnabled public String packName;
        @AuraEnabled public Boolean packageActive;
        @AuraEnabled public String frequency;
        @AuraEnabled public String schedule;
    }
    
    // Inner class for object data
    public class ObjectData {
        @AuraEnabled public String objectName;
        @AuraEnabled public Boolean replicationSelected;
        @AuraEnabled public Boolean purgeSelected;
        @AuraEnabled public String executionOrder;
        @AuraEnabled public String queryConditional;
        @AuraEnabled public String bucketName;
        @AuraEnabled public String screenSizeLoad;
        @AuraEnabled public String path;
        @AuraEnabled public String batchSize;
        @AuraEnabled public String queryConditionalPurge;
    }
}