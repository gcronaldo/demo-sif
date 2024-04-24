/*
 * Name: DataloadOppQuoteQLI
 * Description: Parse the values from stage to standard objects creating opp, quote and qli.
*/ 
public with sharing class DataloadOppQuoteQLI implements Database.Batchable<Integer> {
    
    private Integer quantity;
    
    public DataloadOppQuoteQLI(Integer quantity) {
        Cache.Org.put('DataloadScript', quantity);
        this.quantity = quantity;
    }

    public Iterable<Integer> start(Database.BatchableContext context) {
        List<Integer> numbers = new List<Integer>();
        for (Integer i = 0; i < Math.min(quantity, 2000); i++) {
            numbers.add(i);
        }
        return numbers;
    }

    public void execute(Database.BatchableContext context, List<Integer> scope) {

        List<QuoteStaging__c> quotesStaging = [SELECT Name, Account__c, Stage__c, CloseDate__c
                                               FROM QuoteStaging__c    
                                               LIMIT :scope.size()];

        List<Opportunity> opportunities = new List<Opportunity>();
        List<String> quotesStagingIds = new List<String>();
        for(QuoteStaging__c qs : quotesStaging) {
            Opportunity opp = new Opportunity();
            opp.AccountId = qs.Account__c;
            opp.CloseDate = qs.CloseDate__c;
            String opportunityName = qs.Name;
            opportunityName = opportunityName.replace('Quote', 'Opportunity');
            opp.Name = qs.Name;
            opp.StageName = qs.Stage__c;
            quotesStagingIds.add(qs.Id);
            opportunities.add(opp);
        }
        insert opportunities;

        List<Quote> quotes = new List<Quote>();
        for(Opportunity opp : opportunities) {
            for(QuoteStaging__c qs : quotesStaging){
                if(opp.AccountId == qs.Account__c ){
                    Quote quote = new Quote();
                    quote.Name = qs.Name;
                    quote.OpportunityId = opp.Id;
                    quote.ExternalID__c = qs.Id;
                    quotes.add(quote);
                }
            }
        }
        insert quotes;

        List<QuoteLineItem> quoteLinesItems = new List<QuoteLineItem>();
        List<QuoteDetailStaging__c> quotesDetails = [SELECT PriceBookID__c, ProductID__c, Quantity__c, Quote_Staging__c, UnitPrice__c
                                                     FROM QuoteDetailStaging__c
                                                     WHERE Quote_Staging__c in :quotesStagingIds];
        for(Quote quote: quotes){
            for(QuoteDetailStaging__c qds: quotesDetails) {
                if(qds.Quote_Staging__c == quote.ExternalID__c){
                    QuoteLineItem qli = new QuoteLineItem();
                    qli.Quantity = qds.Quantity__c;
                    qli.UnitPrice = qds.UnitPrice__c;
                    qli.QuoteId = quote.Id;
                    qli.Product2Id = qds.ProductID__c;
                    qli.PricebookEntryId = qds.PriceBookID__c;
                    quoteLinesItems.add(qli);
                }
            }
        }
        insert quoteLinesItems;

        delete quotesStaging;

        Integer cacheQuantity = (Integer)Cache.Org.get('DataloadScript');
        cacheQuantity = cacheQuantity - scope.size();
        Cache.Org.put('DataloadScript', cacheQuantity);
    }

    public void finish(Database.BatchableContext context) {
        Integer currentQuantity = (Integer)Cache.Org.get('DataloadScript');
        if (currentQuantity < quantity && currentQuantity != 0) {
            DataloadOppQuoteQLI nextBatch = new DataloadOppQuoteQLI(currentQuantity);
            Database.executeBatch(nextBatch);
        } else {
            System.debug('Batch execution completed.');
        }
    }
}