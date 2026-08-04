public with sharing class UthPriceBookEntry {
    public static  PricebookEntry  create (Id pricebookId, Id productId) {      
        
        Id stdPbId = Test.getStandardPricebookId(); 
        PricebookEntry stdPbe = new PricebookEntry(
            Pricebook2Id = stdPbId,
            Product2Id   = productId,
            UnitPrice    = 100.00,
            IsActive     = true
        );
        insert stdPbe;

        PricebookEntry customPbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = productId,
            UnitPrice = 95.00, // discounted in custom PB
            IsActive = true,
            UseStandardPrice = false
        );
        insert customPbe;
        return customPbe;
    }

     public static List<PricebookEntry> getAll(){
        return Database.query('SELECT '+
            String.join(new List<String>(PricebookEntry.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
                        //add more feilds from related object as and wehn required
            ' FROM PricebookEntry WHERE Pricebook2.IsStandard = FALSE  '
        );
    }
}