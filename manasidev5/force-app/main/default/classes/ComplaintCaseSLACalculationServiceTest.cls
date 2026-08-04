@isTest(seeAllData=false)
public with sharing class ComplaintCaseSLACalculationServiceTest {
    
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
    static void testCalculateSLAStartDateBeforeStartTime(){     
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,03,04),Time.newInstance(5,30,0,0));
            Date expectedDate = Date.newInstance(2024,03,05);
            Time expectedTime = Time.newInstance(9,0,0,0);
            DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(CaseDecorator.STATUS_STAGE_ONE,caseRecord.Status,'Case Status must be Stage One');
            Assert.areEqual(expectedDateTime,caseRecord.SLAStartDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLADateAtStartTime(){    
    Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_CREATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        System.runAs(new User(Id = currentUserId)) { 
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,03,04),Time.newInstance(9,0,0,0));
            Date expectedDate = Date.newInstance(2024,03,05);
            Time expectedTime = Time.newInstance(9,0,0,0);
            DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(CaseDecorator.STATUS_STAGE_ONE,caseRecord.Status,'Case Status must be Stage One');
            Assert.areEqual(expectedDateTime,caseRecord.SLAStartDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartDateAfterStartTime(){     
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,03,04),Time.newInstance(10,45,0,0));
            Date expectedDate = Date.newInstance(2024,03,05);
            Time expectedTime = Time.newInstance(9,0,0,0);
            DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(CaseDecorator.STATUS_STAGE_ONE,caseRecord.Status,'Case Status must be Stage One');
            Assert.areEqual(expectedDateTime,caseRecord.SLAStartDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartDateAt1PM(){    
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,03,04),Time.newInstance(13,0,0,0));
            Date expectedDate = Date.newInstance(2024,03,06);
            Time expectedTime = Time.newInstance(9,0,0,0);
            DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(CaseDecorator.STATUS_STAGE_ONE,caseRecord.Status,'Case Status must be Stage One');
            Assert.areEqual(expectedDateTime,caseRecord.SLAStartDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartDateAfter1PM(){     
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,03,04),Time.newInstance(15,45,0,0));
            Date expectedDate = Date.newInstance(2024,03,06);
            Time expectedTime = Time.newInstance(9,0,0,0);
            DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(CaseDecorator.STATUS_STAGE_ONE,caseRecord.Status,'Case Status must be Stage One');
            Assert.areEqual(expectedDateTime,caseRecord.SLAStartDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartDateAfterEndTime(){     
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,03,04),Time.newInstance(21,30,0,0));
            Date expectedDate = Date.newInstance(2024,03,06);
            Time expectedTime = Time.newInstance(9,0,0,0);
            DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(CaseDecorator.STATUS_STAGE_ONE,caseRecord.Status,'Case Status must be Stage One');
            Assert.areEqual(expectedDateTime,caseRecord.SLAStartDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartADayBeforeCurrentDateBeforeStartTime(){  
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(9,0,0,0));
            DateTime expectedDateTime = businessHourService.calculateTargetDate(2, startDateTime);
            Date expectedDate = expectedDateTime.date();
            Time expectedTime = Time.newInstance(9,0,0,0);
            expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(CaseDecorator.STATUS_STAGE_ONE,caseRecord.Status,'Case Status must be Stage One');
            Assert.areEqual(expectedDateTime,caseRecord.SLAStartDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartADayBeforeCurrentDateAtStartTime(){   
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(9,0,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            DateTime expectedDateTime = businessHourService.getNextBusinessDay(businessHourService.add(nextBusinessStartDateTime,BusinessHourDecorator.FOUR_HOUR_IN_MILLISECONDS),13);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(CaseDecorator.STATUS_STAGE_ONE,caseRecord.Status,'Case Status must be Stage One');
            Assert.areEqual(expectedDateTime,caseRecord.SLAStartDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartADayBeforeCurrentDateAfterStartTime(){     
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(10,30,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            DateTime expectedDateTime = businessHourService.getNextBusinessDay(businessHourService.add(nextBusinessStartDateTime,BusinessHourDecorator.FOUR_HOUR_IN_MILLISECONDS),13);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(CaseDecorator.STATUS_STAGE_ONE,caseRecord.Status,'Case Status must be Stage One');
            Assert.areEqual(expectedDateTime,caseRecord.SLAStartDate__c,'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartDateADayBeforeCurrentDateAt1PM(){     
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission(); 
        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();      
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(13,0,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            DateTime expectedDateTime = businessHourService.getNextBusinessDay(businessHourService.add(nextBusinessStartDateTime,BusinessHourDecorator.FOUR_HOUR_IN_MILLISECONDS),13);
            List<Contact> contactsList = UthContact.getAll();  
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();   
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual((!caseRecord.BreachOf4hrSLA__c ? CaseDecorator.STATUS_INITIAL_COMPLAINT : CaseDecorator.STATUS_STAGE_ONE),caseRecord.Status,'Case Status must be Initial Complaint');
            Assert.areEqual((!caseRecord.BreachOf4hrSLA__c ? nextBusinessStartDateTime : expectedDateTime),caseRecord.SLAStartDate__c,'SLA start date must be equal to next business start date time');
        }
    }

    @isTest
    static void testCalculateSLAStartDateADayBeforeCurrentDateAfter1PM(){    
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission(); 
        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();    
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(15,49,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            DateTime expectedDateTime = businessHourService.getNextBusinessDay(businessHourService.add(nextBusinessStartDateTime,BusinessHourDecorator.FOUR_HOUR_IN_MILLISECONDS),13);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();  
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual((!caseRecord.BreachOf4hrSLA__c ? CaseDecorator.STATUS_INITIAL_COMPLAINT : CaseDecorator.STATUS_STAGE_ONE),caseRecord.Status,'Case Status must be Initial Complaint');
            Assert.areEqual((!caseRecord.BreachOf4hrSLA__c ? nextBusinessStartDateTime : expectedDateTime),caseRecord.SLAStartDate__c,'SLA start date must be equal to next business start date time');
        }
    }

    @isTest
    static void testCalculateSLAStartDateADayBeforeCurrentDateAfterEndTime(){    
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission(); 
        System.runAs(new User(Id = currentUserId)) { 
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();    
            DateTime startDateTime = DateTime.newInstance(System.today().addDays(-1),Time.newInstance(20,49,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            DateTime expectedDateTime = businessHourService.getNextBusinessDay(businessHourService.add(nextBusinessStartDateTime,BusinessHourDecorator.FOUR_HOUR_IN_MILLISECONDS),13);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();  
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual((!caseRecord.BreachOf4hrSLA__c ? CaseDecorator.STATUS_INITIAL_COMPLAINT : CaseDecorator.STATUS_STAGE_ONE),caseRecord.Status,'Case Status must be Initial Complaint');
            Assert.areEqual((!caseRecord.BreachOf4hrSLA__c ? nextBusinessStartDateTime : expectedDateTime),caseRecord.SLAStartDate__c,'SLA start date must be equal to next business start date time');
        }
    }

    /*
    @isTest
    static void testCalculateSLAStartDateForManualStage1EscalatedDateBeforeStartTime(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(5,30,0,0));
            DateTime expectedDateTime = businessHourService.calculateTargetDate(1, startDateTime).date();
            Date expectedDate = expectedDateTime.date();
            Time expectedTime = Time.newInstance(9,0,0,0);
            expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            // Assert.areEqual(expectedDateTime,caseRecord.SLAStartDate__c,'Both should be equal');
            Assert.areEqual(currentUserId,caseRecord.EscalatedToStage1By__c,'Both should be equal');
            Assert.isNotNull(caseRecord.Stage1RequestedDate__c,'It shouldnt be null');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            update caseRecord;
            Datetime businessStartDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(businessStartDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
        }
    }*/

    @isTest
    static void testCalculateSLAStartDateForManualStage1EscalatedDateAtStartTime(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(9,0,0,0));
            DateTime expectedDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            expectedDateTime = businessHourService.calculateTargetDate(2, expectedDateTime).date();
            Date expectedDate = expectedDateTime.date();
            Time expectedTime = Time.newInstance(9,0,0,0);
            expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime,caseRecord.SLAStartDate__c,'Both should be equal');
            Assert.areEqual(currentUserId,caseRecord.EscalatedToStage1By__c,'Both should be equal');
            Assert.isNotNull(caseRecord.Stage1RequestedDate__c,'It shouldnt be null');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            update caseRecord;
            Datetime businessStartDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(businessStartDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartDateForManualStage1EscalatedDateAfterStartTime(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(10,12,0,0));
            DateTime expectedDateTime = businessHourService.calculateTargetDate(1, startDateTime).date();
            Date expectedDate = expectedDateTime.date();
            Time expectedTime = Time.newInstance(9,0,0,0);
            expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime,caseRecord.SLAStartDate__c,'Both should be equal');
            Assert.areEqual(currentUserId,caseRecord.EscalatedToStage1By__c,'Both should be equal');
            Assert.isNotNull(caseRecord.Stage1RequestedDate__c,'It shouldnt be null');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            update caseRecord;
            Datetime businessStartDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(businessStartDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartDateForManualStage1EscalatedDateAt1PM(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(13,0,0,0));
            DateTime nextBusinessDayTime = businessHourService.getNextBusinessDay(startDateTime,CaseDecorator.COMPLAINTS_CASE_INITIAL_STAGE_SLA_BASELINE_HOUR); 
            DateTime initialComplaintSLABreachStartDateTime = businessHourService.add(nextBusinessDayTime,BusinessHourDecorator.FOUR_HOUR_IN_MILLISECONDS); 
            if (System.now() >= initialComplaintSLABreachStartDateTime) {
                startDateTime = initialComplaintSLABreachStartDateTime;
            }
            DateTime expectedDateTime = businessHourService.calculateTargetDate(1,startDateTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            caseRecord.InitialComplaintOutcome__c = CaseDecorator.CASE_INITIAL_CONTACT_SERVICE_RECOVERED;
            caseRecord.InitialComplaintDecision__c = 'Service Recovered';
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Date expectedDate = caseRecord.BreachOf4hrSLA__c ? businessHourService.calculateTargetDate(1,expectedDateTime).date() : expectedDateTime.date();
            Time expectedTime = Time.newInstance(9,0,0,0);
            expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            Assert.areEqual(expectedDateTime,caseRecord.SLAStartDate__c,'Both should be equal');
            Assert.areEqual(currentUserId,caseRecord.EscalatedToStage1By__c,'Both should be equal');
            Assert.isNotNull(caseRecord.Stage1RequestedDate__c,'It shouldnt be null');
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            update caseRecord;
            Datetime businessStartDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(businessStartDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartDateForManualStage1EscalatedDateAfter1PM(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(14,38,0,0));
            DateTime nextBusinessDayTime = businessHourService.getNextBusinessDay(startDateTime,CaseDecorator.COMPLAINTS_CASE_INITIAL_STAGE_SLA_BASELINE_HOUR); 
            DateTime initialComplaintSLABreachStartDateTime = businessHourService.add(nextBusinessDayTime,BusinessHourDecorator.FOUR_HOUR_IN_MILLISECONDS); 
            if (System.now() >= initialComplaintSLABreachStartDateTime) {
                startDateTime = initialComplaintSLABreachStartDateTime;
            }
            DateTime expectedDateTime = businessHourService.calculateTargetDate(1,startDateTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            caseRecord.InitialComplaintOutcome__c = CaseDecorator.CASE_INITIAL_CONTACT_SERVICE_RECOVERED;
            caseRecord.InitialComplaintDecision__c = 'Service Recovered';
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            Case fetchedCaseRecord = UthCase.get(caseRecord.Id);
            Date expectedDate = fetchedCaseRecord.BreachOf4hrSLA__c ? businessHourService.calculateTargetDate(1,expectedDateTime).date() : expectedDateTime.date();
            Time expectedTime = Time.newInstance(9,0,0,0);
            expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            Assert.areEqual(expectedDateTime,fetchedCaseRecord.SLAStartDate__c,'Both should be equal');
            Assert.areEqual((fetchedCaseRecord.BreachOf4hrSLA__c ? currentUserId : null),fetchedCaseRecord.EscalatedToStage1By__c,'Both should be equal');
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            update caseRecord;
            Datetime businessStartDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(businessStartDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartDateForManualStage1EscalatedDateAfterEndTime(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(22,38,0,0));
            DateTime nextBusinessDayTime = businessHourService.getNextBusinessDay(startDateTime,CaseDecorator.COMPLAINTS_CASE_INITIAL_STAGE_SLA_BASELINE_HOUR); 
            DateTime initialComplaintSLABreachStartDateTime = businessHourService.add(nextBusinessDayTime,BusinessHourDecorator.FOUR_HOUR_IN_MILLISECONDS); 
            if (System.now() >= initialComplaintSLABreachStartDateTime) {
                startDateTime = initialComplaintSLABreachStartDateTime;
            }
            DateTime expectedDateTime = businessHourService.calculateTargetDate(1,startDateTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            caseRecord.InitialComplaintOutcome__c = CaseDecorator.CASE_INITIAL_CONTACT_SERVICE_RECOVERED;
            caseRecord.InitialComplaintDecision__c = 'Service Recovered';
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            Case fetchedCaseRecord = UthCase.get(caseRecord.Id);
            Date expectedDate = caseRecord.BreachOf4hrSLA__c ? businessHourService.calculateTargetDate(1,expectedDateTime).date() : expectedDateTime.date();
            Time expectedTime = Time.newInstance(9,0,0,0);
            expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            Assert.areEqual(expectedDateTime,fetchedCaseRecord.SLAStartDate__c,'Both should be equal');
            Assert.areEqual((fetchedCaseRecord.BreachOf4hrSLA__c ? currentUserId : null),fetchedCaseRecord.EscalatedToStage1By__c,'Both should be equal');
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            update caseRecord;
            Datetime businessStartDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(businessStartDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartDateForManualStage2EscalatedDateBeforeStartTime(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(5,30,0,0));
            DateTime expectedDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Date expectedDate = expectedDateTime.date();
            Time expectedTime = businessHourService.getBusinessStartTime(expectedDateTime.format('EEEE').toLowerCase());
            expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = startDateTime;
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(startDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_TWO;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartDateForManualStage2EscalatedDateAtStartTime(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(9,0,0,0));
            DateTime expectedDateTime = businessHourService.getNextBusinessDay(System.now(),13);
            Date expectedDate = expectedDateTime.date();
            Time expectedTime = businessHourService.getBusinessStartTime(expectedDateTime.format('EEEE').toLowerCase());
            expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (caseRecord.StageOneEscalatedDate__c == null) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = startDateTime;
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(startDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_TWO;
            update caseRecord;
            Datetime businessStartDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(businessStartDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartDateForManualStage2EscalatedDateAfterStartTime(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(10,12,0,0));
            Date expectedDate = businessHourService.getNextBusinessDay(startDateTime,null).date();
            Time expectedTime = Time.newInstance(9,0,0,0);
            DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = startDateTime;
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(startDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_TWO;
            update caseRecord;
            Datetime businessStartDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(businessStartDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartDateForManualStage2EscalatedDateAt1PM(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(13,0,0,0));
            DateTime expectedDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            Date expectedDate = expectedDateTime.date();
            Time expectedTime = businessHourService.getBusinessStartTime(expectedDateTime.format('EEEE').toLowerCase());
            expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            UthCase.initializeComplaintInitialContactWithEscalatedOutcome(caseRecord,startDateTime);
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = startDateTime;
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime,caseRecord.SLAStartDate__c,'Both should be equal');
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_TWO;
            update caseRecord;
            Datetime businessStartDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(businessStartDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartDateForManualStage2EscalatedDateAfter1PM(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(14,38,0,0));
            DateTime expectedDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            Date expectedDate = expectedDateTime.date();
            Time expectedTime = businessHourService.getBusinessStartTime(expectedDateTime.format('EEEE').toLowerCase());
            expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            UthCase.initializeComplaintInitialContactWithEscalatedOutcome(caseRecord,startDateTime);
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = startDateTime;
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime,caseRecord.SLAStartDate__c,'Both should be equal');
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_TWO;
            update caseRecord;
            Datetime businessStartDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(businessStartDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
        }
    }

    @isTest
    static void testCalculateSLAStartDateForManualStage2EscalatedDateAfterEndTime(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(22,30,0,0));
            DateTime expectedDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            Date expectedDate = expectedDateTime.date();
            Time expectedTime = businessHourService.getBusinessStartTime(expectedDateTime.format('EEEE').toLowerCase());
            expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            UthCase.initializeComplaintInitialContactWithEscalatedOutcome(caseRecord,startDateTime);
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = startDateTime;
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime,caseRecord.SLAStartDate__c,'Both should be equal');
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_TWO;
            update caseRecord;
            Datetime businessStartDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(businessStartDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
        }
    }

    @isTest
    static void testCalculateOnHoldBreachDateTimeForStageOne(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(11,30,0,0));
            Datetime nextBusinessDayDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = DateTime.newInstance(
                businessHourService.calculateTargetDate(CaseDecorator.COMPLAINTS_CASE_STAGE_ONE_ON_HOLD_MAX_DAYS, nextBusinessDayDateTime).date(),
                System.now().time()
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            update caseRecord;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_IN_PROGRESS;
            update caseRecord;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_ON_HOLD;
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime.date(),caseRecord.OnHoldBreachDateTime__c.date(),'Both should be equal');
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_IN_PROGRESS;
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.isNull(caseRecord.OnHoldBreachDateTime__c,'It should be equal');
            Test.stopTest();        
        }
    }

    @isTest
    static void testCalculateOnHoldBreachDateTimeForStageTwo(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(11,30,0,0));
            Datetime nextBusinessDayDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = DateTime.newInstance(
                businessHourService.calculateTargetDate(CaseDecorator.COMPLAINTS_CASE_STAGE_TWO_ON_HOLD_MAX_DAYS, nextBusinessDayDateTime).date(),
                System.now().time()
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = startDateTime;
            update caseRecord;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_IN_PROGRESS;
            update caseRecord;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_ON_HOLD;
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime.date(),caseRecord.OnHoldBreachDateTime__c.date(),'Both should be equal');
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_IN_PROGRESS;
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.isNull(caseRecord.OnHoldBreachDateTime__c,'It should be equal');
            Test.stopTest();        
        }
    }

    @isTest
    static void testCalculateSLAStartDateForOmbudsman(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(14,38,0,0));
            DateTime expectedDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Date expectedDate = expectedDateTime.date();
            Time expectedTime = businessHourService.getBusinessStartTime(expectedDateTime.format('EEEE').toLowerCase());
            expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            UthCase.initializeComplaintInitialContactWithEscalatedOutcome(caseRecord,startDateTime);
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = startDateTime;
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_TWO;
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_OMBUDSMAN;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.OmbudsmanDeadlineDate__c = System.today().addDays(35);
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAStartDate__c.date(),'Both should be equal');
        }
    }

    @isTest
    static void testStage1AutoEscalation(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(5,30,0,0));
            Time expectedTime = Time.newInstance(13,0,0,0);
            DateTime expectedDateTime = DateTime.newInstance(startDateTime.date(),expectedTime);
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(expectedDateTime,caseRecord.StageOneEscalatedDate__c,'Both should be equal');
        }
    }

    @isTest
    static void testStage1ManualEscalation(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_CREATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(5,30,0,0));
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageOneEscalatedDate__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(startDateTime,caseRecord.StageOneEscalatedDate__c,'Both should be equal');
        }
    }
}