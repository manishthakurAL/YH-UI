@isTest
public with sharing class UthMutualExchange {
    public static YH_Mutual_Exchange__c buildInternalProperty(Id caseId, String swapNumber, Id propertyId){
        return new YH_Mutual_Exchange__c(
            Case__c = caseId,
            PropertyType__c = MutualExchangeDecorator.PROPERTY_TYPE_INTERNAL,
            SwapNumber__c = swapNumber,
            InternalProperty__c = propertyId
        );
    }

    public static YH_Mutual_Exchange__c buildInternalPropertyWithSwapExchange(Id caseId, Id mexSwap, Id propertyId, string mutualExchangeType){
        return new YH_Mutual_Exchange__c(
            Case__c = caseId,
            PropertyType__c = MutualExchangeDecorator.PROPERTY_TYPE_INTERNAL,
            ExchangeSwapNumber__c = mexSwap,
            InternalProperty__c = propertyId,
            MutualExchangeType__c = mutualExchangeType
        );
    }

    public static YH_Mutual_Exchange__c buildExternalProperty(Id caseId, String swapNumber){ 
        return new YH_Mutual_Exchange__c(
            Case__c = caseId,
            PropertyType__c = MutualExchangeDecorator.PROPERTY_TYPE_EXTERNAL,
            SwapNumber__c = swapNumber,
            ExternalAddress2__Street__s = 'Test Street',
            ExternalAddress2__City__s = 'Test City',
            ExternalAddress2__PostalCode__s = 'PostalCode',
            ExternalAddress2__CountryCode__s = 'GB',
            ExternalLandlord__c = 'Test Landlord'
        );
    }

    
    public static List<YH_Mutual_Exchange__c> getAll(){
        return Database.query('SELECT '+
            String.join(new List<String>(YH_Mutual_Exchange__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
            ' FROM YH_Mutual_Exchange__c ' + 
            ' ORDER BY Id'
        );
    }

    public static List<YH_Mutual_Exchange__c> getAllExternalPropertyType(){
        return Database.query('SELECT '+
            String.join(new List<String>(YH_Mutual_Exchange__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
            ' FROM YH_Mutual_Exchange__c ' + 
            ' WHERE PropertyType__c = \'' + MutualExchangeDecorator.PROPERTY_TYPE_EXTERNAL + '\'' +
            ' ORDER BY Id'
        );
    }

    public static List<YH_Mutual_Exchange__c> getAllInternalPropertyType(){
        return [SELECT Id,ExchangeSwapNumber__c FROM YH_Mutual_Exchange__c WHERE PropertyType__c =: MutualExchangeDecorator.PROPERTY_TYPE_INTERNAL AND InternalProperty__r.YH_RentType__c =: PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT limit 1];
    }
}