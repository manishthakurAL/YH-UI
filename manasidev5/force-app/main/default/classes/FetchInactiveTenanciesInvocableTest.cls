@isTest
public with sharing class FetchInactiveTenanciesInvocableTest {
    @TestSetup
    static void setUpTestData(){
        UthFeatureSwitches.enableCaseChangesRT();
        TriggerBase.bypass('Account');
        Account personAccount = UthAccount.buildPersonAccount('fNameOne', 'lNameOne');
        insert personAccount;
        Contact contactRecord = UthContact.getAll()[0];
        
        YH_Property__c property = uthProperty.buildPropertyWithAssetClass(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE,
            PropertyDecorator.AUTHCODE_E08000038,
            PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
            PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE,
            PropertyDecorator.FLAT_ASSET_CLASS
            );
        insert property;

        YH_Property__c garageProperty = uthProperty.buildPropertyWithAssetClass(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS,
            PropertyDecorator.AUTHCODE_E08000038,
            PropertyDecorator.GARAGE_RENT,
            PropertyDecorator.PRODUCT_TYPE_MARKETRENTAL,
            PropertyDecorator.GARAGE_PARKING_ASSET_CLASS
            );
        insert garageProperty;

        List<YH_Tenancy__c> tenancyList = new List<YH_Tenancy__c>();
        tenancyList.add(UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT));
        tenancyList.add(UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO));
        tenancyList.add(UthTenancy.build(garageProperty.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO));
        insert tenancyList;

        List<Member__c> memberList = new List<Member__c>();
        memberList.add(UthMember.buildWithOccupancyEndDate(contactRecord.Id, tenancyList[0].Id, MemberDecorator.TYPE_SOLO, System.today() - 4));
        memberList.add(UthMember.buildWithOccupancyEndDate(contactRecord.Id, tenancyList[1].Id, MemberDecorator.TYPE_SOLO, System.today() - 3));
        memberList.add(UthMember.buildWithOccupancyEndDate(contactRecord.Id, tenancyList[2].Id, MemberDecorator.TYPE_SOLO, System.today()));

        insert memberList;

        TriggerBase.clearBypass('Account');
    }

    @isTest
    static void fetctInactiveTenancyIdTest(){
        Test.startTest();
            List<FetchInactiveTenanciesInvocable.Request> requests  = new List<FetchInactiveTenanciesInvocable.Request>();
            FetchInactiveTenanciesInvocable.Request aRequest = new FetchInactiveTenanciesInvocable.Request();
            aRequest.contactId = UthContact.getAll()[0].Id;
            requests.add(aRequest);
            List<FetchInactiveTenanciesInvocable.Result> results = new List<FetchInactiveTenanciesInvocable.Result>();
            results = FetchInactiveTenanciesInvocable.fetchInactiveTenancies(requests);
            Assert.areEqual(UthTenancy.getAll()[1].Id,results[0].tenancyId);
        Test.stopTest();
    }
}