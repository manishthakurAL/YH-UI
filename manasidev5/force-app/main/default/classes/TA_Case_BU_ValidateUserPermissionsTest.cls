@isTest(seeAllData=false)
public with sharing class TA_Case_BU_ValidateUserPermissionsTest {
    
    @testSetup
    static void setUpTestData(){

        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        TriggerBase.bypass('Case');

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact;

        Case caseRecord = UthCase.buildComplaintCase(contact.Id);
        caseRecord.StageOneEscalatedDate__c = System.now().addDays(-1);
        caseRecord.StageTwoEscalatedDate__c = System.now().addDays(-1);
        insert caseRecord;
        caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
        update caseRecord;
        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        TriggerBase.clearBypass('Case');
    }

    @isTest
    static void testUpdateComplaintCasePermission_Success(){
        
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE2).Id;
        
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        Case caseRecord = UthCase.getAll().get(0);
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            update caseRecord;
            caseRecord.Status =  CaseDecorator.STATUS_STAGE_TWO;
            update caseRecord;
        }
        Test.stopTest();

        caseRecord = UthCase.get(caseRecord.Id);
        Assert.areEqual( CaseDecorator.STATUS_STAGE_TWO, caseRecord.Status,'Status should be updated');
    }

    @isTest
    static void testInitialComplaintCasePermission(){
        
        Id currentUserId = UserInfo.getUserId();
        Case caseRecord = UthCase.getAll().get(0);
        String expectedErrorMsg = String.format(
            Label.CasePermissionValidationError,
            new List<String>{'edit', CaseDecorator.STATUS_STAGE_ONE}
        );
        String actualErrorMsg;
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
                caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
                update caseRecord;
            }catch(Exception exp){
                actualErrorMsg = exp.getMessage();
            }
        }
        Test.stopTest();
        Assert.areEqual(null, actualErrorMsg, 'No Exception should be thrown' );
    }

    @isTest
    static void testStageOneCasePermission(){
        Id currentUserId = UserInfo.getUserId();
        Case caseRecord = UthCase.getAll().get(0);
        String expectedErrorMsg = String.format(
            Label.CasePermissionValidationError,
            new List<String>{'edit', CaseDecorator.STATUS_STAGE_ONE}
        );
        String actualErrorMsg;
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
                caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
                update caseRecord;
                caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
                update caseRecord;
            }catch(Exception exp){
                actualErrorMsg = exp.getMessage();
            }
        }
        Test.stopTest();
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Expected exception when editing case');
    }
}