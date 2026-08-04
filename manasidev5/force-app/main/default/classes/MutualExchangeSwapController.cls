public with sharing class MutualExchangeSwapController {
    
    @AuraEnabled(cacheable=true)
    public static SObject[] getMutualExchange(String recordId) {
        return [
            SELECT Id, Name, PropertyType__c, ExchangeSwapId__c, InternalProperty__c, 
                   InternalPropertyAddress__c,ExchangeAddress__c, ExternalAddress2__c,
                   ExternalLandlord__c, ExchangeSwapNumber__c, ExchangeSwapNumber__r.Name,
                   ExchangeSwapNumber__r.PropertyType__c, ExchangeSwapNumber__r.InternalPropertyAddress__c,
                   ExchangeSwapNumber__r.ExternalAddress2__c,
                   (SELECT RelatedContact__r.Name FROM MutualExchangeApplicants__r)
            FROM YH_Mutual_Exchange__c
            WHERE Case__c =: recordId
            ORDER BY PropertyType__c ASC
        ];
    } 

    @AuraEnabled
    public static void saveNewMapping(String data) {
        try{
            YH_Mutual_Exchange__c[] mappings = (YH_Mutual_Exchange__c[]) JSON.deserialize(data, YH_Mutual_Exchange__c[].class);
            update mappings;
        }catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage()  );
        }   
    }

}