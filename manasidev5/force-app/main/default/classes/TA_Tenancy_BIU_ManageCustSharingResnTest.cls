@isTest
private class TA_Tenancy_BIU_ManageCustSharingResnTest {
    @isTest
    static void testShareReasonWhenInactive() {
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
                PropertyDecorator.AUTHORITY_BARNSLEY,
                PropertyDecorator.AUTHCODE_E08000038,
                null);
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, null);
        insert tenancy;

        Test.startTest();
            tenancy.Active__c = false;
            update tenancy;
        Test.stopTest();
        YH_Tenancy__c atenancy = UthTenancy.getAll()[0];
        Assert.isTrue(String.isBlank(atenancy.CustomerSharingReasons__c), 'Sharing reasons should be cleared when tenancy is deactivated');
    }

    @isTest
    static void testUpdatingWhenActive() {
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
                PropertyDecorator.AUTHORITY_BARNSLEY,
                PropertyDecorator.AUTHCODE_E08000038,
                null);
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, false, null);
        insert tenancy;

        Test.startTest();
            tenancy.Active__c = true; 
            update tenancy;
        Test.stopTest();
        Assert.areEqual(TenancyDecorator.CUSTOMER_SHARING_REASON_TENANCY, UthTenancy.getAll()[0].CustomerSharingReasons__c, 'Sharing reasons should be populated when tenancy is activated');

    } 

    @isTest
    static void testShareReasonWhenInactiveInsert() {
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
                PropertyDecorator.AUTHORITY_BARNSLEY,
                PropertyDecorator.AUTHCODE_E08000038,
                null);
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, false, null);

        Test.startTest();
            insert tenancy;
        Test.stopTest();
        YH_Tenancy__c atenancy = UthTenancy.getAll()[0];
        Assert.isTrue(String.isBlank(atenancy.CustomerSharingReasons__c), 'Sharing reasons should be cleared when  tenancy is deactivated');
    }

     @isTest
    static void testUpdatingWhenActiveInsert() {
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
                PropertyDecorator.AUTHORITY_BARNSLEY,
                PropertyDecorator.AUTHCODE_E08000038,
                null);
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, null);

        Test.startTest();
            insert tenancy;
        Test.stopTest();
        Assert.areEqual(TenancyDecorator.CUSTOMER_SHARING_REASON_TENANCY, UthTenancy.getAll()[0].CustomerSharingReasons__c, 'Sharing reasons should be populated when tenancy is activated');

    } 
}