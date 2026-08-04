@isTest(seeAllData=false)
public with sharing class TenancyCoachingSLACalculationServiceTest {
    
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
    static void testCalculateSLADatesForUrgentPriorityOnCreate(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.TENANCY_COACHING_CASE_URGENT_PRIORITY_DAYS,
                nextBusinessDay
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildTenancyCoachingCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_URGENT;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT),'It should include first contact attempt milestone');
            caseRecord.OwnerId = UserInfo.getUserId();
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAEndDate__c.date(),'Both must be equal');
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT),'It should include first contact attempt milestone');
        }
    }

    @isTest
    static void testCalculateSLADatesForRoutinePriorityOnCreate(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.TENANCY_COACHING_CASE_ROUTINE_PRIORITY_DAYS,
                nextBusinessDay
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildTenancyCoachingCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_ROUTINE;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT),'It should include first contact attempt milestone');
            caseRecord.OwnerId = UserInfo.getUserId();
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAEndDate__c.date(),'Both must be equal');
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT),'It should include first contact attempt milestone');
        }
    }

    @isTest
    static void testCalculateSLADatesOnTriageStatus(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.TENANCY_COACHING_CASE_URGENT_PRIORITY_DAYS,
                nextBusinessDay
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildTenancyCoachingCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_URGENT;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT),'It should include first contact attempt milestone');
            caseRecord.Status = CaseDecorator.STATUS_TRIAGE;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.isFalse(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT),'It should not include first contact attempt milestone');
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION),'It should include resolution milestone');
        }
    }

    @isTest
    static void testCalculateSLADatesOnCompleteFirstContactAttempt(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.TENANCY_COACHING_CASE_URGENT_PRIORITY_DAYS,
                nextBusinessDay
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildTenancyCoachingCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_URGENT;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT),'It should include first contact attempt milestone');
            caseRecord.Status = CaseDecorator.STATUS_TRIAGE;
            caseRecord.CompletedMilestones__c = CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT ;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.isFalse(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT),'It should not include first contact attempt milestone');
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION),'It should include resolution milestone');
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT),'It should include customer contact milestone');
        }
    }

    @isTest
    static void testCalculateSLADatesOnCompleteCustomerContact(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.TENANCY_COACHING_CASE_URGENT_PRIORITY_DAYS,
                nextBusinessDay
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildTenancyCoachingCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_URGENT;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT),'It should include first contact attempt milestone');
            caseRecord.Status = CaseDecorator.STATUS_TRIAGE;
            caseRecord.CompletedMilestones__c = CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT ;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.isFalse(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT),'It should not include first contact attempt milestone');
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION),'It should include resolution milestone');
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT),'It should include customer contact milestone');
        }
    }
}