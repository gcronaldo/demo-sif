/*
 * Name: DataPackController
 * Description: Controller for DataPack components. 
 */  
public class DataPackController {

    // Expose the execution call to flow and IPs. 
    @invocableMethod(label='Execute Data Pack Process' description='Execute the data pack process through flow passing execution process Id, enable the process to call the purge and replication process.')
    public static List<Id> executeDataPackProcess(List<Id> dataPackIds) {

        if(dataPackIds.size() > 0){
            System.debug('Retrieved id --> '+dataPackIds[0]);
            String typeProcess = setPackProcessStatus(dataPackIds[0]);
            if(typeProcess == 'Full') {
                purgeData(dataPackIds[0]);
            }
            else if(typeProcess == 'Purge'){
                purgeData(dataPackIds[0]);
            } 
            else {
                // Will call apex callout. 
            }  
        }
        else {
            System.debug('No records found!');
        }

        return dataPackIds;
    }
    
    // Execute the purge data process to the setup data pack objects. 
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

    // Check if the package execution is to apply a full or partion process. 
    public static String setPackProcessStatus(Id dataPackID){

        // Result. 
        Boolean result;

        // Retrieve the data pack execution to be updated. 
        DataPackExecution__c dpe = DataPackDAO.retrieveOpenDataPackExecution(dataPackID);
        
        // Get the type of process to update the status on data pack execution.  
        dpe.Status__c = DataPackDAO.validateDataPackageProcess(dataPackID);

        // Apply the changes to data pack execution
        DataPackDAO.updateDataPackExecution(dpe);

        return dpe.Status__c;
    }

    // Check the data pack type process closing the current one and scheduling the next one. 
    public static void concludePurgeProcess(Id dataPackID) {

        // Retrieve current data pack execution. 
        DataPackExecution__c dpe = DataPackDAO.retrieveInProgressDataPackExceution(dataPackID);

        // Check the type process execution to determine the update settings. 
        if(dpe.Status__c == 'Purge') {
            dpe.PurgeConcluded__c = true;
            dpe.Status__c = 'Success';
        }
        else {
            dpe.PurgeConcluded__c = true;
        }

        // Update the data pack execution. 
        DataPackDAO.updateDataPackExecution(dpe);

        // Create the next schedule execution. 
        createNextScheduleExecution(dpe);

    } 

    // Create next schedule execution. 
    public static void createNextScheduleExecution(DataPackExecution__c dataPackExecution) {

        // Prepare next schedule. 
        DataPackage__c dataPackage = DataPackDAO.retrieveDataPackage(dataPackExecution.PackageName__c);
        Time timeValue = Time.newInstance(dataPackExecution.StartDate__c.hour(), 
                                          dataPackExecution.StartDate__c.minute(), 
                                          dataPackExecution.StartDate__c.second(),
                                          0); 
        DataPackExecution__c dpe = new DataPackExecution__c();
        dpe.Name = dataPackExecution.Name;
        dpe.PackageName__c = dataPackExecution.PackageName__c;
        dpe.StartDate__c = ScheduleSetupDatatime.createScheduleDatetime(timeValue, dataPackage.Frequency__c);

        // Create next schedule. 
        DataPackDAO.createDataPackExecution(dpe);

    }

}