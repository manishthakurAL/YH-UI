@isTest(seeAllData=false)
public with sharing class TA_Case_BI_ValidateUserPermissionsTest {

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
        caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
        caseRecord.StageOneEscalatedDate__c = System.now().addDays(-1);
        caseRecord.StageTwoEscalatedDate__c = System.now().addDays(-1);
        insert caseRecord;

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        TriggerBase.clearBypass('Case');
    }

    @isTest
    static void testInsertComplaintCasePermission_Success(){
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        Contact contact = UthContact.getAll().get(0);
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            Case caseRecord = UthCase.buildComplaintCase(contact.Id);
            caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_COMPLAINTS;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.Type = CaseDecorator.TYPE_COMPLAINT;
            caseRecord.StageOneEscalatedDate__c = System.now().addDays(-1);
            insert caseRecord;
        }
        Test.stopTest();

        Integer size = UthCase.getAll().size();
        Assert.areEqual(2,size,'Should be able to insert successfully');
    }

    @isTest
    static void testInsertComplaintCasePermission_Failure(){
        Id currentUserId = UserInfo.getUserId();
        Contact contact = UthContact.getAll().get(0);
        String expectedErrorMsg = String.format(
            Label.CasePermissionValidationError,
            new List<String>{'create', CaseDecorator.STATUS_STAGE_ONE}
        );
        String actualErrorMsg;
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
                Case caseRecord = UthCase.buildComplaintCase(contact.Id);
                caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_COMPLAINTS;
                caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
                caseRecord.Type = CaseDecorator.TYPE_COMPLAINT;
                caseRecord.StageOneEscalatedDate__c = System.now().addDays(-1);
                insert caseRecord;
            }catch(Exception exp){
                actualErrorMsg = exp.getMessage();
            }
        }
        Test.stopTest();
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg),  'Expected exception when inserting case' );
    
    }
}