@isTest
public with sharing class AutoCloseTerminationCaseBatchTest {
    @TestSetup
    static void setup(){
        OrgSetting__c orgSetting = UthOrgSetting.buildSettingForAutoCaseCloseBatch();
        insert orgSetting;
        
        UthFeatureSwitches.enableCaseTerminationRT();
        
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Case');
        TriggerBase.bypass('YH_Tenancy__c');
        
        Account account1 = UthAccount.buildPersonAccount();
        insert account1;
        Id acontactId = UthContact.getAll()[0].Id;

        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
                PropertyDecorator.AUTHORITY_BARNSLEY,
                PropertyDecorator.AUTHCODE_E08000038,
                null);
        insert property; 

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, false, null);
        tenancy.TenancyEndDate__c = Date.newInstance(2025, 10, 21);

        insert tenancy;

        TriggerBase.clearBypass('Case');
        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('YH_Tenancy__c');
    }

    @isTest
    static void testExecuteAutoCloseBatchSuccess(){
        OrgSetting__c setting = OrgSetting__c.getOrgDefaults();

        Id currentUserId = UserInfo.getUserId();
        Id currentUserIdNonAdmin;
        System.runAs(new User(Id = currentUserId)){
            currentUserIdNonAdmin = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TERMINATION_CASE_UPDATE).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, createPermissionSetId);

            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet( currentUserId, createPermissionSetId);
            }
        }

        System.runAs((new User(Id = currentUserId))){
            TriggerBase.bypass('Case');
            Case caseRec = UthCase.buildTerminationCase(UthContact.getAll()[0].Id, UthTenancy.getAll()[0].Id);
            insert caseRec;
            TriggerBase.clearBypass('Case');
            Test.startTest();
                List<Id> recordTypeIds = new List<Id>{
                    CaseDecorator.RECORD_TYPE_ID_TERMINATION
                };
                AutoCloseTerminationCaseBatch abatch = new AutoCloseTerminationCaseBatch(recordTypeIds, (Integer)setting.DaysAutoCloseTerminationCase__c, 5);
                abatch.chatterImpl = new MockChatterPoster();
                abatch.startdate = Date.newInstance(2025, 10, 24);
                Database.executeBatch(abatch);
            Test.stopTest();
        }
        
        Assert.areEqual(CaseDecorator.STATUS_COMPLETE_CASE, UthCase.getAll()[0].Status);
        Assert.areEqual(CaseDecorator.CASE_CLOSURE_REASON_TENANCY_ENDED, UthCase.getAll()[0].ClosureReason__c);
        Assert.areEqual(CaseDecorator.CASE_OUTCOME_TENANCY_ENDED, UthCase.getAll()[0].CaseOutcome__c);
        Assert.areEqual(CaseDecorator.SUB_STATUS_COMPLETED, UthCase.getAll()[0].SubStatus__c);
    } 

    @isTest
    static void testExecuteAutoCloseBatchBulkSuccess(){
        OrgSetting__c setting = OrgSetting__c.getOrgDefaults();

        TriggerBase.bypass('Account');
        TriggerBase.bypass('Case');
        TriggerBase.bypass('YH_Tenancy__c');
        
        List<Account> accountList = new List<Account>();
        for(Integer i=0 ; i <5 ; i++){
            accountList.add(UthAccount.buildPersonAccount());
        }
        insert accountList;
        List<Contact> contacts = UthContact.getAll();

        List<YH_Property__c> propertyList = new List<YH_Property__c>();
        for(Integer i=0 ; i < contacts.size() ; i++){
            propertyList.add(UthProperty.buildHousingPurposeProperty(
                PropertyDecorator.AUTHORITY_BARNSLEY,
                PropertyDecorator.AUTHCODE_E08000038,
                null));
        }
        insert propertyList;
        List<YH_Property__c> properties = UthProperty.getAll();

        List<YH_Tenancy__c> tenancyList = new List<YH_Tenancy__c>();
        for(Integer i=0 ; i < contacts.size() ; i++){
            YH_Tenancy__c tenancy = UthTenancy.build(properties[i].Id, false, null);
            tenancy.TenancyEndDate__c = Date.newInstance(2025, 10, 21);

            tenancyList.add(tenancy);
        }
        insert tenancyList;
        List<YH_Tenancy__c> tenancies = UthTenancy.getAll();

        List<Case> caseList = new List<Case>();
        for(Integer i=0 ; i < contacts.size() ; i++){
            caseList.add(UthCase.buildTerminationCase(contacts[i].Id, tenancies[i].Id));
            
        }
        insert caseList;

        TriggerBase.clearBypass('Case');
        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('YH_Tenancy__c');

        Id currentUserId = UserInfo.getUserId();
        Id currentUserIdNonAdmin;
        System.runAs(new User(Id = currentUserId)){
            currentUserIdNonAdmin = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TERMINATION_CASE_UPDATE).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, createPermissionSetId);

            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet( currentUserId, createPermissionSetId);
            }
        }

        System.runAs((new User(Id = currentUserId))){
            Test.startTest();
                List<Id> recordTypeIds = new List<Id>{
                    CaseDecorator.RECORD_TYPE_ID_TERMINATION
                };
                AutoCloseTerminationCaseBatch abatch = new AutoCloseTerminationCaseBatch(recordTypeIds, (Integer)setting.DaysAutoCloseTerminationCase__c, 5);
                abatch.chatterImpl = new MockChatterPoster();
            	abatch.startdate = Date.newInstance(2025, 10, 24);
                Database.executeBatch(abatch);
            Test.stopTest();
        }
        List<Case> cases = UthCase.getAll();
        Assert.areEqual(6, cases.size());
        for(Integer i=0 ; i < cases.size() ; i++){
            Assert.areEqual(CaseDecorator.STATUS_COMPLETE_CASE, cases[i].Status);
            Assert.areEqual(CaseDecorator.CASE_CLOSURE_REASON_TENANCY_ENDED, cases[i].ClosureReason__c);
            Assert.areEqual(CaseDecorator.CASE_OUTCOME_TENANCY_ENDED, cases[i].CaseOutcome__c);
            Assert.areEqual(CaseDecorator.SUB_STATUS_COMPLETED, cases[i].SubStatus__c);
        }
    } 
    
    @isTest
    static void testExecuteAutoCloseBatchError(){
        OrgSetting__c setting = OrgSetting__c.getOrgDefaults();

        Id currentUserId = UserInfo.getUserId();
        Id currentUserIdNonAdmin;
        System.runAs(new User(Id = currentUserId)){
            currentUserIdNonAdmin = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TERMINATION_CASE_UPDATE).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, createPermissionSetId);

            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet( currentUserId, createPermissionSetId);
            }
        }

        System.runAs((new User(Id = currentUserId))){
            TriggerBase.bypass('Case');
            Case caseRec = UthCase.buildTerminationCase(UthContact.getAll()[0].Id, UthTenancy.getAll()[0].Id);
            caseRec.CaseType__c = null;
            insert caseRec;
            TriggerBase.clearBypass('Case');

            Test.startTest();
                List<Id> recordTypeIds = new List<Id>{
                    CaseDecorator.RECORD_TYPE_ID_TERMINATION
                };
                AutoCloseTerminationCaseBatch abatch = new AutoCloseTerminationCaseBatch(recordTypeIds, (Integer)setting.DaysAutoCloseTerminationCase__c, 5);
            	abatch.chatterImpl = new MockChatterPoster();
                Database.executeBatch(abatch);
            Test.stopTest();
        }
        
        Assert.areNotEqual(CaseDecorator.STATUS_COMPLETE_CASE, UthCase.getAll()[0].Status);
    } 

    private class MockChatterPoster implements ChatterInterface { 
        public ConnectApi.BatchResult[] postToChatterFeedBatchResults(Id subjectId, List<String> messages) {  
           return new List<ConnectApi.BatchResult>();
        }  
    }
}