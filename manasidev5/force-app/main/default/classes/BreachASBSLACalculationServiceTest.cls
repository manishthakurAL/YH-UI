@isTest
public class BreachASBSLACalculationServiceTest {

    @TestSetup
    static void makeData(){
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
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_UPDATE).Id;
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
            Case caseRecord = UthCase.buildBreachAndASBCase(contactsList[0].Id);
            caseRecord.Issue__c = CaseDecorator.BREACH_ASB_ISSUE_CRIMINAL_DAMAGE;
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
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_UPDATE).Id;
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
            Case caseRecord = UthCase.buildBreachAndASBCase(contactsList[0].Id);
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
    static void testCalculateSLADatesOnCompleteFirstContactAttempt(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_UPDATE).Id;
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
            Case caseRecord = UthCase.buildBreachAndASBCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_URGENT;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT),'It should include first contact attempt milestone');
            caseRecord.CompletedMilestones__c = CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT ;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT),'It should include customer contact milestone');
        }
    }

    @isTest
    static void testCalculateSLADatesOnCompleteCustomerContact(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_UPDATE).Id;
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
            Case caseRecord = UthCase.buildBreachAndASBCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_URGENT;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT),'It should include first contact attempt milestone');
            caseRecord.CompletedMilestones__c = CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT ;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT),'It should include customer contact milestone');
        }
    }

    @isTest
    static void testCalculateSLADatesForBreachASBUrgentWithPreDefinedDates(){  
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
        List <Case> newList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId, 
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.CASE_TYPE_BREACH_AND_ANTISOCIAL,
            CaseDecorator.RECORD_TYPE_ID_BREACH_ASB)};
        newList[0].Status = CaseDecorator.STATUS_NEW;
        newList[0].Priority = CaseDecorator.PRIORITY_URGENT;

        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
                DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2024, 10, 28) ,Time.newInstance(10,0,0,0));
                DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2024, 10, 29) ,Time.newInstance(17,0,0,0));
                new BreachASBSLACalculationService(startDateTime).calculateSLADates(newList, null);
            Test.stopTest();   
            
            Assert.areEqual(startDateTime,newList[0].SLAStartDate__c,'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),newList[0].SLAEndDate__c.date(),'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLADatesForBreachASBRoutineWithPreDefinedDates(){  
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
        List <Case> newList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId, 
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.CASE_TYPE_BREACH_AND_ANTISOCIAL,
            CaseDecorator.RECORD_TYPE_ID_BREACH_ASB)};
        newList[0].Status = CaseDecorator.STATUS_NEW;
        newList[0].Priority = CaseDecorator.PRIORITY_ROUTINE;

        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
                DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2024, 10, 28) ,Time.newInstance(10,0,0,0));
                DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2024, 11, 04) ,Time.newInstance(17,0,0,0));
                new BreachASBSLACalculationService(startDateTime).calculateSLADates(newList, null);
            Test.stopTest();   
            
            Assert.areEqual(startDateTime,newList[0].SLAStartDate__c,'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),newList[0].SLAEndDate__c.date(),'Both must be equal');
        }
    }
    /*@isTest
    static void testSLAForReOpenedCase(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        System.runAs(new User(Id = currentUserId)) {
            
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildBreachAndASBCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_ROUTINE;
            insert caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_CLOSED;
            caseRecord.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_RESOLVED;
            caseRecord.ClosureReason__c = CaseDecorator.CASE_OUTCOME_COMPLETED;
            caseRecord.BreachOrASBIssuesResolved__c = CaseDecorator.BREACH_OR_ASB_ISSUES_RESOLVED;
            update caseRecord;
            Test.setCreatedDate(caseRecord.Id, DateTime.now().addDays(-1));
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            
            Test.startTest();
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.TENANCY_COACHING_CASE_ROUTINE_PRIORITY_DAYS,
                nextBusinessDay
            );
            caseRecord.ReOpenedDate__c = System.now();
            caseRecord.ReOpenReason__c= CaseDecorator.CASE_REOPEN_REASON_BREACH_RESUMED;
            caseRecord.Status = CaseDecorator.STATUS_NEW;
            update caseRecord;
            
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT),'It should include first contact attempt milestone');
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION),'It should include Resolution milestone');
            Assert.isTrue(String.IsBlank(caseRecord.CompletedMilestones__c),'It should be blank');
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAEndDate__c.date(),'Both must be equal');

        }
    }*/
    
}