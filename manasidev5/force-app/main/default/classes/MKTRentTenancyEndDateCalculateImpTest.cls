@isTest
public with sharing class MKTRentTenancyEndDateCalculateImpTest {
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
        PropertyDecorator.RENT_TYPE_MARKET_RENT,
        PropertyDecorator.PRODUCT_TYPE_MARKETRENTAL);
        insert property;
    }

    @isTest
    static void testCalculateMarketRentDateFeb() {
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        insert atenancy;
        atenancy = UthTenancy.getAll()[0];
        Test.startTest();
            MarketRentTenancyEndDateCalculateImpl rentTenImpl = new MarketRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = rentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,2,3));
        Test.stopTest();
       
        Assert.areEqual(date.newInstance(2025,4,3), calculatedEndDate, 'Market rent calculated End Date date is incorrect.');
    }

    @isTest
    static void testCalculateMarketRentDateMarch() {
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        insert atenancy;
        atenancy = UthTenancy.getAll()[0];
        Test.startTest();
            MarketRentTenancyEndDateCalculateImpl rentTenImpl = new MarketRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = rentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,3,4));
        Test.stopTest();
       
        Assert.areEqual(date.newInstance(2025,5,4), calculatedEndDate, 'Market rent calculated End Date date is incorrect.');
    }

    @isTest
    static void testCalculateMarketRentDateApril() {
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        insert atenancy;
        atenancy = UthTenancy.getAll()[0];
        Test.startTest();
            MarketRentTenancyEndDateCalculateImpl rentTenImpl = new MarketRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = rentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,4,2));
        Test.stopTest();
       
        Assert.areEqual(date.newInstance(2025,6,2), calculatedEndDate, 'Market rent calculated End Date date is incorrect.');
    }
    
    @isTest
    static void testCalculateMarketRentDateTuesday() {
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        insert atenancy;
        atenancy = UthTenancy.getAll()[0];
        Test.startTest();
        MarketRentTenancyEndDateCalculateImpl rentTenImpl = new MarketRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = rentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,2,4));
        Test.stopTest();
       
        Assert.areEqual(date.newInstance(2025,4,4), calculatedEndDate, 'Market rent calculated End Date date is incorrect.');
    }

    @isTest
    static void testCalculateMarketRentDateSunday() {
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        insert atenancy;
        atenancy = UthTenancy.getAll()[0];
        Test.startTest();
            MarketRentTenancyEndDateCalculateImpl rentTenImpl = new MarketRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = rentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,2,2));
        Test.stopTest();
       
        Assert.areEqual(date.newInstance(2025,4,2), calculatedEndDate, 'Market rent calculated End Date date is incorrect.');
    }
}