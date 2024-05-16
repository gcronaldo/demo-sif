/*
 * Name: DataloadQuoteQLI
 * Description: Parse the values from Quote and QLI (Quote Line Item) stage objects to the standard one in a batch process.   
*/ 
public with sharing class DataloadQuoteQLI implements Database.Batchable<sObject> {
    
    public Database.Querylocator start(Database.BatchableContext BC){
        // retrive the records from the stage object.
        return Database.getQueryLocator([SELECT Id, Name, Account__c, Stage__c, CloseDate__c, SourceExternalKey__c
                                         FROM QuoteStaging__c]);
                                         //WHERE CreatedDate = LAST_N_DAYS:7]);
    }
    

    public void execute(Database.BatchableContext BC, List<QuoteStaging__c> scope){
        
        List<opportunity> opportunities = new List<Opportunity>();
        List<quote> quotes = new List<Quote>();
        Set<Id> quoteIds = new Set<Id>();
        for(QuoteStaging__c qs : scope) {

            // Prepare opp info. 
            Opportunity opp = new Opportunity();
            opp.Name = qs.Name;
            opp.AccountId = qs.Account__c;
            opp.CloseDate = qs.CloseDate__c;
            opp.StageName = qs.Stage__c;
            opp.External_ID__c = qs.SourceExternalKey__c;

            opportunities.add(opp);

            // Prepare quote info. 
            Quote quote = new Quote();
            quote.Name = qs.Name;
            Opportunity oppRef = new Opportunity(External_ID__c = qs.SourceExternalKey__c);
            quote.Opportunity = oppRef;
            quote.SourceSystemIdentifier__c = qs.SourceExternalKey__c;
            quotes.add(quote);

            quoteIds.add(qs.Id);
        }

        // Upsert the info based on external key fields. 
        upsert opportunities External_ID__c;
        upsert quotes SourceSystemIdentifier__c;

        // Retrieve and process the quote line items. 
        List<QuoteDetailStaging__c> qliStages = [SELECT Quote_Staging__c, 
                                                        Quantity__c, 
                                                        UnitPrice__c, 
                                                        ProductID__c, 
                                                        PriceBookID__c, 
                                                        SourceExternalKey__c,
                                                        Quote_Staging__r.SourceExternalKey__c
                                                 FROM QuoteDetailStaging__c
                                                 WHERE Quote_Staging__c in :quoteIds];
        List<QuoteLineItem> qlis = new List<QuoteLineItem>();
        for(QuoteDetailStaging__c qds: qliStages) {
            QuoteLineItem qli = new QuoteLineItem();
            qli.Quantity = qds.Quantity__c;
            qli.UnitPrice = qds.UnitPrice__c;
            Quote quoteRef = new Quote(SourceSystemIdentifier__c=qds.Quote_Staging__r.SourceExternalKey__c);
            qli.Quote = quoteRef;
            qli.Product2Id = qds.ProductID__c;
            qli.PricebookEntryId = qds.PriceBookID__c;
            qli.SourceExternalKey__c = qds.SourceExternalKey__c;

            qlis.add(qli);
        }

        upsert qlis SourceExternalKey__c;

        delete scope;
    }

    public void finish(Database.BatchableContext context) {
        NotifyUserServiceComplete.notifyUser('Data load quote and quote line items');
    }
}