@isTest
public with sharing class AutoCloseEmailCaseTypeBatchTest {
    @TestSetup
    static void setup(){
        OrgSetting__c orgSetting = OrgSetting__c.getOrgDefaults();
        orgSetting.DaysAutoCloseEmailCaseType__c  = -10;
        upsert orgSetting;
        UthFeatureSwitches.enableEmailResponseRT();
        TriggerBase.bypass('Account');
        Account account1 = UthAccount.buildPersonAccount();
        insert account1;
        Id acontactId = UthContact.getAll()[0].Id;
        List<Case> cases = new List<Case>();
        TriggerBase.bypass('Case');
        for(Integer i=0 ; i <5 ; i++){
            cases.add(UthCase.buildEmailResponseCase(acontactId));
        }
        insert cases;
        TriggerBase.clearBypass('Case');
        TriggerBase.clearBypass('Account');
    }




    @isTest
    static void testExecuteAutoCloseBatchUserRole(){

        OrgSetting__c setting = OrgSetting__c.getOrgDefaults();
        Id currentUserId = UserInfo.getUserId();
        Id currentUserIdNonAdmin;
        Group cecqueue = UthQueue.getQueue(CaseDecorator.CUSTOMER_EXPERIENCE_QUEUE);
        System.runAs(new User(Id = currentUserId)){
            currentUserIdNonAdmin = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.Bypass_CP_Case_TF_BIU_SETAWAITINGINFORMATIONCHANGEDATETIME).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, createPermissionSetId);

            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet( currentUserId, createPermissionSetId);
            }
        }
        System.runAs((new User(Id = currentUserId))){
            Test.startTest();
            TriggerBase.bypass('Case');
            List<Case> cases = new List<Case>();
            for(Integer i=0 ; i <5 ; i++){
                Case acase = UthCase.getAll()[i];
                acase.Status = CaseDecorator.STATUS_AWAITING_INFORMATION;
                acase.AwaitingInformationDateTime__c = Datetime.newInstance(2024, 4, 30,8,0,0);
                acase.OwnerId = currentUserIdNonAdmin;
                cases.add(acase);
            }
            update cases;
            TriggerBase.clearBypass('Case');
            List<Id> recordTypeIds = new List<Id>{
                CaseDecorator.RECORD_TYPE_ID_EMAILRESPONSE, CaseDecorator.RECORD_TYPE_ID_GENERAL_ENQUIRY 
            };
            AutoCloseEmailCaseTypeBatch abatch = new AutoCloseEmailCaseTypeBatch(recordTypeIds, (Integer)setting.DaysAutoCloseEmailCaseType__c, 5);
            abatch.chatterImpl = new MockChatterPoster();
            abatch.startDate = Date.newInstance(2024, 5, 15);
            Database.executeBatch(abatch);
            Test.stopTest();
        }
        Assert.areEqual(CaseDecorator.STATUS_STAGE_CLOSED, UthCase.getAll()[0].Status);
    }  
    @isTest
    static void testExecuteAutoCloseBatchNonCECUser(){

        OrgSetting__c setting = OrgSetting__c.getOrgDefaults();
        Id currentUserId = UserInfo.getUserId();
        Group cecqueue = UthQueue.getQueue(CaseDecorator.CUSTOMER_EXPERIENCE_QUEUE);
        System.runAs((new User(Id = currentUserId))){
            Test.startTest();
            TriggerBase.bypass('Case');
            List<Case> cases = new List<Case>();
            for(Integer i=0 ; i <5 ; i++){
                Case acase = UthCase.getAll()[i];
                acase.Status = CaseDecorator.STATUS_AWAITING_INFORMATION;
                acase.AwaitingInformationDateTime__c = Datetime.newInstance(2024, 4, 30,8,0,0);
                acase.OwnerId = cecqueue.Id;
                cases.add(acase);
            }
            update cases;
            TriggerBase.clearBypass('Case');
            List<Id> recordTypeIds = new List<Id>{
                CaseDecorator.RECORD_TYPE_ID_EMAILRESPONSE, CaseDecorator.RECORD_TYPE_ID_GENERAL_ENQUIRY 
            };
            AutoCloseEmailCaseTypeBatch abatch = new AutoCloseEmailCaseTypeBatch(recordTypeIds, (Integer)setting.DaysAutoCloseEmailCaseType__c, 5);
            abatch.chatterImpl = new MockChatterPoster();
            abatch.startDate = Date.newInstance(2024, 5, 15);
            Database.executeBatch(abatch);
            Test.stopTest();
        }
        Assert.areNotEqual(CaseDecorator.STATUS_STAGE_CLOSED, UthCase.getAll()[0].Status);
    }  

    


    @isTest
    static void testExecuteAutoCloseBatchError(){
        OrgSetting__c setting = OrgSetting__c.getOrgDefaults();
        YH_Property__c aproperty = uthProperty.buildPropertyWithDesignAssumptions(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE,
            PropertyDecorator.AUTHCODE_E08000038,
            PropertyDecorator.RENT_TYPE_SOCIAL_RENT,
            PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE
            );
        insert aproperty;

        YH_Tenancy__c tenancy = UthTenancy.build(aproperty.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        tenancy.StartDate__c = System.today().addYears(-2);
        tenancy.TenancyEndDate__c = System.today().addMonths(-1);
        insert tenancy;
        Case caseRec = UthCase.buildTerminationCase(UthContact.getAll()[0].Id, UthTenancy.getAll()[0].Id);
        Date terminationNoticeReceivedDatePlus7Days = System.today() + 7;
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
       
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        DateTime startDateTime = businessHourService.getNextBusinessDay(Date.today(),null);
        DateTime targetDateTime = businessHourService.calculateTargetDate((Integer)setting.DaysAutoCloseEmailCaseType__c, startDateTime);
        Test.startTest();
        TriggerBase.bypass('Case');
        caseRec.Status = CaseDecorator.STATUS_AWAITING_INFORMATION;
        caseRec.AwaitingInformationDateTime__c = targetDateTime;
        insert caseRec; 
        MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
       
        TriggerBase.clearBypass('Case');
        
        List<Id> recordTypeIds = new List<Id>{
            CaseDecorator.RECORD_TYPE_ID_TERMINATION
        };
        AutoCloseEmailCaseTypeBatch abatch = new AutoCloseEmailCaseTypeBatch(recordTypeIds, (Integer)setting.DaysAutoCloseEmailCaseType__c, 5);
        abatch.chatterImpl = new MockChatterPoster();
        Database.executeBatch(abatch);
        Test.stopTest();
        Assert.areNotEqual(CaseDecorator.STATUS_STAGE_CLOSED, UthCase.getAll()[0].Status);
    }  
    
    private class MockChatterPoster implements ChatterInterface { 
        public ConnectApi.BatchResult[] postToChatterFeedBatchResults(Id subjectId, List<String> messages) {  
           return new List<ConnectApi.BatchResult>();
        }  
    }
}