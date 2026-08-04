@isTest(seeAllData=false)
public class TenancyResolutionSLACalculationTest {

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
    static void testCalculateSLADatesForAbandonedGoods(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(getTenancyUser()) {
            Test.startTest();
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.TENANCY_ABANDONED_GOODS_CASE_SLA_DAYS,
                nextBusinessDay
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildTenancyCase(contactsList[0].Id);
            caseRecord.CaseType__C = CaseDecorator.TYPE_ABANDONED_GOODS;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAEndDate__c.date(),'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLADatesForAbandonedVehicles(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(getTenancyUser()) {
            Test.startTest();
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.TENANCY_ABANDONED_PROPERTY_CASE_SLA_DAYS,
                nextBusinessDay
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildTenancyCase(contactsList[0].Id);
            caseRecord.CaseType__C = CaseDecorator.TYPE_ABANDONED_PROPERTIES;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAEndDate__c.date(),'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLADatesForRightToRent(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(getTenancyUser()) {
            Test.startTest();
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.TENANCY_RIGHT_TO_RENT_CASE_SLA_DAYS,
                nextBusinessDay
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildTenancyCase(contactsList[0].Id);
            caseRecord.CaseType__C = CaseDecorator.TYPE_RIGHT_To_RENT;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAEndDate__c.date(),'Both must be equal');
        }
    }


    static User getTenancyUser() {
        Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        UthPermissionAssigner.assignPermissionSet(currentUserId, createPermissionSetId);
        return (new User(Id = currentUserId));
    }
}