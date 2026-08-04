@isTest(seeAllData=false)
public with sharing class TA_Tenancy_RequireReasonEndDateCha_Test {

    public static Boolean errorThrown = false;

    @IsTest
    static void testRequireReasonForEndDateChange() {

        List<YH_Tenancy__c> newList = new List<YH_Tenancy__c>();
        List<YH_Tenancy__c> oldList = new List<YH_Tenancy__c>();

        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions(
                PropertyDecorator.AUTHORITY_BARNSLEY,
                PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE,
                PropertyDecorator.AUTHCODE_E08000038,
                PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
                PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE
        );
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        tenancy.TenancyEndDate__c = Date.newInstance(2024, 3, 17);
        insert tenancy;

        YH_Tenancy__c oldTenancy = tenancy.clone(true, true);
        oldTenancy.TenancyEndDate__c = Date.newInstance(2024, 3, 10);

        newList.add(tenancy);
        oldList.add(oldTenancy);

        Test.startTest();
        TA_Tenancy_BU_RequireReasonEndDateChange.beforeUpdate(newList, oldList);
        Test.stopTest();

        System.assertEquals(true, errorThrown, 'Error should have been thrown but was not');

    }

    @IsTest
    static void testSkipCheckWhenPropertyAttributesAreMissing() {

        List<YH_Tenancy__c> newList = new List<YH_Tenancy__c>();
        List<YH_Tenancy__c> oldList = new List<YH_Tenancy__c>();

        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
                PropertyDecorator.AUTHORITY_BARNSLEY,
                PropertyDecorator.AUTHCODE_E08000038,
                null);
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        tenancy.TenancyEndDate__c = Date.newInstance(2024, 3, 17);
        insert tenancy;

        YH_Tenancy__c oldTenancy = tenancy.clone(true, true);
        oldTenancy.TenancyEndDate__c = Date.newInstance(2024, 3, 10);

        newList.add(tenancy);
        oldList.add(oldTenancy);

        Test.startTest();
        TA_Tenancy_BU_RequireReasonEndDateChange.beforeUpdate(newList, oldList);
        Test.stopTest();

        System.assertEquals(false, errorThrown, 'Error should not have been thrown');
    }

    @IsTest
    static void testSkipCheckWhenNoDateChange() {

        List<YH_Tenancy__c> newList = new List<YH_Tenancy__c>();
        List<YH_Tenancy__c> oldList = new List<YH_Tenancy__c>();

        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions(
                PropertyDecorator.AUTHORITY_BARNSLEY,
                PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE,
                PropertyDecorator.AUTHCODE_E08000038,
                PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
                PropertyDecorator.PRODUCT_TYPE_MORTGAGE_RESCUE
        );
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        tenancy.TenancyEndDate__c = Date.newInstance(2024, 3, 17);
        insert tenancy;

        newList.add(tenancy);
        oldList.add(tenancy);

        Test.startTest();
        TA_Tenancy_BU_RequireReasonEndDateChange.beforeUpdate(newList, oldList);
        Test.stopTest();

        System.assertEquals(false, errorThrown, 'Error should not have been thrown');
    }
}