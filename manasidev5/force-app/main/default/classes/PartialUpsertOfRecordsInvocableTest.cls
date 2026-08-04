@isTest
public class PartialUpsertOfRecordsInvocableTest {

    @testSetup
    static void setUpTestData(){

        UthFeatureSwitches.enableCaseComplaintsRT();
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
        
        list<SObject> cases = new list<SObject>();
        Case complaintCase = UthCase.buildComplaintCase(UthContact.getAll().get(0).Id);
        complaintCase.StageOneEscalatedDate__c = System.now().addDays(-1);
        complaintCase.Status = CaseDecorator.STATUS_STAGE_ONE;
        complaintCase.Type = CaseDecorator.TYPE_COMPLAINT;
        cases.add(complaintCase);

        List<PartialUpsertOfRecordsInvocable.PartialUpsertInput> inputs = new List<PartialUpsertOfRecordsInvocable.PartialUpsertInput>();
        PartialUpsertOfRecordsInvocable.PartialUpsertInput input = new PartialUpsertOfRecordsInvocable.PartialUpsertInput();
        input.records = cases;
        input.dmlOptionAssignmentRule = true;
        inputs.add(input);
        
        List<PartialUpsertOfRecordsInvocable.PartialUpsertResult> retResult;
        
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
                retResult = PartialUpsertOfRecordsInvocable.upsertRecords(inputs);
            Test.stopTest();
        }

        complaintCase = UthCase.getAll()[0];

        String ownerId = complaintCase.ownerId;

        Assert.areEqual(true, ownerId.startsWithIgnoreCase('00G'), 'Case owner must be a queue');
        system.Assert.isTrue(retResult != null);
        system.Assert.isTrue(retResult.size() == 1); 
    }
    
    @isTest
    static void upsertPersonAccount() {
        list<SObject> pAccounts1 = new list<SObject>();
        pAccounts1.add(UthAccount.build());
        pAccounts1.add(UthAccount.build());

        list<SObject> pAccounts2 = new list<SObject>();
        pAccounts2.add(UthAccount.build());
        pAccounts2.add(UthAccount.build());


        List<PartialUpsertOfRecordsInvocable.PartialUpsertInput> inputs = new List<PartialUpsertOfRecordsInvocable.PartialUpsertInput>();
        PartialUpsertOfRecordsInvocable.PartialUpsertInput input1 = new PartialUpsertOfRecordsInvocable.PartialUpsertInput();
        input1.records = pAccounts1;
        input1.dmlOptionAssignmentRule = false;

        PartialUpsertOfRecordsInvocable.PartialUpsertInput input2 = new PartialUpsertOfRecordsInvocable.PartialUpsertInput();
        input2.records = pAccounts2;
        input2.dmlOptionAssignmentRule = false;

        inputs.add(input1);
        inputs.add(input2);

        Test.startTest();
            List<PartialUpsertOfRecordsInvocable.PartialUpsertResult> retResult = PartialUpsertOfRecordsInvocable.upsertRecords(inputs);
        Test.stopTest();

        system.Assert.isTrue(retResult != null);
        system.Assert.isTrue(retResult.size() == 2);        
    }

    @isTest
    static void upsertPersonAccountErrorScenario() {
        list<SObject> pAccounts1 = new list<SObject>();
        pAccounts1.add(UthAccount.build());
        pAccounts1.add(UthAccount.build());

        list<SObject> pAccounts2 = new list<SObject>();
        pAccounts2.add(new Account());

        list<SObject> pAccounts3 = new list<SObject>();


        List<PartialUpsertOfRecordsInvocable.PartialUpsertInput> inputs = new List<PartialUpsertOfRecordsInvocable.PartialUpsertInput>();
        PartialUpsertOfRecordsInvocable.PartialUpsertInput input1 = new PartialUpsertOfRecordsInvocable.PartialUpsertInput();
        input1.records = pAccounts1;
        input1.dmlOptionAssignmentRule = false;

        PartialUpsertOfRecordsInvocable.PartialUpsertInput input2 = new PartialUpsertOfRecordsInvocable.PartialUpsertInput();
        input2.records = pAccounts2;
        input2.dmlOptionAssignmentRule = false;

        PartialUpsertOfRecordsInvocable.PartialUpsertInput input3 = new PartialUpsertOfRecordsInvocable.PartialUpsertInput();
        input3.records = pAccounts3;
        input3.dmlOptionAssignmentRule = false;

        inputs.add(input1);
        inputs.add(input2);
        inputs.add(input3);

        Test.startTest();
            List<PartialUpsertOfRecordsInvocable.PartialUpsertResult> retResult = PartialUpsertOfRecordsInvocable.upsertRecords(inputs);
        Test.stopTest();

        system.Assert.isTrue(retResult != null);
        system.Assert.isTrue(retResult.size() == 3); 
        
        system.Assert.isTrue(retResult[0].isSuccess[0] == true);
        system.Assert.isTrue(retResult[0].isCreated[0] == true);
        system.Assert.isTrue(retResult[0].recordId[0] != null);
        system.Assert.isTrue(retResult[0].isSuccess[1] == true);
        system.Assert.isTrue(retResult[0].isCreated[1] == true);
        system.Assert.isTrue(retResult[0].recordId[1] != null);
        system.Assert.isTrue(retResult[0].error.isEmpty() == true);

        system.Assert.isTrue(retResult[1].isSuccess[0] == false);
        system.Assert.isTrue(retResult[1].error.isEmpty() == false);
        system.Assert.isTrue(retResult[1].recordId.isEmpty() == true);
        

        system.Assert.isTrue(retResult[2].recordId.isEmpty() == true);
        system.Assert.isTrue(retResult[2].isSuccess.isEmpty() == true);
        system.Assert.isTrue(retResult[2].error.isEmpty() == true);
    }
}