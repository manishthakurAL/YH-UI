@isTest
public with sharing class SocialRentTenancyEndDateCalculateImpTest {
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
        PropertyDecorator.RENT_TYPE_SOCIAL_RENT,
        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
        insert property;
    }

    @isTest
    static void testCalculateDateFeb(){
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        Test.startTest();
            SocialRentTenancyEndDateCalculateImpl rentTenImpl = new SocialRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = rentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,2,3));
        Test.stopTest();
       
        Assert.areEqual(calculatedEndDate, date.newInstance(2025,3,2));
    }

    @isTest
    static void testCalculateDateTues(){
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        Test.startTest();
            SocialRentTenancyEndDateCalculateImpl rentTenImpl = new SocialRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = rentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,2,4));
        Test.stopTest();
       
        Assert.areEqual(calculatedEndDate, date.newInstance(2025,3,9));
    }

    @isTest
    static void testCalculateDateMarch(){
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        Test.startTest();
            SocialRentTenancyEndDateCalculateImpl rentTenImpl = new SocialRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = rentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,3,11));
        Test.stopTest();
       
        Assert.areEqual(calculatedEndDate, date.newInstance(2025,4,13));
    }

    @isTest
    static void testCalculateDateApril(){
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        Test.startTest();
            SocialRentTenancyEndDateCalculateImpl rentTenImpl = new SocialRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = rentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,4,14));
        Test.stopTest();
       
        Assert.areEqual(calculatedEndDate, date.newInstance(2025,5,11));
    }

    @isTest
    static void testCalculateDatSunday(){
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(UthProperty.getAll()[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        Test.startTest();
            SocialRentTenancyEndDateCalculateImpl rentTenImpl = new SocialRentTenancyEndDateCalculateImpl();
            Date calculatedEndDate  = rentTenImpl.calculateTenancyEndDate(atenancy, date.newInstance(2025,2,2));
        Test.stopTest();
       
        Assert.areEqual(calculatedEndDate, date.newInstance(2025,3,2));
    }
}