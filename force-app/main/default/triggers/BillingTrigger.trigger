trigger BillingTrigger on Billing__c (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        BillingHandler.populateBillingName(Trigger.new);
    }
}
