/*
 * Name: DataPackController
 * Description: Controller for DataPack components. 
 */  
public class DataPackController {

    // Expose the execution call to flow and IPs. 
    @invocableMethod(label='Execute Data Pack Process' description='Execute the data pack process through flow passing execution process Id, enable the process to call the purge and replication process.')
    public static List<Id> executeDataPackProcess(List<Id> dataPackIds) {
        System.debug('Enter executeDataPackProcess');

        if(dataPackIds.size() > 0){
            System.debug('Retrieved id --> '+dataPackIds[0]);
            purgeData(dataPackIds[0]);
        }
        else {
            System.debug('No records found!');
        }

        return dataPackIds;
    }
    

    public static void purgeData(String dataPackID){

        //Define Execution Order
        Integer execOrder =1;
        
        //Call Data Package and DataPack Objects
        DataPackObject__c dataPack = DataPackDAO.retrieveDataPackageObject(dataPackID, execOrder);

        //Check if list is empty
        //Get package and first object from package
        if (dataPack.Package__c == null){
            System.debug('Expected at least one Package for execution');            
        } else{
            String jobName = 'JOB_'+dataPack.Package__r.Name+'_'+dataPack.ObjectName__c;
            purgeDataBatch job = new purgeDataBatch(jobName,dataPack.PurgeQueryConditional__c,Integer.valueOf(dataPack.ExecutionOrder__c),Integer.valueOf(dataPack.BatchSize__c),dataPack.Package__c);
            Database.executeBatch(job, Integer.valueOf(dataPack.BatchSize__c));
        }
    }  
}