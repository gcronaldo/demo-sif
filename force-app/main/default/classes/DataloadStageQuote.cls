/*
 * Name: DataloadStageQuote
 * Description: create mass data to be inserted on a stage quote custom object.  
*/ 
public with sharing class DataloadStageQuote implements Database.Batchable<Integer> {
    
    private Integer quantity;

    public DataloadStageQuote(Integer quantity) {
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

        List<QuoteStaging__c> quotesStaging  = new List<QuoteStaging__c>();
        List<Account> accounts = [SELECT Id FROM Account LIMIT 50000];
        Integer countedRecords = 0;
        for (Integer i : scope) {
            QuoteStaging__c qs = new QuoteStaging__c();
            qs.Name = 'Pseudo Quote ' + i;
            qs.Account__c = accounts.get(countedRecords).Id;
            qs.Stage__c = 'Needs Analysis';
            qs.CloseDate__c = System.today();
            quotesStaging.add(qs);
            countedRecords += 1;
        }

        insert quotesStaging;

        List<QuoteDetailStaging__c> quotesDetails = new List<QuoteDetailStaging__c>();
        for(QuoteStaging__c qs : quotesStaging) {
            QuoteDetailStaging__c qds = new QuoteDetailStaging__c();
            qds.PriceBookID__c = '01uam000000DyFKAA0';
            qds.ProductID__c = '01tam000000bfecAAA';
            qds.Quantity__c = 1;
            qds.Quote_Staging__c = qs.Id;
            qds.UnitPrice__c = 0.0;
            quotesDetails.add(qds);
        }

        insert quotesDetails;

        Integer cacheQuantity = (Integer)Cache.Org.get('DataloadScript');
        cacheQuantity = cacheQuantity - scope.size();
        Cache.Org.put('DataloadScript', cacheQuantity);
    }

    public void finish(Database.BatchableContext context) {
        Integer currentQuantity = (Integer)Cache.Org.get('DataloadScript');
        if (currentQuantity < quantity && currentQuantity != 0) {
            DataloadStageQuote nextBatch = new DataloadStageQuote(currentQuantity);
            Database.executeBatch(nextBatch);
        } else {
            System.debug('Batch execution completed.');
        }
    }
}