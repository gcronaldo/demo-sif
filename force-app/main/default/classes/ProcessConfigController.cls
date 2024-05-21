/*
 * Name: ProcessConfigController
 * Description: retrieve the setup configuration required to process in modal view. 
*/ 
public with sharing class ProcessConfigController {
    
    @AuraEnabled(cacheable=true)
    public static List<ProcessConfig__mdt> getProcessConfigs(String objectName){
        return [SELECT MasterLabel, DeveloperName, Object__c, Field__c, Action__c, Target__c, IconName__c
                FROM ProcessConfig__mdt
                WHERE Object__c =  :objectName
                WITH SECURITY_ENFORCED];
    }
}