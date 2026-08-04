public with sharing class TA_Tenancy_BU_RequireReasonEndDateChange implements TriggerAction.BeforeUpdate{

    private static final String ERROR_MESSAGE = 'Please provide a reason for changing the end date';

    public static void beforeUpdate(List<YH_Tenancy__c> newList, List<YH_Tenancy__c> oldList) {
        Map<Id, YH_Tenancy__c> oldMap = new Map<Id, YH_Tenancy__c>(oldList);
        Set<Id> propertyIds = getPropertyIds(newList);
        Map<Id, YH_Property__c> propertyMap = new Map<Id, YH_Property__c>(getRelatedProperties(propertyIds));

        for (YH_Tenancy__c tenancy : newList) {
            if (tenancy.Property__c == null || String.isNotBlank(tenancy.ReasonTenancyEndDateChanged__c)) {
                continue;
            }
            YH_Tenancy__c oldRecord = oldMap.get(tenancy.Id);
            YH_Property__c property = propertyMap.get(tenancy.Property__c);
            if (tenancy.TenancyEndDate__c != oldRecord.TenancyEndDate__c && property != null) {

                if (
                        isHousingPurposeRequiringReason(property) &&
                        isRentTypeRequiringReason(property) &&
                        isProductTypeRequiringReason(property)) {
                    tenancy.ReasonTenancyEndDateChanged__c.addError(ERROR_MESSAGE);
                    if (Test.isRunningTest()) TA_Tenancy_RequireReasonEndDateCha_Test.errorThrown = true;
                }
            }
        }
    }

    static Set<Id> getPropertyIds(List<YH_Tenancy__c> newList) {
        Set<Id> propertyIds = new Set<Id>();
        for (YH_Tenancy__c tenancy : newList) {
            if (tenancy.Property__c != null) {
                propertyIds.add(tenancy.Property__c);
            }
        }
        return propertyIds;
    }

    static Boolean isHousingPurposeRequiringReason(YH_Property__c property) {
        return PropertyDecorator.LIST_HOUSING_PURPOSE_GENERAL_SUPPORTED_ELDERLY.contains(property.YH_HousingPurpose__c);
    }

    static Boolean isRentTypeRequiringReason(YH_Property__c property) {
        return PropertyDecorator.LIST_RENT_TYPE_INTERMEDIATE_SOCIAL_AFFORDABLE.contains(property.YH_RentType__c);
    }

    static Boolean isProductTypeRequiringReason(YH_Property__c property) {
        return PropertyDecorator.LIST_PRODUCT_TYPE_MORTGAGE_TRY_LOW_EXTRA.contains(property.YH_ProductType__c);
    }

    static List<YH_Property__c> getRelatedProperties(Set<Id> propertyIds) {
        return [SELECT Id, YH_HousingPurpose__c, YH_RentType__c, YH_ProductType__c
        FROM YH_Property__c
        WHERE Id IN :propertyIds];
    }
}