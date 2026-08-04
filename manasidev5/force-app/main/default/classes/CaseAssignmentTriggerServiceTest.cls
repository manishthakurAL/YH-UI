@isTest(seeAllData=false)
public with sharing class CaseAssignmentTriggerServiceTest {

    @TestSetup
    static void setUpTestData(){
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.buildUser(roleId,adminProfileId,'fname1','lname1');
        insert adminUser;

        System.runAs(adminUser){
            UthFeatureSwitches.enableCustomerRT();
            UthFeatureSwitches.enableCaseTerminationRT();
            TriggerBase.bypass('Account');
            TriggerBase.bypass('YH_Tenancy__c');
                Account account = UthAccount.build();
                insert account;

                insert new List<Account>{
                    UthAccount.buildPersonAccount('JohnOne', 'DoeOne','123 Test St','London','AB123CD')
                };
                
                YH_Property__c property = UthProperty.buildPropertyWithAssetClass('Leeds',
                        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
                        PropertyDecorator.RENT_TYPE_MARKET_RENT, PropertyDecorator.PRODUCT_TYPE_MARKETRENTAL,
                        '123 Test St', 'London', 'AB123CD',PropertyDecorator.FLAT_ASSET_CLASS);
                insert property;

                YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT);
        	    insert tenancy;

                YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];

                List<Contact> contacts = UthContact.getAll();

                List<User> userList = new List<User>{
                    UthUser.buildCommunityUser(contacts[0].Id,null)
                };
                insert userList;
            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('YH_Tenancy__c');
        }
    }

    @isTest
    static void testIntialComplaint(){
        Id currentUserId = UserInfo.getUserId();   
        List<Contact> contactsList = UthContact.getAll();
        Test.startTest();
        Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
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
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            insert caseRecord;
                               
        
            Test.startTest();
            List<Case> casesList = UthCase.getAll();
            casesList[0].SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            update casesList;
            casesList[0].Status = CaseDecorator.STATUS_STAGE_ONE;
            casesList[0].StageOneEscalatedDate__c = System.now().addDays(-1);
            update casesList;
            Test.stopTest();
            String complaintStageOneQueueId = UthQueue.getQueue(CaseDecorator.COMPLAINT_STAGE_ONE_QUEUE).Id;
            casesList = UthCase.getAll();
            Assert.areEqual(complaintStageOneQueueId,casesList[0].OwnerId,'Owner should be stage one complaint queue');
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
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            insert caseRecord;
                               
        
            Test.startTest();
            List<Case> casesList = UthCase.getAll();
            casesList[0].SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            update casesList;
            casesList[0].Status = CaseDecorator.STATUS_STAGE_ONE;
            casesList[0].StageOneEscalatedDate__c = System.now().addDays(-1);
            update casesList;
            casesList[0].Status = CaseDecorator.STATUS_STAGE_TWO;
            casesList[0].StageTwoEscalatedDate__c  = System.now().addDays(-1);
            update casesList;
            Test.stopTest();
            String complaintStageTwoQueueId = UthQueue.getQueue(CaseDecorator.COMPLAINT_STAGE_TWO_QUEUE).Id;
            casesList = UthCase.getAll();
            Assert.areEqual(complaintStageTwoQueueId,casesList[0].OwnerId,'Owner should be complaint stage two queue');
        }
    }

    @isTest
    static void testCustomerExperienceQueueAssignment(){

        Id userRoleId = UthUserRole.getUserRole(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER).Id;

        Id customSuccessProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_CUSTOMER_SUCCESS)[0].Id;
        User runAsUser = UthUser.buildUser(userRoleId, customSuccessProfileId, 'fName', 'lname');
        insert runAsUser;
        Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CEC_RT_UPDATE).Id;
        Id currentUserId =runAsUser.Id;
        UthPermissionAssigner.assignPermissionSet(currentUserId, createPermissionSetId); 

        System.runAs(runAsUser) {
            TriggerBase.bypass('Case');
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildCustomerCase(contactsList[0].Id);
            insert caseRecord;
            caseRecord.ownerId = runAsUser.Id;
            update caseRecord;
            TriggerBase.clearBypass('Case');
            Test.startTest();
            List<Case> casesList = UthCase.getAll();
            casesList[0].Status = CaseDecorator.STATUS_AWAITING_DOCUMENTATION;
            update casesList;
            Test.stopTest();
        }
        String customerExperienceCentreQueueId = UthQueue.getQueue(CaseDecorator.CUSTOMER_EXPERIENCE_QUEUE).Id;
        List<Case> casesListUpdated = UthCase.getAll();
        Assert.areEqual(customerExperienceCentreQueueId,casesListUpdated[0].OwnerId,'Case must be assigned to customer expereince queue');
    }

    @isTest
    static void testOmbudsmanComplaint(){
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

        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_OMBUDSMAN).Id;
        
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {

            List<Contact> contactsList = [SELECT Id FROM Contact LIMIT 1];
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            insert caseRecord;
                               
            Test.startTest();
            List<Case> casesList = UthCase.getAll();
            casesList[0].SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            update casesList;
            casesList[0].Status = CaseDecorator.STATUS_STAGE_ONE;
            casesList[0].StageOneEscalatedDate__c = System.now().addDays(-1);
            update casesList;
            casesList[0].Status = CaseDecorator.STATUS_STAGE_TWO;
            casesList[0].StageTwoEscalatedDate__c  = System.now().addDays(-1);
            update casesList;
            casesList[0].Status = CaseDecorator.STATUS_STAGE_OMBUDSMAN;
            update casesList;
            Test.stopTest();
            casesList = UthCase.getAll();
            Assert.areEqual(currentUserId,casesList[0].OwnerId,'Owner should be current user');
        }
    }

    @isTest
    static void terminationCaseAssignment(){
        TriggerBase.bypass('Case');
        TriggerBase.bypass('YH_Tenancy__c');
        List<Contact> contactList = UthContact.getAll();
        Case caseRec = UthCase.buildTerminationCaseForSharing(contactList[0].Id, UthTenancy.getAll()[0].Id, CaseDecorator.CASESHARINGREASON_TENANT);
        insert caseRec;
        TriggerBase.clearBypass('YH_Tenancy__c');
        TriggerBase.clearBypass('Case');
       
        Test.startTest();
            TriggerBase.bypass('Case');
            CaseAssignmentTriggerService.bypassAutomation = false;
            CaseAssignmentTriggerService.triggerCaseAssingmentRules(new Set<Id>{caseRec.Id}, false);
            TriggerBase.clearBypass('Case');
        Test.stopTest();

        List<CaseShare> caseShares1 = UthCaseShare.getAllUsingCaseId(new List<Id>{caseRec.Id});
        System.Assert.areEqual(1, caseShares1.size());
    }
}