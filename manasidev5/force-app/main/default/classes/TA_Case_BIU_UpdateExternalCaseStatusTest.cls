@isTest
public with sharing class TA_Case_BIU_UpdateExternalCaseStatusTest {
    @testSetup
    static void setUpTestData(){
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        TriggerBase.bypass('Case');

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact;

        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
        PropertyDecorator.RENT_TYPE_SOCIAL_RENT,
        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
        insert property;

        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10; 
        insert atenancy;
        
        Case caseRec = UthCase.buildTerminationCase(contact.Id, atenancy.Id);
        caseRec.CaseType__c = CaseDecorator.TYPE_TERMINATION;
        
        insert caseRec;

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        TriggerBase.clearBypass('Case');

    }
    @isTest
    static void testCaseStatusUpdateForInsert(){
        List<Contact> contactsList = UthContact.getAll();
        Test.startTest();
        Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
        insert caseRecord;
        Test.stopTest();
        Case acase = UthCase.get(caseRecord.Id);
        Assert.areEqual(acase.ExternalCaseStatus__c,CaseDecorator.EXTERNAL_STATUS_INPROGRESS,'Case External Status should be In Progress for Initial Contact');
    }
    
   
    @isTest
    static void testCaseStatusUpdateForUpdate(){
        
        List<Contact> contactList = UthContact.getAll();
        Case caseRec = UthCase.getAll()[0];
        
        MetadataTriggerHandler.Bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.Bypass(TA_Termination_BU_CheckPermission.class.getName());
        MetadataTriggerHandler.Bypass(TA_InspectionCheck_BU_CheckPermission.class.getName());
        MetadataTriggerHandler.Bypass(TA_TerminationAmmend_BU_CheckPermission.class.getName()); 
        
        caseRec.TerminationNoticeReceived__c = System.today();
        caseRec.Status = CaseDecorator.STATUS_COMPLETE_CASE;
        caseRec.IsFullConsentForTerminationNotGive__c = true;
        caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_CONSENT_NOT_GIVE;
        update caseRec;
        MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.clearBypass(TA_Termination_BU_CheckPermission.class.getName());
        MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BU_CheckPermission.class.getName());
        MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BU_CheckPermission.class.getName()); 
        
        Case acase = UthCase.get(caseRec.Id);
        Assert.areEqual(acase.ExternalCaseStatus__c,CaseDecorator.EXTERNAL_STATUS_CLOSED,'Case External Status should be Closed');

    }

}