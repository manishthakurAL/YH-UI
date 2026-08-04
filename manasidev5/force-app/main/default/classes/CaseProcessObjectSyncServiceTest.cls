@isTest
public class CaseProcessObjectSyncServiceTest {
    
    @TestSetup
    static void makeData(){
        UthFeatureSwitches.enableAllRT();
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        Account account = UthAccount.build();
        insert account;
        
        
        Contact contact = UthContact.build(account.Id);
        insert contact;

        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
                PropertyDecorator.AUTHORITY_BARNSLEY,
                PropertyDecorator.AUTHCODE_E08000038,
                null);
        insert property; 

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, false, null);
        insert tenancy;
        
        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        
    }
    
    @isTest
    static void testUpdateCaseStatusCopiedToProcess_Success(){
        
        String statusExpected = CaseDecorator.STATUS_IN_PROGRESS;
        String statusActual;
        Contact contact = UthContact.getAll().get(0);
        
        System.runAs(getMoneyCoachingUser()) {
            Case caseRecord = UthCase.buildMoneyCoachingCase(contact.Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_HIGH;
            caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_MONEY_COACHING;
            insert caseRecord;
            
            Test.startTest();
            
            caseRecord.Status = CaseDecorator.STATUS_IN_PROGRESS;
            update caseRecord;
            
            Test.stopTest();
            
            Triage__c triageRecord = UthTriage.getAll().get(0);
            statusActual = triageRecord.caseStatus__c;
            
        }
        
        
        Integer size = UthCase.getAll().size();
        Assert.areEqual(statusExpected, statusActual, 'Status must be copied to Triage Record');
    }

    @isTest
    static void testUpdateCaseStatusCopiedToProcessTermination_Success(){
        Id userId = UserInfo.getUserId();
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());

        UthFeatureSwitches.enableCaseTerminationRT(); 
        UthFeatureSwitches.enableCaseLettingRT();
        TriggerBase.bypass('Account');
        Account account1 = UthAccount.buildPersonAccount();
        insert account1;
        TriggerBase.clearBypass('Account');    
        
        YH_Property__c aproperty = uthProperty.buildPropertyWithDesignAssumptions(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE,
            PropertyDecorator.AUTHCODE_E08000038,
            PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
            PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE
            );
        insert aproperty;

        YH_Tenancy__c tenancy = UthTenancy.build(aproperty.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        insert tenancy;
        
        String statusExpected = CaseDecorator.STATUS_ADMINISTRATION;
        String statusActual;
        Contact contact = UthContact.getAll().get(0);
        
        System.runAs(new User(Id = userId)) {
            List<Case> cases = new List<Case>();
            for(Integer i = 0; i < 10;i++){
                Case caseRecord = UthCase.buildTerminationCase(contact.Id, tenancy.Id);
                cases.add(caseRecord);
            }
            insert cases;
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());

            MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Termination_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_InspectionCheck_BU_CheckPermission.class.getName());
            Test.startTest();
            for(Case acase: cases){
                acase.Status = CaseDecorator.STATUS_ADMINISTRATION;
            }
            update cases;
            MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Termination_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BU_CheckPermission.class.getName());
            Test.stopTest();            
        }
        
      

        for(Termination__c terminationrec: UthTermination.getAll()){
            statusActual = terminationrec.caseStatus__c;
            Assert.areEqual(statusExpected, statusActual, 'Status must be copied to Triage Record');
        }
    }
    
    @isTest
    static void testUpdateTenancyCaseStatusCopiedToProcess_Success(){
        
        String statusExpected = CaseDecorator.STATUS_IN_PROGRESS;
        String triageStatusActual;
        String socialStatusActual;
        Contact contact = UthContact.getAll().get(0);
        
        System.runAs(getTenancyCoachingUser()) {
            Case caseRecord = UthCase.buildTenancyCoachingCase(contact.Id);
            insert caseRecord;
            
            Test.startTest();
            
            caseRecord.Status = CaseDecorator.STATUS_IN_PROGRESS;
            update caseRecord;
            
            Test.stopTest();
            
            Triage__c triageRecord = UthTriage.getAll().get(0);
            triageStatusActual = triageRecord.caseStatus__c;
            
            SocialValue__c socialRecord = UthSocialValue.getAll().get(0);
            socialStatusActual = socialRecord.caseStatus__c;
        }
        
        Assert.areEqual(statusExpected, triageStatusActual, 'Status must be copied to Triage Record');
        Assert.areEqual(statusExpected, socialStatusActual, 'Status must be copied to SocialValue Record');
    }

    @isTest
    static void testManagedMoveCaseStatusCopiedToProcess_Success(){
        
        String actualErrorMessage;
        Case caseRecord;
        
        System.runAs(UthUser.getSchemeUserForManagedMove(UserInfo.getUserId())) {

            caseRecord = UthCase.buildManagedMoveCaseWithTenancyAndReporter(UthContact.getAll()[0].Id, UthTenancy.getAll()[0].Id, UthContact.getAll()[0].Id);
            caseRecord.SubStatus__c = 'New';
            insert caseRecord;
            
            Test.startTest();
                try {
                    caseRecord.SubStatus__c = 'Awaiting Customer Reply';
                    update caseRecord;
                } 
                catch(Exception exp) {
                        actualErrorMessage = exp.getMessage();
                }
            Test.stopTest();
        }
        
        ManagedMove__c managedMoveRecord = [SELECT Id, CaseStatus__c, CaseSubStatus__c From ManagedMove__c];

        Assert.areEqual(managedMoveRecord.CaseStatus__c, caseRecord.Status, 'Status must be copied to ManagedMove Record');
        Assert.areEqual(managedMoveRecord.CaseSubStatus__c, caseRecord.SubStatus__c, 'Status must be copied to ManagedMove Record');
    }
    
    static User getMoneyCoachingUser() {
        Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MONEY_COACHING_CASE_CREATE).Id;
        Id updatePermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MONEY_COACHING_CASE_UPDATE).Id;
        Id currentUserId = UserInfo.getUserId();
        UthPermissionAssigner.assignPermissionSet(currentUserId, createPermissionSetId);
        UthPermissionAssigner.assignPermissionSet(currentUserId, updatePermissionSetId);
        return (new User(Id = currentUserId));
    }
    
    
    static User getTenancyCoachingUser() {
        Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_CREATE).Id;
        Id updatePermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_UPDATE).Id;
        Id currentUserId = UserInfo.getUserId();
        UthPermissionAssigner.assignPermissionSet(currentUserId, createPermissionSetId);
        UthPermissionAssigner.assignPermissionSet(currentUserId, updatePermissionSetId);
        return (new User(Id = currentUserId));
    }
    
}