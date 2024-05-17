/*
 * Name: RelatedAccountsController
 * Description: retrieve the accounts related to the same contacts on current account. 
*/ 
public with sharing class RelatedAccountsController {

    @AuraEnabled(cacheable=true)
    public static List<AccountContactRelation> getRelatedAccounts(String accountId) {
        System.debug('Enter method ---< '+accountId);

        List<String> contactIds = new List<String>();
        for(Contact c: [SELECT Id 
                        FROM Contact 
                        WHERE AccountId =: accountId
                        WITH SECURITY_ENFORCED]){
            contactIds.add(c.Id);
        }
        system.debug('->> '+contactIds);

        List<AccountContactRelation> relatedAccounts = [SELECT AccountId, Account.Name, ContactId, Roles 
                                                        FROM AccountContactRelation 
                                                        WHERE ContactId IN: contactIds
                                                        AND AccountId !=: accountId
                                                        WITH SECURITY_ENFORCED];

        system.debug('----> '+relatedAccounts);
        return relatedAccounts;
    }
}