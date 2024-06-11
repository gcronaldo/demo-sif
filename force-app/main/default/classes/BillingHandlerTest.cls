@isTest
public class BillingHandlerTest {

    @testSetup
    static void setup() {
        // Creating test data that will be used in the test methods
        List<Billing__c> billings = new List<Billing__c>();

        billings.add(new Billing__c(Name = 'Invoice1', BillingDate__c = Date.newInstance(2024, 5, 24)));
        billings.add(new Billing__c(Name = 'Invoice2', BillingDate__c = Date.newInstance(2024, 12, 15)));

        insert billings;
    }

    @isTest
    static void testPopulateBillingName() {
        // Query the records that were inserted in the test setup
        List<Billing__c> newBillings = [SELECT Id, Name, BillingDate__c FROM Billing__c];

        // Validate the populated Name fields
        System.assertEquals('5-Invoice1', newBillings[0].Name, 'The Name field should be populated with "May-Invoice1"');
        System.assertEquals('12-Invoice2', newBillings[1].Name, 'The Name field should be populated with "December-Invoice2"');
    }

    @isTest
    static void testTrigger() {
        // Create a new Billing record to trigger the before insert logic
        Billing__c newBilling = new Billing__c(Name = 'Invoice3', BillingDate__c = Date.newInstance(2024, 6, 1));
        insert newBilling;

        // Query the inserted Billing record to validate the populated Name field
        Billing__c insertedBilling = [SELECT Id, Name, BillingDate__c FROM Billing__c WHERE Id = :newBilling.Id LIMIT 1];
        System.assertEquals('6-Invoice3', insertedBilling.Name, 'The Name field should be populated with "June-Invoice3"');
    }
}
