public with sharing class TA_Tenancy_BIU_AddErrorNoConversionDate implements TriggerAction.BeforeUpdate, TriggerAction.BeforeInsert {

    @TestVisible
    public static final String ERROR_MESSAGE = 'Conversion Date is Mandatory for starter tenancy';

    public static void beforeUpdate(List<YH_Tenancy__c> newList, List<YH_Tenancy__c> oldList) {
        validateTenancies(newList);
    }

    public static void beforeInsert(List<YH_Tenancy__c> newList) {
        validateTenancies(newList);
    }

    private static void validateTenancies(List<YH_Tenancy__c> tenancies) {
        for (YH_Tenancy__c tenancy : tenancies) {
            if (tenancy.YH_AgreementType__c == TenancyDecorator.TENANCY_AGREEMENT_TYPE_STARTER &&
                tenancy.ConversionDate__c == null) {
                tenancy.ConversionDate__c.addError(ERROR_MESSAGE);
            }
        }
    }
}