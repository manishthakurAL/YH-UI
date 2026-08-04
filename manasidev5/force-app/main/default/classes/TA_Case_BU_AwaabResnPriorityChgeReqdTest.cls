@isTest
public with sharing class TA_Case_BU_AwaabResnPriorityChgeReqdTest {
    @testSetup
    static void setUpTestData(){

        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        TriggerBase.bypass('Case');
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName()); 
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact; 

        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        insert tenancy;

        Case caseAwaabsLaw = UthCase.buildAwaabsLawCase(contact.Id, tenancy.Id);
        caseAwaabsLaw.Priority = CaseDecorator.PRIORITY_SLIGHT;
        insert caseAwaabsLaw;

        caseAwaabsLaw.Status = CaseDecorator.CASE_STATUS_AWAAB_ACTION;
        caseAwaabsLaw.OrchardJobNumber__c = '123456';
        update caseAwaabsLaw;

       

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        TriggerBase.clearBypass('Case');
        MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName()); 
        
    }

	@isTest
    static void testReasonForPriorityChangeRequiredPositive(){
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        list<Case> caseList = UthCase.getAll();
        Case awaabsCase = caseList.get(0);
        Test.startTest();
        try{
            awaabsCase.Priority = CaseDecorator.PRIORITY_EMERGENCY;
            awaabsCase.PriorityChangeReason__c = CaseDecorator.REASONPRIORITYCHANGE_INACCURATE_INFORMATION_PROVIDED;
            update awaabsCase;
            caseList = UthCase.getAll();
            awaabsCase = caseList.get(0);
            Assert.areEqual(CaseDecorator.PRIORITY_EMERGENCY, awaabsCase.Priority);

        }catch(Exception e){
            Assert.isNull(e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testReasonForPriorityChangeRequiredNegative(){
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        list<Case> caseList = UthCase.getAll();
        Case awaabsCase = caseList.get(0);
        Test.startTest();
        try{
            awaabsCase.Priority = CaseDecorator.PRIORITY_EMERGENCY;
            update awaabsCase;
            caseList = UthCase.getAll();
            awaabsCase = caseList.get(0);

        }catch(Exception e){
            Assert.isNotNull(e.getMessage());
            Assert.isTrue(e.getMessage().contains(Label.AwaabReasonForPriorityRequired));

        }
        Test.stopTest();
    }
}