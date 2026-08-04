@isTest
public with sharing class TA_Case_BU_ValidateClosedAwaabCaseTest {
    
    @testSetup
    static void setUpTestData(){

        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        MetadataTriggerHandler.bypass(TA_Case_AU_TriggerCaseProcessObjectSync.class.getName()); 
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

        Entitlement awaabsStdEntitlement = UthEntitlement.buildAwaabsStandardEntitlement(account.Id);
        insert awaabsStdEntitlement;

        Case caseAwaabsLaw = UthCase.buildAwaabsLawCase(contact.Id, tenancy.Id, System.Now(), CaseDecorator.PRIORITY_SIGNIFICANT, awaabsStdEntitlement.Id);
        insert caseAwaabsLaw;
        List<CaseMilestone> milestoneList = UthCaseMilestone.getAllByCaseId(caseAwaabsLaw.Id);
        milestoneList[0].CompletionDate  = System.Now();
        update milestoneList;
        caseAwaabsLaw.Status = CaseDecorator.STATUS_PRE_CASE_CLOSURE;
        caseAwaabsLaw.ClosureReason__c = 'Test';
        update caseAwaabsLaw;

        caseAwaabsLaw.Status = CaseDecorator.STATUS_COMPLETE_CASE;
        update caseAwaabsLaw;

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName()); 
        MetadataTriggerHandler.clearBypass(TA_Case_AU_TriggerCaseProcessObjectSync.class.getName()); 
        
    }

	@isTest
    static void testClosedAwaabsLawCaseOrchardJobNumberEditable(){
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        list<Case> caseList = UthCase.getAll();
        Case awaabsCase = caseList.get(0);
        Test.startTest();

        awaabsCase.OrchardJobNumber__c = 'JOB123456';
        awaabsCase.FurtherWorksJobNumber__c = 'JOB123457';
        update awaabsCase;

        Test.stopTest();

        caseList = UthCase.getAll();

        System.Assert.areEqual('JOB123456', caseList[0].OrchardJobNumber__c);
        System.Assert.areEqual('JOB123457', caseList[0].FurtherWorksJobNumber__c);

    }

    @isTest
    static void testStopEditOnClosedAwaabsLawCaseExceptJobNumber(){
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        String expectedExceptionMessage = CaseDecorator.CASE_AWAABS_LAW_EDIT_ERROR_AFTER_CLOSURE;
        String actualExceptionMessage = '';
        list<Case> caseList = UthCase.getAll();
        Case awaabsCase = caseList.get(0);
        Test.startTest();

        try {

        awaabsCase.OrchardJobNumber__c = 'JOB123456';
        awaabsCase.description = 'JOB123456';
        update awaabsCase;
        } catch(Exception exp) {
            actualExceptionMessage = exp.getMessage();
        }

        Test.stopTest();

        System.Assert.areEqual(true, actualExceptionMessage.contains(expectedExceptionMessage),  'After Awaabs Case is closed only Orchard Job Number can be edited');
    }

	@isTest
    static void testAllowToChangeClosedDMCCaseCP(){
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        list<Case> caseList = UthCase.getAll();
        Case awaabsCase = caseList.get(0);

        System.runAs(new User(Id=UserInfo.getUserId())){
            Id dmcCaseUpdatePsId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_DMC_CASE_UPDATE).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(UserInfo.getUserId(), dmcCaseUpdatePsId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(UserInfo.getUserId(), dmcCaseUpdatePsId);
            }
        }
        System.runAs(new User(Id=UserInfo.getUserId())){
            Test.startTest();        
            awaabsCase.Priority = CaseDecorator.PRIORITY_EMERGENCY;
            awaabsCase.PriorityChangeReason__c = CaseDecorator.CASE_PRIORITY_CHANGE_REASSESSED;
            awaabsCase.ReasonforMilestoneBreach__c = CaseDecorator.CASE_MILESTONE_BREACH_CUSTOMER_AVAILABILITY;
            awaabsCase.DateandTimeEmergencyWorkStarted__c = System.today();
            awaabsCase.DateReportSentToCustomer__c = System.today();
            awaabsCase.DateSafetyWorksCompleted__c = System.today();
            update awaabsCase;

            Test.stopTest();
        }

        caseList = UthCase.getAll();

        System.Assert.areEqual(CaseDecorator.PRIORITY_EMERGENCY, caseList[0].Priority);
        System.Assert.areEqual(CaseDecorator.CASE_PRIORITY_CHANGE_REASSESSED, caseList[0].PriorityChangeReason__c);
        System.Assert.areEqual(CaseDecorator.CASE_MILESTONE_BREACH_CUSTOMER_AVAILABILITY, caseList[0].ReasonforMilestoneBreach__c);
        System.Assert.areEqual(System.today(), caseList[0].DateandTimeEmergencyWorkStarted__c);
        System.Assert.areEqual(System.today(), caseList[0].DateReportSentToCustomer__c);
    }

	@isTest
    static void testAllowToChangeClosedDMCCaseCPOtherFields(){
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        list<Case> caseList = UthCase.getAll();
        Case awaabsCase = caseList.get(0);
        String actualExceptionMessage = '';

        System.runAs(new User(Id=UserInfo.getUserId())){
            Id dmcCaseUpdatePsId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_DMC_CASE_UPDATE).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(UserInfo.getUserId(), dmcCaseUpdatePsId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(UserInfo.getUserId(), dmcCaseUpdatePsId);
            }
        }
        System.runAs(new User(Id=UserInfo.getUserId())){
            Test.startTest();        
            try{
                awaabsCase.Priority = CaseDecorator.PRIORITY_EMERGENCY;
                update awaabsCase;
            } catch(Exception exp) {
                actualExceptionMessage = exp.getMessage();
            }
            Test.stopTest();

            System.Assert.areEqual(true, actualExceptionMessage.contains(CaseDecorator.CASE_AWAABS_LAW_EDIT_ERROR_AFTER_CLOSURE_TL),  'Closed Awaabs case Should not be allowed to Edit');
        }
    }

	@isTest
    static void testAllowToChangeClosedDMCCaseCPMilestoneCheck(){
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        list<Case> caseList = UthCase.getAll();
        Case awaabsCase = caseList.get(0);
        List<CaseMilestone> milestoneList = UthCaseMilestone.getAllByCaseId(awaabsCase.Id);

        System.runAs(new User(Id=UserInfo.getUserId())){
            Id dmcCaseUpdatePsId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_DMC_CASE_UPDATE).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(UserInfo.getUserId(), dmcCaseUpdatePsId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(UserInfo.getUserId(), dmcCaseUpdatePsId);
            }
        }
        System.runAs(new User(Id=UserInfo.getUserId())){
            Test.startTest();        
            awaabsCase.Priority = CaseDecorator.PRIORITY_EMERGENCY;
            awaabsCase.PriorityChangeReason__c = CaseDecorator.CASE_PRIORITY_CHANGE_REASSESSED;
            awaabsCase.ReasonforMilestoneBreach__c = CaseDecorator.CASE_MILESTONE_BREACH_CUSTOMER_AVAILABILITY;
            awaabsCase.DateandTimeEmergencyWorkStarted__c = System.today();
            awaabsCase.DateReportSentToCustomer__c = System.today();
            update awaabsCase;

            Test.stopTest();
        }

        List<CaseMilestone> milestoneListRequeried = UthCaseMilestone.getAllByCaseId(awaabsCase.Id);
        
        System.Assert.areEqual(milestoneList.size(), milestoneListRequeried.size());
        System.Assert.areEqual(milestoneList[0].TargetDate, milestoneListRequeried[0].TargetDate);
      
    }


}