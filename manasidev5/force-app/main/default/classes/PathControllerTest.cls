@isTest(seeAllData=false)
public with sharing class PathControllerTest {
    
    @testSetup
    static void setUpTestData(){
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        TriggerBase.bypass('Case');

        OrgSetting__c orgSetting = UthOrgSetting.build();
        insert orgSetting;

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact;

        Case caseRecord = UthCase.buildComplaintCase(contact.Id);
        caseRecord.StageOneEscalatedDate__c = System.now().addDays(-1);
        insert caseRecord;
        caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
        update caseRecord;
        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        TriggerBase.clearBypass('Case');
    }

    @isTest
    static void testFetchPathConfigurationForAPicklist(){
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        System.runAs(new User(Id = currentUserId)) {
            List<Case> casesList = UthCase.getAll();
            for (Case caseRecord : casesList) {
                caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
                caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            }
            update casesList;
            Test.startTest();
            PathController.Path path = PathController.fetchPathConfiguration(
                casesList[0].Id,
                Case.Status.getDescribe().getName(),
                false,
                ''
            );
            Case caseRecord = (Case)path.record;
            Assert.areEqual(CaseDecorator.STATUS_STAGE_ONE,caseRecord.Status,'Status should be stage one');
            Assert.isTrue(path.fieldLabels.size() > 0,'it should fetch all the field labels for an sobject');
            Assert.areEqual(Case.sObjectType.getDescribe().getName(),path.sObjectName,'Sobjectname must be case');
            Assert.isNotNull(path.orgSetting.Id,'It should have an org setting with default record type id');
            Test.stopTest();
        }
    }

    @isTest
    static void testFetchPathConfigurationForADependentPicklist(){
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        System.runAs(new User(Id = currentUserId)) {
            List<Case> casesList = UthCase.getAll();
            for (Case caseRecord : casesList) {
                caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
                caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            }
            update casesList;
            Test.startTest();
            PathController.Path path = PathController.fetchPathConfiguration(
                casesList[0].Id,
                Case.SubStatus__c.getDescribe().getName(),
                true,
                Case.Status.getDescribe().getName()
            );
            Case caseRecord = (Case)path.record;
            Assert.areEqual(CaseDecorator.STATUS_STAGE_ONE,caseRecord.Status,'Status should be stage one');
            Assert.isTrue(path.fieldLabels.size() > 0,'it should fetch all the field labels for an sobject');
            Assert.areEqual(Case.sObjectType.getDescribe().getName(),path.sObjectName,'Sobjectname must be case');
            Assert.isNotNull(path.orgSetting.Id,'It should have an org setting with default record type id');
            Test.stopTest();
        }
    }
}