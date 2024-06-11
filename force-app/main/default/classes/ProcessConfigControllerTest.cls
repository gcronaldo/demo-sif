@isTest
public class ProcessConfigControllerTest {

@isTest
    static void testGetProcessConfigs() {
        Test.startTest();
        List<ProcessConfig__mdt> configs = ProcessConfigController.getProcessConfigs('Account');
        Test.stopTest();
        
        System.assertEquals(configs.size(), 2, 'Number of records should be 3');
    }
}