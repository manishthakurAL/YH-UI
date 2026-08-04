@isTest
public with sharing class GarageRentTenancyEndDateCalculateImpTest {
    @TestSetup
    static void makeData(){
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact; 

        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.NON_RESEDENTIAL_STOCK, 'E08000035', 
        PropertyDecorator.GARAGE_RENT,
        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
        insert property;
    }

    @isTest
    static void testCalculateDateFeb(){
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        Test.startTest();
            GarageRentTenancyEndDateCalculateImpl garageRentTenImpl = new GarageRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = garageRentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,2,3));
        Test.stopTest();
       
        Assert.areEqual(calculatedEndDate, date.newInstance(2025,2,9));
    }

    @isTest
    static void testCalculateDateMarch(){
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        Test.startTest();
            GarageRentTenancyEndDateCalculateImpl garageRentTenImpl = new GarageRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = garageRentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,3,10));
        Test.stopTest();
       
        Assert.areEqual(calculatedEndDate, date.newInstance(2025,3,16));
    }

    @isTest
    static void testCalculateDateApril(){
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        Test.startTest();
            GarageRentTenancyEndDateCalculateImpl garageRentTenImpl = new GarageRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = garageRentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,4,14));
        Test.stopTest();
       
        Assert.areEqual(calculatedEndDate, date.newInstance(2025,4,20));
    }

    @isTest
    static void testCalculateDateAprilSunday(){
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        Test.startTest();
            GarageRentTenancyEndDateCalculateImpl garageRentTenImpl = new GarageRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = garageRentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,4,6));
        Test.stopTest();
       
        Assert.areEqual(calculatedEndDate, date.newInstance(2025,4,13));
    }
}