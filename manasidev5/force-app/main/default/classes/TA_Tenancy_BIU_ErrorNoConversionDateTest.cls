@isTest
private class TA_Tenancy_BIU_ErrorNoConversionDateTest {

    @isTest
    static void testErrorWhenStarterTenancyHasNoConversionDateOnUpdate() {
        Boolean errorThrown = false;
        String errorMessage;
    
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.AUTHCODE_E08000038,
            null
        );
        insert property;
    
        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, null);
        tenancy.YH_AgreementType__c = TenancyDecorator.TENANCY_AGREEMENT_TYPE_ASSURED;
        tenancy.ConversionDate__c = null;
        insert tenancy;

        Test.startTest();
        try {
            tenancy.YH_AgreementType__c = TenancyDecorator.TENANCY_AGREEMENT_TYPE_STARTER;
            update tenancy;
        } catch (DmlException e) {
            errorThrown = true;
            errorMessage = e.getDmlMessage(0); 
        }
        Test.stopTest();
    
        System.assertEquals(true, errorThrown, 'Expected validation error was not thrown on update');
        System.assertEquals(TA_Tenancy_BIU_AddErrorNoConversionDate.ERROR_MESSAGE, errorMessage, 'Incorrect error thrown');
    }
    

    @isTest
    static void testErrorWhenStarterTenancyHasNoConversionDateOnInsert() {
        Boolean errorThrown = false;
        String errorMessage;

        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.AUTHCODE_E08000038,
            null
        );
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, null);
        tenancy.YH_AgreementType__c = TenancyDecorator.TENANCY_AGREEMENT_TYPE_STARTER;
        tenancy.ConversionDate__c = null;

        Test.startTest();
        try {
            insert tenancy;
        } catch (DmlException e) {
            errorThrown = true;
            errorMessage = e.getDmlMessage(0); 
        }
        Test.stopTest();

        System.assertEquals(true, errorThrown, 'Expected validation error was not thrown on insert');
        System.assertEquals(TA_Tenancy_BIU_AddErrorNoConversionDate.ERROR_MESSAGE, errorMessage, 'Incorrect error thrown');
    }

    @isTest
    static void testNoErrorWhenConversionDateIsPresent() {
        Boolean errorThrown = false;

        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.AUTHCODE_E08000038,
            null
        );
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, null);
        tenancy.YH_AgreementType__c = TenancyDecorator.TENANCY_AGREEMENT_TYPE_STARTER;
        tenancy.ConversionDate__c = Date.today();
        insert tenancy;

        Test.startTest();
        try {
            tenancy.RentBalance__c = 75;
            update tenancy;
        } catch (DmlException e) {
            errorThrown = true;
        }
        Test.stopTest();

        System.assertEquals(false, errorThrown, 'No validation error should be thrown when Conversion Date is present');
        System.assertEquals(75, UthTenancy.getTenancyById(tenancy.Id).RentBalance__c);
    }

    @isTest
    static void testNoErrorForNonStarterTenancy() {
        Boolean errorThrown = false;

        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.AUTHCODE_E08000038,
            null
        );
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, null);
        tenancy.YH_AgreementType__c = TenancyDecorator.TENANCY_AGREEMENT_TYPE_ASSURED;
        tenancy.ConversionDate__c = null; 
        insert tenancy;

        Test.startTest();
        try {
            tenancy.RentBalance__c = 100;
            update tenancy;
        } catch (DmlException e) {
            errorThrown = true;
        }
        Test.stopTest();

        System.assertEquals(false, errorThrown, 'No error should be thrown for non-Starter Tenancy');
        System.assertEquals(100, UthTenancy.getTenancyById(tenancy.Id).RentBalance__c);
    }
}