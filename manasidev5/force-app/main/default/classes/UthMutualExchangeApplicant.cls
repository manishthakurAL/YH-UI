@isTest
public with sharing class UthMutualExchangeApplicant {
    public static MutualExchangeApplicant__c build(Id RelatedMutualExchange, Id RelatedContact, String tenantType) {
        return new MutualExchangeApplicant__c(
            RelatedMutualExchange__c = RelatedMutualExchange,
            RelatedContact__c = RelatedContact,
            TenantType__c = tenantType
        );
    }
}