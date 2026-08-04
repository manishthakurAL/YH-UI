@isTest(seeAllData=false)
public with sharing class MoneyCoachingSLACalculationServiceTest {
    
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
    static void testCalculateSLADatesForHighPriorityOnCreate(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(getMoneyCoachingUser()) {
            Test.startTest();
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.MONEY_COACHING_CASE_HIGH_PRIORITY_DAYS,
                nextBusinessDay
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildMoneyCoachingCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_HIGH;
            insert caseRecord;
            caseRecord.OwnerId = UserInfo.getUserId();
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAEndDate__c.date(),'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLADatesForLowPriorityOnCreate(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(getMoneyCoachingUser()) {  
            Test.startTest();      
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.MONEY_COACHING_CASE_LOW_PRIORITY_DAYS,
                nextBusinessDay
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildMoneyCoachingCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_LOW;
            insert caseRecord;
            caseRecord.OwnerId = UserInfo.getUserId();
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAEndDate__c.date(),'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLADatesForHighPriorityOnUpdateToLowPriority(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(getMoneyCoachingUser()) {   
            Test.startTest();     
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.MONEY_COACHING_CASE_HIGH_PRIORITY_DAYS,
                nextBusinessDay
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildMoneyCoachingCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_HIGH;
            insert caseRecord;
            caseRecord.OwnerId = UserInfo.getUserId();
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAEndDate__c.date(),'Both must be equal');
            caseRecord.Priority = CaseDecorator.PRIORITY_LOW;
            caseRecord.PriorityChangeReasonFreetext__c = 'test';
            update caseRecord;
            Test.stopTest();        
            expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.MONEY_COACHING_CASE_LOW_PRIORITY_DAYS,
                nextBusinessDay
            );
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAEndDate__c.date(),'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLADatesForLowPriorityOnUpdateToHighPriority(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(getMoneyCoachingUser()) {
            Test.startTest();        
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.MONEY_COACHING_CASE_LOW_PRIORITY_DAYS,
                nextBusinessDay
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildMoneyCoachingCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_LOW;
            insert caseRecord;
            caseRecord.OwnerId = UserInfo.getUserId();
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAEndDate__c.date(),'Both must be equal');
            caseRecord.Priority = CaseDecorator.PRIORITY_HIGH;
            caseRecord.PriorityChangeReasonFreetext__c = 'test';
            update caseRecord;
            Test.stopTest();   
            expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.MONEY_COACHING_CASE_HIGH_PRIORITY_DAYS,
                nextBusinessDay
            );     
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAEndDate__c.date(),'Both must be equal');
        }
    }

    static User getMoneyCoachingUser() {
        Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MONEY_COACHING_CASE_CREATE).Id;
        Id updatePermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MONEY_COACHING_CASE_UPDATE).Id;
        Id currentUserId = UserInfo.getUserId();
        UthPermissionAssigner.assignPermissionSet(currentUserId, createPermissionSetId);
        UthPermissionAssigner.assignPermissionSet(currentUserId, updatePermissionSetId);
        return (new User(Id = currentUserId));
    }
}