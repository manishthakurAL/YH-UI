@isTest
public with sharing class CaseSLACalculationServiceEmailRespGETest {
   
    @TestSetup
    static void makeData(){
        UthFeatureSwitches.enableEmailResponseRT();
        TriggerBase.bypass('Account');
        Account account1 = UthAccount.buildPersonAccount();
        insert account1;
        Id acontactId = UthContact.getAll()[0].Id;
        TriggerBase.clearBypass('Account');
    }


    @isTest
    static void calculateSLADatesTestInitialEmail(){  
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildEmailResponseCase(contactsList[0].Id);
            caseRecord.Origin = CaseDecorator.CASE_ORIGIN_EMAIL_CEC;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_INITIALEMAIL),'It should include Initial Email milestone');
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal'); 
    }

    @isTest
    static void testCalculateSLADatesForEmailResponse(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();
        DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
        List<Contact> contactsList = UthContact.getAll();
        Case caseRecord = UthCase.buildEmailResponseCase(contactsList[0].Id);
        caseRecord.Origin = CaseDecorator.CASE_ORIGIN_EMAIL_CEC;
        insert caseRecord;
        caseRecord.Status = CaseDecorator.CASE_STAGE_EMAILRESPONSERECIEVED;
        caseRecord.CompletedMilestones__c = CaseMilestoneDecorator.CASE_MILESTONE_INITIALEMAIL;
        update caseRecord;
        caseRecord = UthCase.get(caseRecord.Id);
        Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_EMAILRESPONSE),'It should include Email response milestone');
        Test.stopTest();        
        caseRecord = UthCase.get(caseRecord.Id);
        Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
    }

    @isTest
    static void testCalculateSLADatesForPreDefinedDates(){  
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
        List <Case> newList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId, 
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.CASE_TYPE_EMAILRESPONSE,
            CaseDecorator.RECORD_TYPE_ID_EMAILRESPONSE)};
        newList[0].Status = CaseDecorator.STATUS_NEW;
        newList[0].Origin = CaseDecorator.CASE_ORIGIN_EMAIL_CEC;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
                DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2024, 10, 15) ,Time.newInstance(10,0,0,0));
                DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2024, 10, 17) ,Time.newInstance(17,0,0,0));
                new CaseSLACalculationServiceEmailResponseGE(startDateTime).calculateSLADates(newList, null);
            Test.stopTest();   
            
            Assert.areEqual(startDateTime,newList[0].SLAStartDate__c,'Both must be equal');
        }
    }
    @isTest
    static void calculateSLADatesTestInitialEmail_CustomerPortal(){  
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildGeneralEnquiryCase(contactsList[0].Id,null);
            caseRecord.Origin = CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_INITIALEMAIL),'It should include Initial Email milestone');
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal'); 
    }

    @isTest
    static void testCalculateSLADatesForEmailResponse_OperativeRepairs(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();
        DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
        List<Contact> contactsList = UthContact.getAll();
        Case caseRecord = UthCase.buildGeneralEnquiryCase(contactsList[0].Id,null);
        caseRecord.Origin = CaseDecorator.CASE_ORIGIN_OPERATIVE_REPAIRS;
        insert caseRecord;
        caseRecord.Status = CaseDecorator.CASE_STAGE_EMAILRESPONSERECIEVED;
        caseRecord.CompletedMilestones__c = CaseMilestoneDecorator.CASE_MILESTONE_INITIALEMAIL;
        update caseRecord;
        caseRecord = UthCase.get(caseRecord.Id);
        Assert.isTrue(caseRecord.RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_EMAILRESPONSE),'It should include Email response milestone');
        Test.stopTest();        
        caseRecord = UthCase.get(caseRecord.Id);
        Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
    }
}