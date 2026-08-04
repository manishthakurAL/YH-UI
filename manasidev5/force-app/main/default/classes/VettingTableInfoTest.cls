@isTest
public with sharing class VettingTableInfoTest {
    @TestSetup
    static void makeData(){
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        TriggerBase.bypass('Case');
        Account account = UthAccount.build();
        insert account;


        Contact contact = UthContact.build(account.Id);
        insert contact;

        YH_Property__c aproperty = uthProperty.buildPropertyWithDesignAssumptions(
        PropertyDecorator.AUTHORITY_BARNSLEY,
        PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE,
        PropertyDecorator.AUTHCODE_E08000038,
        PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
        PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE
        );
        insert aproperty;

        YH_Tenancy__c atenancy = UthTenancy.build(aproperty.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        insert atenancy;

        Case caseRecord = UthCase.buildComplaintCase(contact.Id);
        caseRecord.StageOneEscalatedDate__c = System.now().addDays(-1);
        caseRecord.StageTwoEscalatedDate__c = System.now().addDays(-1);
        caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
        caseRecord.Tenancy__c = atenancy.Id;
        insert caseRecord;
        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        TriggerBase.clearBypass('Case');
    }

    @isTest
    static void getVettingSupportInfoTest(){
        Id caseId = [SELECT Id FROM CASE].Id;
        Id propertyId = [SELECT Id FROM YH_Property__c].Id;
        Id contactId = [SELECT Id  FROM Contact].Id;
        YH_Application__c application  = UthApplication.buildApplication(caseId, propertyId);
        insert application;
        Applicant__c aapplicant = UthApplicant.buildApplicant(contactId, application.Id);
        insert aapplicant;
        Vetting__c avetting = UthVetting.buildVetting(application.Id, aapplicant.Id);
        insert avetting;
        List<VettingSupportingInfo__c> vettingSupportInfos = new List<VettingSupportingInfo__c>();
        for(Integer i = 0; i <= 2; i++){
            vettingSupportInfos.add(UthVettingSupportInformation.buildVettingSupportInfo(avetting.Id));
        }
        insert vettingSupportInfos;
        Test.startTest();
            List<VettingInfoDataTable.VettingSupportInfoWrapper> vettingSupportInfo = VettingInfoDataTable.getVettingSupportInfo(aapplicant.Id);
        Test.stopTest();
        Assert.isNotNull(vettingSupportInfo, 'Vetting supporting Info not populated correctly');
    }

    @isTest
    static void getVettingIdTest(){
        Id caseId = [SELECT Id FROM CASE].Id;
        Id propertyId = [SELECT Id FROM YH_Property__c].Id;
        Id contactId = [SELECT Id  FROM Contact].Id;
        YH_Application__c application  = UthApplication.buildApplication(caseId, propertyId);
        insert application;
        Applicant__c aapplicant = UthApplicant.buildApplicant(contactId, application.Id);
        insert aapplicant;
        Vetting__c avetting = UthVetting.buildVetting(application.Id, aapplicant.Id);
        insert avetting;
       
        Test.startTest();
            Id vettingId   = VettingInfoDataTable.getVettingId(aapplicant.Id);
        Test.stopTest();
        Assert.isNotNull(vettingId, 'Vetting Id should be returned correctly');
    }


}