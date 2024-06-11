public class BillingHandler {

    public static void populateBillingName(List<Billing__c> newBillings) {
        for (Billing__c billing : newBillings) {
            if (billing.BillingDate__c != null && String.isNotBlank(billing.Name)) {
                String monthPrefix = String.valueOf(billing.BillingDate__c.month());
                billing.Name = monthPrefix + '-' + billing.Name;
            }
        }
    }
}
