@isTest(seeAllData=false)
public class TenancyFirstContactSLACalculationTest {
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
    static void testCalculateSLADatesForDecantTypeTemporary(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(getTenancyUser()) {
            Test.startTest();
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.TENANCY_FIRSTCONTACT_TEMPORARY_DECANT_CASE_SLA_DAYS,
                nextBusinessDay
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildTenancyCase(contactsList[0].Id);
            caseRecord.CaseType__C = CaseDecorator.CASETYPE_DECANT;
            insert caseRecord;
            caseRecord.DecantType__c = CaseDecorator.TENANCY_DECANT_CASE_TYPE_TEMPORARY;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.ResolutionTargetDate__c,'Both must be equal');
        }
    }    

    @isTest
    static void testCalculateSLADatesForDecantTypeTemporaryUpdateScenario(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(getTenancyUser()) {
            Test.startTest();
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.TENANCY_FIRSTCONTACT_TEMPORARY_DECANT_CASE_SLA_DAYS,
                nextBusinessDay
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildTenancyCase(contactsList[0].Id);
            caseRecord.CaseType__C = CaseDecorator.CASETYPE_DECANT;
            insert caseRecord;
            caseRecord.DecantType__c = CaseDecorator.TENANCY_DECANT_CASE_TYPE_TEMPORARY;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.ResolutionTargetDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLADatesForDecantTypePermanent(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(getTenancyUser()) {
            Test.startTest();
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.TENANCY_FIRSTCONTACT_CASE_SLA_DAYS,
                nextBusinessDay
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildTenancyCase(contactsList[0].Id);
            caseRecord.CaseType__C = CaseDecorator.CASETYPE_DECANT;
            caseRecord.DecantType__c = CaseDecorator.TENANCY_DECANT_CASE_TYPE_PERMANENT;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.ResolutionTargetDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLADatesForDecantTypeTemporaryWithPreDefinedDates(){  
        
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        
        System.runAs(getTenancyUser()) {
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
        List <Case> newList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId, 
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.CASETYPE_DECANT,
            CaseDecorator.RECORD_TYPE_ID_TENANCY)};
            newList[0].Status = CaseDecorator.STATUS_NEW;
            newList[0].DecantType__c = null;

        List <Case> oldList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId, 
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.CASETYPE_DECANT,
            CaseDecorator.RECORD_TYPE_ID_TENANCY)};
            newList[0].Status = CaseDecorator.STATUS_NEW;
            newList[0].DecantType__c = CaseDecorator.TENANCY_DECANT_CASE_TYPE_TEMPORARY;
        Map<Id, Case> oldCasesMap = new Map<Id, Case>();
        oldCasesMap.put(caseRecId, oldList[0]);
        
            Test.startTest();
                DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2025, 03, 21) ,Time.newInstance(10,0,0,0));
                DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2025, 03, 24) ,Time.newInstance(17,0,0,0));
                new TenancyFirstContactSLACalculationService(startDateTime).calculateSLADates(newList, oldCasesMap);
            Test.stopTest();   
            
            Assert.areEqual(startDateTime,newList[0].SLAStartDate__c,'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),newList[0].ResolutionTargetDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLADatesForDecantTypePermanentWithPreDefinedDates(){  
        
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        
        System.runAs(getTenancyUser()) {
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
        List <Case> newList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId, 
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.CASETYPE_DECANT,
            CaseDecorator.RECORD_TYPE_ID_TENANCY)};
            newList[0].Status = CaseDecorator.STATUS_NEW;
            newList[0].DecantType__c = CaseDecorator.TENANCY_DECANT_CASE_TYPE_PERMANENT;

            Test.startTest();
                DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2025, 03, 21) ,Time.newInstance(10,0,0,0));
                DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2025, 03, 28) ,Time.newInstance(17,0,0,0));
                new TenancyFirstContactSLACalculationService(startDateTime).calculateSLADates(newList, null);
            Test.stopTest();   
            
            Assert.areEqual(startDateTime,newList[0].SLAStartDate__c,'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),newList[0].ResolutionTargetDate__c,'Both must be equal');
        }
    }
    
    static User getTenancyUser() {
        Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id;
        Id createPermissionSetUpdateId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_UPDATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        UthPermissionAssigner.assignPermissionSet(currentUserId, createPermissionSetId);
        UthPermissionAssigner.assignPermissionSet(currentUserId, createPermissionSetUpdateId);
        return (new User(Id = currentUserId));
    }
}