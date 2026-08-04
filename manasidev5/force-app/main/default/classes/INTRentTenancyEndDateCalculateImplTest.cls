@isTest
public with sharing class INTRentTenancyEndDateCalculateImplTest {

    @TestSetup
    static void makeData(){
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact; 

        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
        PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
        PropertyDecorator.RENT_TYPE_RENTTOBUY);
        insert property;
    }

    @isTest
    static void testCalculateIntermediateRentDateFeb(){
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        Test.startTest();
            INTRentTenancyEndDateCalculateImpl rentTenImpl = new INTRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = rentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,2,3));
        Test.stopTest();
       
        Assert.areEqual(date.newInstance(2025,3,2), calculatedEndDate, 'Intermediate rent calculated End Date date is incorrect.');
    }

    @isTest
    static void testCalculateIntermediateRentDateTues(){
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        Test.startTest();
        INTRentTenancyEndDateCalculateImpl rentTenImpl = new INTRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = rentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,2,4));
        Test.stopTest();
       
        Assert.areEqual(date.newInstance(2025,3,3), calculatedEndDate, 'Intermediate rent calculated End Date date is incorrect.');
    }

    @isTest
    static void testCalculateIntermediateRentDateMarch(){
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        Test.startTest();
            INTRentTenancyEndDateCalculateImpl rentTenImpl = new INTRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = rentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,3,4));
        Test.stopTest();
       
        Assert.areEqual(date.newInstance(2025,3,31), calculatedEndDate, 'Intermediate rent calculated End Date date is incorrect.');
    }

    @isTest
    static void testCalculateIntermediateRentDateApril(){
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        Test.startTest();
            INTRentTenancyEndDateCalculateImpl rentTenImpl = new INTRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = rentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,4,2));
        Test.stopTest();
       
        Assert.areEqual(date.newInstance(2025,4,29), calculatedEndDate, 'Intermediate rent calculated End Date date is incorrect.');
    }

    @isTest
    static void testCalculateIntermediateRentDateSunday(){
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        Test.startTest();
            INTRentTenancyEndDateCalculateImpl rentTenImpl = new INTRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = rentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,2,2));
        Test.stopTest();
       
        Assert.areEqual(date.newInstance(2025,3,1), calculatedEndDate, 'Intermediate rent calculated End Date date is incorrect.');
    }
}