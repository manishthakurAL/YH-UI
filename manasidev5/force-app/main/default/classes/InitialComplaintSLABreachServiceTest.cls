@isTest(seeAllData=false)
public with sharing class InitialComplaintSLABreachServiceTest {
    
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
    static void testCalculateInitialComplaintSLABreachStartDateBeforeStartTime(){    
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,03,04),Time.newInstance(5,30,0,0));
            Date expectedDate = Date.newInstance(2024,03,04);
            Time expectedTime = Time.newInstance(13,0,0,0);
            DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime,caseRecord.InitialComplaintSLABreachStartDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateInitialComplaintSLABreachStartDateOnStartTime(){     
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,03,04),Time.newInstance(9,0,0,0));
            Date expectedDate = Date.newInstance(2024,03,04);
            Time expectedTime = Time.newInstance(13,0,0,0);
            DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime,caseRecord.InitialComplaintSLABreachStartDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateInitialComplaintSLABreachStartDateAfterStartTime(){  
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission(); 
        System.runAs(new User(Id = currentUserId)) { 
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,03,04),Time.newInstance(11,30,0,0));
            Date expectedDate = Date.newInstance(2024,03,04);
            Time expectedTime = Time.newInstance(15,30,0,0);
            DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime,caseRecord.InitialComplaintSLABreachStartDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateInitialComplaintSLABreachStartDateAt1PM(){  
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        System.runAs(new User(Id = currentUserId)) { 
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,03,04),Time.newInstance(13,0,0,0));
            Date expectedDate = Date.newInstance(2024,03,05);
            Time expectedTime = Time.newInstance(13,0,0,0);
            DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime,caseRecord.InitialComplaintSLABreachStartDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateInitialComplaintSLABreachStartDateAt1530PM(){  
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        System.runAs(new User(Id = currentUserId)) {  
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,03,04),Time.newInstance(15,30,0,0));
            Date expectedDate = Date.newInstance(2024,03,05);
            Time expectedTime = Time.newInstance(13,0,0,0);
            DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime,caseRecord.InitialComplaintSLABreachStartDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateInitialComplaintSLABreachStartDateAtEndTime(){     
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        System.runAs(new User(Id = currentUserId)) { 
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,03,04),Time.newInstance(17,00,0,0));
            Date expectedDate = Date.newInstance(2024,03,05);
            Time expectedTime = Time.newInstance(13,0,0,0);
            DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime,caseRecord.InitialComplaintSLABreachStartDate__c,'Both must be equal');
        }
    }


    @isTest
    static void testCalculateInitialComplaintSLABreachStartDateAfterEndTime(){   
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        System.runAs(new User(Id = currentUserId)) { 
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,03,04),Time.newInstance(19,30,0,0));
            Date expectedDate = Date.newInstance(2024,03,05);
            Time expectedTime = Time.newInstance(13,0,0,0);
            DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime,caseRecord.InitialComplaintSLABreachStartDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateInitialComplaintSLABreachStartDateBeforeStartTimeOnUpdate(){   
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,03,04),Time.newInstance(5,30,0,0));
            Date expectedDate = Date.newInstance(2024,03,04);
            Time expectedTime = Time.newInstance(13,0,0,0);
            DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            startDateTime = startDateTime.addHours(1);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime,caseRecord.InitialComplaintSLABreachStartDate__c,'Both must be equal');
        }
    }
}