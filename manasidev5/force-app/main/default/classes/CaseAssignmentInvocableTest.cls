@isTest(seeAllData=false)
public with sharing class CaseAssignmentInvocableTest {
    
    // Test data setup
    @testSetup
    static void setUpTestData(){

        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        TriggerBase.bypass('Case');

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact;

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        TriggerBase.clearBypass('Case');
    }

    @isTest
    static void testIntialComplaint(){
        Id currentUserId = UserInfo.getUserId();   
        List<Contact> contactsList = UthContact.getAll();
        Test.startTest();
        Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
        caseRecord.StageOneEscalatedDate__c = System.now().addDays(-1);
        insert caseRecord;
        Test.stopTest();
        List<Case> casesList = UthCase.getAll();
        Assert.areEqual(currentUserId,casesList[0].OwnerId,'Owner should be current user');
    }

    @isTest
    static void testStageOneComplaint(){
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            insert caseRecord;
            List<Case> casesList = UthCase.getAll();
            casesList[0].SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            update casesList;
            casesList[0].Status = CaseDecorator.STATUS_STAGE_ONE;
            casesList[0].StageOneEscalatedDate__c = System.now().addDays(-1);
            update casesList;
            List<CaseAssignmentInvocable.CaseAssignmentWrapper> wrappers = 
                       new  List<CaseAssignmentInvocable.CaseAssignmentWrapper>();
            CaseAssignmentInvocable.CaseAssignmentWrapper awrapper = new CaseAssignmentInvocable.CaseAssignmentWrapper();
            awrapper.casesList = casesList;
            awrapper.sendEmailOnAssignment = false;
            CaseAssignmentInvocable.forceAssignmentRules(wrappers);
            Test.stopTest();
            casesList = UthCase.getAll();
            Assert.areNotEqual(currentUserId,casesList[0].OwnerId,'Owner should not be current user');
        }
    }

    @isTest
    static void testStageTwoComplaint(){
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

       
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            insert caseRecord;
            List<Case> casesList = UthCase.getAll();
            casesList[0].SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            update casesList;
            casesList[0].Status = CaseDecorator.STATUS_STAGE_ONE;
            casesList[0].StageOneEscalatedDate__c = System.now().addDays(-1);
            update casesList;
            casesList[0].Status = CaseDecorator.STATUS_STAGE_TWO;
            casesList[0].StageTwoEscalatedDate__c  = System.now().addDays(-1);
            update casesList;
            List<CaseAssignmentInvocable.CaseAssignmentWrapper> wrappers = 
                        new List<CaseAssignmentInvocable.CaseAssignmentWrapper>();
            CaseAssignmentInvocable.CaseAssignmentWrapper awrapper = new CaseAssignmentInvocable.CaseAssignmentWrapper();
            awrapper.casesList = casesList;
            awrapper.sendEmailOnAssignment = false;
            CaseAssignmentInvocable.forceAssignmentRules(wrappers);
            Test.stopTest();
            casesList = UthCase.getAll();
            Assert.areNotEqual(currentUserId,casesList[0].OwnerId,'Owner should not be current user');
        }
    }


    @isTest
    static void testStageOneComplaintMultiple(){
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        List<CaseAssignmentInvocable.CaseAssignmentWrapper> wrappers = 
        new  List<CaseAssignmentInvocable.CaseAssignmentWrapper>();

        
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
            List<Contact> contactsList = UthContact.getAll();
            List<Case> cases = new List<Case>();
            for(Integer i=0; i<5; i++){
                CaseAssignmentInvocable.CaseAssignmentWrapper awrapper = new CaseAssignmentInvocable.CaseAssignmentWrapper();
                Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
                insert caseRecord;
                caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
                update caseRecord;
                caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
                caseRecord.StageOneEscalatedDate__c = System.now().addDays(-1);
                update caseRecord;
                cases.add(caseRecord);
                awrapper.casesList = cases;
                cases.clear();
                wrappers.add(awrapper);
            }
           
          
            CaseAssignmentInvocable.forceAssignmentRules(wrappers);
            Test.stopTest();
            List<Case> casesList = UthCase.getAll();
            for(Case acase: casesList){
                Assert.areNotEqual(currentUserId,acase.OwnerId,'Owner should not be current user');
            }
        }
    }
}