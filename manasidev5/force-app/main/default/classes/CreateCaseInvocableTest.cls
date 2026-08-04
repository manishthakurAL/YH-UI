@isTest
public class CreateCaseInvocableTest {

    @testSetup
    static void setUpTestData(){

        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');

        Account account = UthAccount.build();
        insert account;
        

        Contact contact = UthContact.build(account.Id);
        insert contact;

       

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
    }

    @isTest 
    static void test_insert_case_with_assignment_rule() {

        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_CREATE_STAGE1).Id;
        Id permissionSetUpdateId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id; 
        
        Id currentUserId = UserInfo.getUserId();
        Contact contact = UthContact.getAll().get(0);
        UthPermissionAssigner.assignPermissionSet(currentUserId, permissionSetId);
        UthPermissionAssigner.assignPermissionSet(currentUserId, permissionSetUpdateId);
        List<Case> response = new List<Case>();
        Case complaintCase = UthCase.buildComplaintCase(UthContact.getAll().get(0).Id);
        complaintCase.StageOneEscalatedDate__c = System.now().addDays(-1);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
            complaintCase.Status = CaseDecorator.STATUS_STAGE_ONE;
            complaintCase.Type = CaseDecorator.TYPE_COMPLAINT;
            response = CreateCaseInvocable.create(new List<Case>{complaintCase});
            Test.stopTest();
        }

        complaintCase = UthCase.get(response[0].Id);

        String ownerId = complaintCase.ownerId;

        Assert.areEqual(true, ownerId.startsWithIgnoreCase('00G'), 'Case owner must be a queue');
    }
}