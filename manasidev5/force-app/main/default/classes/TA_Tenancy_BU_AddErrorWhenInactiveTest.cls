@isTest
private class TA_Tenancy_BU_AddErrorWhenInactiveTest {

    @isTest
    static void testUpdatingWhenInactive() {

        Boolean errorThrown = false;
        String errorMessage;

        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
                PropertyDecorator.AUTHORITY_BARNSLEY,
                PropertyDecorator.AUTHCODE_E08000038,
                null);
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, false, null);
        insert tenancy;

        Test.startTest();
        try {
            tenancy.RentBalance__c = 1;
            update tenancy;
        } catch (DmlException e) {
            errorThrown = true;
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, errorThrown, 'Error should have been added');
        System.assertEquals(true, errorMessage.contains(TA_Tenancy_BU_AddErrorWhenInactive.ERROR_MESSAGE), 'Error message is not correct');
    }

    @isTest
    static void testUpdatingWhenActive() {

        Boolean errorThrown = false;

        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
                PropertyDecorator.AUTHORITY_BARNSLEY,
                PropertyDecorator.AUTHCODE_E08000038,
                null);
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, null);
        insert tenancy;

        Test.startTest();
        try {
            tenancy.RentBalance__c = 1; 
            update tenancy;
        } catch (DmlException e) {
            errorThrown = true;
        }
        Test.stopTest();

        System.assertEquals(false, errorThrown, 'An exception was thrown trying to update the tenancy');
        System.assertEquals(1, UthTenancy.getTenancyById(tenancy.Id).RentBalance__c);
    }
}