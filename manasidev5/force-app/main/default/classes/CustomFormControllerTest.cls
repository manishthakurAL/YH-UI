@isTest(seeAllData=false)
public with sharing class CustomFormControllerTest {
    @testSetup
    static void setUpTestData(){

        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        TriggerBase.bypass('Case');
        TriggerBase.bypass('Triage__c');
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

        CaseRole__c aCaseRole = new CaseRole__c(
            Contact__c = contact.Id,
            Case__c = caseRecord.Id,
            Role__c	 = CaseRoleDecorator.CUSTOMER_ROLE 
        );
        insert aCaseRole;

        Triage__c triage = UthTriage.build(caseRecord.Id, contact.Id);
        insert triage;

        Member__c member = UthMember.build(contact.id, atenancy.id, MemberDecorator.TYPE_SOLO);
        insert member;

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        TriggerBase.clearBypass('Case');
        TriggerBase.clearBypass('Triage__c');
    }

    @isTest
    static void testCustomFormRender(){
        Test.startTest();
            List<CustomFormConfiguration__mdt> testFormConfig =
                (List<CustomFormConfiguration__mdt>) JSON.deserialize('[{ "ChildObjectAPIName__c":"Triage__c","FieldSetName__c":"MoneyCoachingInitialContactTriageInfo","ParentObjectAPIName__c":"Case", "ParentRelationshipAPIName__c":"Case__c"}]' 
                    ,List<CustomFormConfiguration__mdt>.class);
            CustomFormController.customFormConfig = testFormConfig;
            Id caseId = UthCase.getAll()[0].Id;
            List<CustomFormController.CustomForm> aCustomForms = CustomFormController.getFormDetails(caseId,'testMetadata');
        Test.stopTest();
        Assert.areEqual('Triage__c',aCustomForms[0].objectAPIName, 'Object name is incorrect');
        Assert.areEqual(UthTriage.getAll()[0].Id, aCustomForms[0].recordId, 'Record ID is not populated correctly');
    }

    @isTest 
    static void testParentOnChildAttribute(){
        Test.startTest();
        List<ParentFieldsOnChildDisplayDetail__mdt> testFormConfig =
            (List<ParentFieldsOnChildDisplayDetail__mdt>) JSON.deserialize('[{ "ParentObjectAPIName__c":"Contact","FieldSetName__c":"ApplicantContactFS","ParentRelationshipAPIName__c":"ContactId"}]' 
                ,List<ParentFieldsOnChildDisplayDetail__mdt>.class);
        CustomFormController.customFormParentConfig = testFormConfig;
        Id caseId = UthCase.getAll()[0].Id;
        List<CustomFormController.CustomForm> aCustomForms = CustomFormController.getParentDisplayConfigDetails(caseId,'testMetadata');
        Test.stopTest();
        Assert.areEqual(UthContact.getAll()[0].Id, aCustomForms[0].recordId, 'Record ID is not populated correctly');
    }
}