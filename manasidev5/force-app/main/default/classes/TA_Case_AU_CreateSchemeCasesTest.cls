@isTest(seeAllData=false)
public with sharing class TA_Case_AU_CreateSchemeCasesTest {
    @testSetup
    static void setUpTestData(){

        Id currentUserId = UserInfo.getUserId();
        System.runAs(new User(Id = currentUserId)) {
            UthFeatureSwitches.enableCaseLettingRT();
            UthFeatureSwitches.enableCaseSchemesRT();
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            TriggerBase.bypass('Account');
            TriggerBase.bypass('Case');
            TriggerBase.bypass('YH_Property__c');
            TriggerBase.bypass('YH_Tenancy__c');
            TriggerBase.bypass('Member__c');
            TriggerBase.bypass('YH_Application__c');
            TriggerBase.bypass('Applicant__c');
            TriggerBase.bypass('Vetting__c');

            Account customrAccount = UthAccount.buildPersonAccount();
            insert customrAccount;

            Account account = UthAccount.build();
            insert account;

            Contact contact = UthContact.build(account.Id);
            insert contact;
            
            List<Account> customerPA = UthAccount.getAllPersonAccount();

            YH_Property__c property = UthProperty.buildHousingPurposeProperty(
                'Leeds',
                'E08000035',
                PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
            );
            insert property;

            YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
            insert tenancy;

            Member__c member = UthMember.build(customerPA[0].PersonContactId, tenancy.Id, MemberDecorator.TYPE_SOLO);
            insert member;

            Case caseRecord = UthCase.buildLettingsCase(customerPA[0].PersonContactId, customerPA[0].Id, tenancy.Id);
            insert caseRecord;

            YH_Application__c application = UthApplication.buildApplication(caseRecord.Id, property.Id, ApplicationDecorator.STARTER_TENANCY, System.now().addDays(1).date(), 'Yes', 'Yes', ApplicationDecorator.MAILING_ADDRESS_UPDATE_ADDRESS_NOT_PROPERTY_ADDRESS);
            insert application;

            Applicant__c applicant = UthApplicant.buildApplicant(UthContact.getAll()[0].Id, application.Id);
            insert applicant;

            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('Case');
            TriggerBase.clearBypass('YH_Property__c');
            TriggerBase.clearBypass('YH_Tenancy__c');
            TriggerBase.clearBypass('Member__c');
            TriggerBase.clearBypass('YH_Application__c');
            TriggerBase.clearBypass('Applicant__c');
            TriggerBase.clearBypass('Vetting__c');
        }
    }

    @isTest
    static void testMonitoringFromCase_Success(){
        Id createLettingPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_LETTINGS_CASE_CREATE).Id;
        Id updateLettingPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_LETTINGS_CASE_UPDATE).Id;
        Id currentUserId = UserInfo.getUserId();
        UthPermissionAssigner.assignPermissionSet(currentUserId, createLettingPermissionSetId);
        UthPermissionAssigner.assignPermissionSet(currentUserId, updateLettingPermissionSetId);
        
        List<Case> lettingCase  = UthCase.getAll();
        Assert.areEqual(1,lettingCase.size(),'Only one Letting Case should exist');

        Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                
                lettingCase[0].Status = CaseDecorator.STATUS_COMPLETE_CASE;
                lettingCase[0].CaseOutcome__c = CaseDecorator.CASE_OUTCOME_RESOLVED;
                update lettingCase;
            }
        Test.stopTest();

        List<Case> resultCase  = UthCase.getAll();
        Assert.areEqual(3,resultCase.size(),'One letting case and one monitoring form case should exist');

        Case mfCase;
        Case ipCase;
        for(Case c : UthCase.getAll()){
            if(c.CaseType__c == CaseDecorator.TYPE_MONITORING_FORM){
                mfCase = c;
            } else if(c.CaseType__c == CaseDecorator.TYPE_INDEPENDENCE_PLAN){
                ipCase = c;
            }
        }

        Assert.areNotEqual(null, mfCase);
        Assert.areNotEqual(null, mfCase.Property__c);
        Assert.areNotEqual(null, mfCase.Tenancy__c);
        Assert.areNotEqual(null, ipCase);
        Assert.areNotEqual(null, ipCase.Property__c);
        Assert.areNotEqual(null, ipCase.Tenancy__c);
    }
}