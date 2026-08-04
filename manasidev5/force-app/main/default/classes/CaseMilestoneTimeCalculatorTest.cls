@isTest(seeAllData=false)
public with sharing class CaseMilestoneTimeCalculatorTest {
    
    @testSetup
    static void setUpTestData(){

        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact; 

        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        insert tenancy;

        Entitlement complaintEntitlement = UthEntitlement.buildComplaintEntitlement(account.Id);
        insert complaintEntitlement;

        Entitlement moneyCoachingEntitlement = UthEntitlement.buildMoneyCoachingEntitlement(account.Id);
        insert moneyCoachingEntitlement;

        Entitlement tenancyCoachingEntitlement = UthEntitlement.buildTenancyCoachingEntitlement(account.Id);
        insert tenancyCoachingEntitlement;

        Entitlement changeEntitlement = UthEntitlement.buildChangeEntitlement(account.Id);
        insert changeEntitlement;

        Entitlement permissionEntitlement = UthEntitlement.buildPermissionEntitlement(account.Id);
        insert permissionEntitlement;

        Entitlement placeEntitlement = UthEntitlement.buildPlaceEntitlement(account.Id);
        insert placeEntitlement;

        Entitlement tenancyEntitlement = UthEntitlement.buildTenancyEntitlement(account.Id);
        insert tenancyEntitlement;

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
    }

    @isTest
    static void testComplaintCaseStage1AcknowledgementSLABeforeStartTime(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);   
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(5,30,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            DateTime stageOneAcknowledgementTargetDateTime = businessHourService.calculateTargetDate(6,nextBusinessStartDateTime);
            DateTime stageOneAcknowledgementTargetDate = DateTime.newInstance(
                stageOneAcknowledgementTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_ONE_ACKNOWLEDGEMENT);
            Assert.areEqual(stageOneAcknowledgementTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 1 acknowledgement target date');
        }
    }

    @isTest
    static void testComplaintCaseStage1AcknowledgementSLAAtStartTime(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);   
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(9,0,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            DateTime stageOneAcknowledgementTargetDateTime = businessHourService.calculateTargetDate(6,nextBusinessStartDateTime);
            DateTime stageOneAcknowledgementTargetDate = DateTime.newInstance(
                stageOneAcknowledgementTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_ONE_ACKNOWLEDGEMENT);
            Assert.areEqual(stageOneAcknowledgementTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 1 acknowledgement target date');
        }
    }

    @isTest
    static void testComplaintCaseStage1AcknowledgementSLAAfterStartTime(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);   
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(11,0,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            DateTime stageOneAcknowledgementTargetDateTime = businessHourService.calculateTargetDate(5,nextBusinessStartDateTime);
            DateTime stageOneAcknowledgementTargetDate = DateTime.newInstance(
                stageOneAcknowledgementTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_ONE_ACKNOWLEDGEMENT);
            Assert.areEqual(stageOneAcknowledgementTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 1 acknowledgement target date');
        }
    }

    @isTest
    static void testComplaintCaseStage1AcknowledgementSLAAt1PM(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(13,0,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            DateTime stageOneAcknowledgementTargetDateTime = null;
            DateTime stageOneAcknowledgementTargetDate = null;
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            UthCase.initializeComplaintInitialContactWithEscalatedOutcome(caseRecord,startDateTime);
            caseRecord.StageOneEscalatedDate__c = startDateTime;
            insert caseRecord;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            caseRecord.InitialComplaintOutcome__c = CaseDecorator.CASE_INITIAL_CONTACT_SERVICE_RECOVERED;
            caseRecord.InitialComplaintDecision__c = 'Service Recovered';
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            stageOneAcknowledgementTargetDateTime = businessHourService.calculateTargetDate(5,nextBusinessStartDateTime);
            stageOneAcknowledgementTargetDate = DateTime.newInstance(
                stageOneAcknowledgementTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_ONE_ACKNOWLEDGEMENT);
            Assert.areEqual(stageOneAcknowledgementTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 1 acknowledgement target date');
        }
    }

    @isTest
    static void testComplaintCaseStage1AcknowledgementSLAAfter1PM(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(15,22,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            DateTime stageOneAcknowledgementTargetDateTime = null;
            DateTime stageOneAcknowledgementTargetDate = null;
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            UthCase.initializeComplaintInitialContactWithEscalatedOutcome(caseRecord,startDateTime);
            caseRecord.StageOneEscalatedDate__c = startDateTime;
            insert caseRecord;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            caseRecord.InitialComplaintOutcome__c = CaseDecorator.CASE_INITIAL_CONTACT_SERVICE_RECOVERED;
            caseRecord.InitialComplaintDecision__c = 'Service Recovered';
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            stageOneAcknowledgementTargetDateTime = businessHourService.calculateTargetDate(5,nextBusinessStartDateTime);
            stageOneAcknowledgementTargetDate = DateTime.newInstance(
                stageOneAcknowledgementTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_ONE_ACKNOWLEDGEMENT); 
            Assert.areEqual(stageOneAcknowledgementTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 1 acknowledgement target date');
        }
    }

    @isTest
    static void testComplaintCaseStage1AcknowledgementSLAAfterEndTime(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(20,34,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            DateTime stageOneAcknowledgementTargetDateTime = null;
            DateTime stageOneAcknowledgementTargetDate = null;
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            UthCase.initializeComplaintInitialContactWithEscalatedOutcome(caseRecord,startDateTime);
            caseRecord.StageOneEscalatedDate__c = startDateTime;
            insert caseRecord;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            caseRecord.InitialComplaintOutcome__c = CaseDecorator.CASE_INITIAL_CONTACT_SERVICE_RECOVERED;
            caseRecord.InitialComplaintDecision__c = 'Service Recovered';
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            stageOneAcknowledgementTargetDateTime = businessHourService.calculateTargetDate(5,nextBusinessStartDateTime);
            stageOneAcknowledgementTargetDate = DateTime.newInstance(
                stageOneAcknowledgementTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_ONE_ACKNOWLEDGEMENT); 
            Assert.areEqual(stageOneAcknowledgementTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 1 acknowledgement target date');
        }
    }

    @isTest
    static void testComplaintCaseStage1ResolutionSLABeforeStartTime(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);   
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(5,30,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Time businessHourStartTime = businessHourService.getBusinessStartTime(nextBusinessStartDateTime.format('EEEE').toLowerCase());
            DateTime SlaStartDateTime = DateTime.newInstance(
                nextBusinessStartDateTime.date(),
                businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
            );
            DateTime stageOneResolutionTargetDateTime = businessHourService.calculateTargetDate(10,SlaStartDateTime);
            DateTime stageOneResolutionTargetDate = DateTime.newInstance(
                stageOneResolutionTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            caseRecord.StageOneEscalatedDate__c = startDateTime;
            insert caseRecord;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            caseRecord.InitialComplaintOutcome__c = CaseDecorator.CASE_INITIAL_CONTACT_SERVICE_RECOVERED;
            caseRecord.InitialComplaintDecision__c = 'Service Recovered';
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_ONE_RESOLUTION); 
            Assert.areEqual(stageOneResolutionTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 1 resolution target date');
        }
    }

    @isTest
    static void testComplaintCaseStage1ResolutionSLAAtStartTime(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);   
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(9,0,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Time businessHourStartTime = businessHourService.getBusinessStartTime(nextBusinessStartDateTime.format('EEEE').toLowerCase());
            DateTime SlaStartDateTime = DateTime.newInstance(
                nextBusinessStartDateTime.date(),
                businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
            );
            DateTime stageOneResolutionTargetDateTime = businessHourService.calculateTargetDate(10,SlaStartDateTime);
            DateTime stageOneResolutionTargetDate = DateTime.newInstance(
                stageOneResolutionTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            caseRecord.StageOneEscalatedDate__c = startDateTime;
            insert caseRecord;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            caseRecord.InitialComplaintOutcome__c = CaseDecorator.CASE_INITIAL_CONTACT_SERVICE_RECOVERED;
            caseRecord.InitialComplaintDecision__c = 'Service Recovered';
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_ONE_RESOLUTION); 
            Assert.areEqual(stageOneResolutionTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 1 resolution target date');
        }
    }

    @isTest
    static void testComplaintCaseStage1ResolutionSLAAfterStartTime(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);   
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(10,43,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Time businessHourStartTime = businessHourService.getBusinessStartTime(nextBusinessStartDateTime.format('EEEE').toLowerCase());
            DateTime SlaStartDateTime = DateTime.newInstance(
                nextBusinessStartDateTime.date(),
                businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
            );
            DateTime stageOneResolutionTargetDateTime = businessHourService.calculateTargetDate(10,SlaStartDateTime);
            DateTime stageOneResolutionTargetDate = DateTime.newInstance(
                stageOneResolutionTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            caseRecord.StageOneEscalatedDate__c = startDateTime;
            insert caseRecord;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            caseRecord.InitialComplaintOutcome__c = CaseDecorator.CASE_INITIAL_CONTACT_SERVICE_RECOVERED;
            caseRecord.InitialComplaintDecision__c = 'Service Recovered';
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageOneEscalatedDate__c = startDateTime;
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_ONE_RESOLUTION);
            Assert.areEqual(stageOneResolutionTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 1 resolution target date');
        }
    }

    @isTest
    static void testComplaintCaseStage1ResolutionSLAAt1PM(){     
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
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Time businessHourStartTime = businessHourService.getBusinessStartTime(nextBusinessStartDateTime.format('EEEE').toLowerCase());
            DateTime SlaStartDateTime = DateTime.newInstance(
                nextBusinessStartDateTime.date(),
                businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
            );
            DateTime stageOneResolutionTargetDateTime = null;
            DateTime stageOneResolutionTargetDate = null;
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            UthCase.initializeComplaintInitialContactWithEscalatedOutcome(caseRecord,startDateTime);
            insert caseRecord;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            caseRecord.InitialComplaintOutcome__c = CaseDecorator.CASE_INITIAL_CONTACT_SERVICE_RECOVERED;
            caseRecord.InitialComplaintDecision__c = 'Service Recovered';
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            caseRecord.StageOneEscalatedDate__c = startDateTime;
            stageOneResolutionTargetDateTime = businessHourService.calculateTargetDate(10,SlaStartDateTime);
            stageOneResolutionTargetDate = DateTime.newInstance(
                stageOneResolutionTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_ONE_RESOLUTION); 
            Assert.areEqual(stageOneResolutionTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 1 resolution target date');
        }
    }

    @isTest
    static void testComplaintCaseStage1ResolutionSLAAfter1PM(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(16,12,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Time businessHourStartTime = businessHourService.getBusinessStartTime(nextBusinessStartDateTime.format('EEEE').toLowerCase());
            DateTime SlaStartDateTime = DateTime.newInstance(
                nextBusinessStartDateTime.date(),
                businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
            );
            DateTime stageOneResolutionTargetDateTime = null;
            DateTime stageOneResolutionTargetDate = null;
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            UthCase.initializeComplaintInitialContactWithEscalatedOutcome(caseRecord,startDateTime);
            insert caseRecord;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            caseRecord.InitialComplaintOutcome__c = CaseDecorator.CASE_INITIAL_CONTACT_SERVICE_RECOVERED;
            caseRecord.InitialComplaintDecision__c = 'Service Recovered';
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            caseRecord.StageOneEscalatedDate__c = startDateTime;
            stageOneResolutionTargetDateTime = businessHourService.calculateTargetDate(10,SlaStartDateTime);
            stageOneResolutionTargetDate = DateTime.newInstance(
                stageOneResolutionTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_ONE_RESOLUTION); 
            Assert.areEqual(stageOneResolutionTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 1 resolution target date');
        }
    }

    @isTest
    static void testComplaintCaseStage1ResolutionSLAAfterEndTime(){     
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            Test.startTest();        
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(22,37,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Time businessHourStartTime = businessHourService.getBusinessStartTime(nextBusinessStartDateTime.format('EEEE').toLowerCase());
            DateTime SlaStartDateTime = DateTime.newInstance(
                nextBusinessStartDateTime.date(),
                businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
            );
            DateTime stageOneResolutionTargetDateTime = null;
            DateTime stageOneResolutionTargetDate = null;
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            insert caseRecord;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            caseRecord.InitialComplaintOutcome__c = CaseDecorator.CASE_INITIAL_CONTACT_SERVICE_RECOVERED;
            caseRecord.InitialComplaintDecision__c = 'Service Recovered';
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            caseRecord.StageOneEscalatedDate__c = startDateTime;
            stageOneResolutionTargetDateTime = businessHourService.calculateTargetDate(10,SlaStartDateTime);
            stageOneResolutionTargetDate = DateTime.newInstance(
                stageOneResolutionTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_ONE_RESOLUTION);
            Assert.areEqual(stageOneResolutionTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 1 resolution target date');
        }
    }

    @isTest
    static void testComplaintCaseStage2AcknowledgementSLABeforeStartTime(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);   
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(5,30,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            DateTime stageTwoAcknowledgementTargetDateTime = businessHourService.calculateTargetDate(5,nextBusinessStartDateTime);
            DateTime stageTwoAcknowledgementTargetDate = DateTime.newInstance(
                stageTwoAcknowledgementTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id); 
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = startDateTime;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_TWO_ACKNOWLEDGEMENT);
            Assert.areEqual(stageTwoAcknowledgementTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 2 acknowledgement target date');
        }
    }

    @isTest
    static void testComplaintCaseStage2AcknowledgementSLAAtStartTime(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);   
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(9,0,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            DateTime stageTwoAcknowledgementTargetDateTime = businessHourService.calculateTargetDate(5,nextBusinessStartDateTime);
            DateTime stageTwoAcknowledgementTargetDate = DateTime.newInstance(
                stageTwoAcknowledgementTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            caseRecord.InitialComplaintOutcome__c =  CaseDecorator.INITIAL_COMPLAINT_OUTCOME_ESCALATED;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = startDateTime;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_TWO_ACKNOWLEDGEMENT);
            Assert.areEqual(stageTwoAcknowledgementTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 2 acknowledgement target date');
        }
    }

    @isTest
    static void testComplaintCaseStage2AcknowledgementSLAAfterStartTime(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);   
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(11,18,0,0));
            DateTime nextBusinessStartDateTime = businessHourService.getNextBusinessDay(startDateTime,13);
            DateTime stageTwoAcknowledgementTargetDateTime = businessHourService.calculateTargetDate(4,nextBusinessStartDateTime);
            DateTime stageTwoAcknowledgementTargetDate = DateTime.newInstance(
                stageTwoAcknowledgementTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = startDateTime;
            }
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = startDateTime;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_TWO_ACKNOWLEDGEMENT);
            Assert.areEqual(stageTwoAcknowledgementTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 2 acknowledgement target date');
        }
    }

    @isTest
    static void testComplaintCaseStage2AcknowledgementSLAAt1PM(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(13,0,0,0));
            DateTime stageTwoAcknowledgementTargetDateTime = businessHourService.calculateTargetDate(5,startDateTime);
            DateTime stageTwoAcknowledgementTargetDate = DateTime.newInstance(
                stageTwoAcknowledgementTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            DateTime stageOneAcknowledgementTargetDate = null;
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
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = startDateTime;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_TWO_ACKNOWLEDGEMENT); 
            Assert.areEqual(stageTwoAcknowledgementTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 2 acknowledgement target date');
        }
    }

    @isTest
    static void testComplaintCaseStage2AcknowledgementSLAAfter1PM(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(14,51,0,0));
            DateTime stageTwoAcknowledgementTargetDateTime = businessHourService.calculateTargetDate(5,startDateTime);
            DateTime stageTwoAcknowledgementTargetDate = DateTime.newInstance(
                stageTwoAcknowledgementTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            DateTime stageOneAcknowledgementTargetDate = null;
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
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = startDateTime;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_TWO_ACKNOWLEDGEMENT); 
            Assert.areEqual(stageTwoAcknowledgementTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 2 acknowledgement target date');
        }
    }

    @isTest
    static void testComplaintCaseStage2AcknowledgementSLAAfterEndTime(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(20,20,0,0));
            DateTime stageTwoAcknowledgementTargetDateTime = businessHourService.calculateTargetDate(5,startDateTime);
            DateTime stageTwoAcknowledgementTargetDate = DateTime.newInstance(
                stageTwoAcknowledgementTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            DateTime stageOneAcknowledgementTargetDate = null;
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
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE;
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = startDateTime;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_TWO_ACKNOWLEDGEMENT);
            Assert.areEqual(stageTwoAcknowledgementTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 2 acknowledgement target date');
        }
    }

    @isTest
    static void testComplaintCaseStage2ResolutionSLABeforeStartTime(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);   
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(5,30,0,0));
            Datetime nextBusinessDayDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Time businessHourStartTime = businessHourService.getBusinessStartTime(nextBusinessDayDateTime.format('EEEE').toLowerCase());
            DateTime slaStartDateTime = DateTime.newInstance(
                nextBusinessDayDateTime.date(),
                businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
            );
            DateTime stageTwoResolutionTargetDateTime = businessHourService.calculateTargetDate(20,slaStartDateTime);
            DateTime stageTwoResolutionTargetDate = DateTime.newInstance(
                stageTwoResolutionTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll(); 
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            insert caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = startDateTime; 
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_TWO;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_TWO_RESOLUTION); 
            Assert.areEqual(stageTwoResolutionTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 2 resolution target date');
        }
    }

    @isTest
    static void testComplaintCaseStage2ResolutionSLAtStartTime(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);   
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(9,0,0,0));
            Datetime nextBusinessDayDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Time businessHourStartTime = businessHourService.getBusinessStartTime(nextBusinessDayDateTime.format('EEEE').toLowerCase());
            DateTime slaStartDateTime = DateTime.newInstance(
                nextBusinessDayDateTime.date(),
                businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
            );
            DateTime stageTwoResolutionTargetDateTime = businessHourService.calculateTargetDate(20,slaStartDateTime);
            DateTime stageTwoResolutionTargetDate = DateTime.newInstance(
                stageTwoResolutionTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = startDateTime;
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_TWO;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_TWO_RESOLUTION); 
            Assert.areEqual(stageTwoResolutionTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 2 resolution target date');
        }
    }

    @isTest
    static void testComplaintCaseStage2ResolutionSLAfterStartTime(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);  
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(11,23,0,0));
            Datetime nextBusinessDayDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Time businessHourStartTime = businessHourService.getBusinessStartTime(nextBusinessDayDateTime.format('EEEE').toLowerCase());
            DateTime slaStartDateTime = DateTime.newInstance(
                nextBusinessDayDateTime.date(),
                businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
            );
            DateTime stageTwoResolutionTargetDateTime = businessHourService.calculateTargetDate(20,slaStartDateTime);
            DateTime stageTwoResolutionTargetDate = DateTime.newInstance(
                stageTwoResolutionTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = startDateTime;
            insert caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = startDateTime;
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_TWO;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_TWO_RESOLUTION);
            Assert.areEqual(stageTwoResolutionTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 2 resolution target date');
        }
    }

    @isTest
    static void testComplaintCaseStage2ResolutionSLAt1PM(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);   
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(13,0,0,0));
            Datetime nextBusinessDayDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Time businessHourStartTime = businessHourService.getBusinessStartTime(nextBusinessDayDateTime.format('EEEE').toLowerCase());
            DateTime slaStartDateTime = DateTime.newInstance(
                nextBusinessDayDateTime.date(),
                businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
            );
            DateTime stageTwoResolutionTargetDateTime = businessHourService.calculateTargetDate(20,slaStartDateTime);
            DateTime stageTwoResolutionTargetDate = DateTime.newInstance(
                stageTwoResolutionTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
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
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_TWO;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_TWO_RESOLUTION);
            Assert.areEqual(stageTwoResolutionTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 2 resolution target date');
        }
    }

    @isTest
    static void testComplaintCaseStage2ResolutionSLAfter1PM(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);  
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(15,29,0,0));
            Datetime nextBusinessDayDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Time businessHourStartTime = businessHourService.getBusinessStartTime(nextBusinessDayDateTime.format('EEEE').toLowerCase());
            DateTime slaStartDateTime = DateTime.newInstance(
                nextBusinessDayDateTime.date(),
                businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
            );
            DateTime stageTwoResolutionTargetDateTime = businessHourService.calculateTargetDate(20,slaStartDateTime);
            DateTime stageTwoResolutionTargetDate = DateTime.newInstance(
                stageTwoResolutionTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
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
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_TWO;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_TWO_RESOLUTION);
            Assert.areEqual(stageTwoResolutionTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 2 resolution target date');
        }
    }

    @isTest
    static void testComplaintCaseStage2ResolutionSLAfterEndTime(){     
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
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);   
            DateTime startDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(21,57,0,0));
            Datetime nextBusinessDayDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Time businessHourStartTime = businessHourService.getBusinessStartTime(nextBusinessDayDateTime.format('EEEE').toLowerCase());
            DateTime slaStartDateTime = DateTime.newInstance(
                nextBusinessDayDateTime.date(),
                businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
            );
            DateTime stageTwoResolutionTargetDateTime = businessHourService.calculateTargetDate(20,slaStartDateTime);
            DateTime stageTwoResolutionTargetDate = DateTime.newInstance(
                stageTwoResolutionTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
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
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_TWO;
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_STAGE_TWO_RESOLUTION);
            Assert.areEqual(stageTwoResolutionTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to stage 2 resolution target date');
        }
    }

    @isTest
    static void testComplaintCaseOmbudsman(){     
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
            Test.startTest();      
            BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);   
            Datetime startDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            DateTime previousDaystartDateTime = DateTime.newInstance(businessHourService.calculatePreviousTargetDate(-1,System.now()).date(),Time.newInstance(21,57,0,0));
            Datetime nextBusinessDayDateTime = businessHourService.getNextBusinessDay(System.now(),null);
            Time businessHourStartTime = businessHourService.getBusinessStartTime(System.now().format('EEEE').toLowerCase());
            DateTime slaStartDateTime = DateTime.newInstance(
                nextBusinessDayDateTime.date(),
                businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
            );
            DateTime ombudsmanTargetDateTime = businessHourService.calculateTargetDate(35,slaStartDateTime);
            DateTime ombudsmanTargetDate = DateTime.newInstance(
                ombudsmanTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            DateTime expetectedOmbudsmanMilestoneTargetDateTime = businessHourService.calculateTargetDate(35,slaStartDateTime);
            DateTime expetectedOmbudsmanMilestoneTargetDate = DateTime.newInstance(
                expetectedOmbudsmanMilestoneTargetDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildComplaintCase(contactsList[0].Id);
            caseRecord.OriginalReceivedDateTime__c = System.now().addDays(-6);
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            if (!caseRecord.BreachOf4hrSLA__c) {
                caseRecord.StageOneEscalatedDate__c = previousDaystartDateTime;
            }
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.StageTwoEscalatedDate__c = previousDaystartDateTime;
            caseRecord.AcknowledgementSentFor__c = CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_TWO;
            update caseRecord;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_OMBUDSMAN;
            caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
            caseRecord.OmbudsmanDeadlineDate__c = ombudsmanTargetDate.date();
            update caseRecord;
            Test.stopTest();        
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_OMBUDSMAN);
            Assert.areEqual(expetectedOmbudsmanMilestoneTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to ombudsman deadline date');
        }
    }

    @isTest
    static void testMoneyCoachingCaseOnHighPriority(){   
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MONEY_COACHING_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MONEY_COACHING_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();        
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.MONEY_COACHING_CASE_HIGH_PRIORITY_DAYS,
                nextBusinessDay
            );
            DateTime slaTargetDateTime = DateTime.newInstance(
                expectedDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildMoneyCoachingCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_HIGH;
            insert caseRecord;
            caseRecord.OwnerId = UserInfo.getUserId();
            update caseRecord;
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT);
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testMoneyCoachingCaseOnLowPriority(){   
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MONEY_COACHING_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MONEY_COACHING_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();        
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.MONEY_COACHING_CASE_LOW_PRIORITY_DAYS,
                nextBusinessDay
            );
            DateTime slaTargetDateTime = DateTime.newInstance(
                expectedDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildMoneyCoachingCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_LOW;
            insert caseRecord;
            caseRecord.OwnerId = UserInfo.getUserId();
            update caseRecord;
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT);
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }       
    }

    @isTest
    static void testTenancyCoachingCaseOnUrgentPriority(){   
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
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
            DateTime slaTargetDateTime = DateTime.newInstance(
                expectedDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildTenancyCoachingCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_URGENT;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT);
            //Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testTenancyCoachingCaseOnRoutinePriority(){   
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
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
            DateTime slaTargetDateTime = DateTime.newInstance(
                expectedDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildTenancyCoachingCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_ROUTINE;
            insert caseRecord;
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT);
            //Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testTenancyCoachingCaseOnTriageStatusWithDefaultResolutionDate(){   
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
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildTenancyCoachingCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_URGENT;
            insert caseRecord;
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(CaseDecorator.TENANCY_COACHING_CASE_RESOLUTION_DAYS,nextBusinessDay);
            DateTime slaTargetDateTime = DateTime.newInstance(expectedDateTime.date(),Time.newInstance(17,0,0,0));
            caseRecord.Status = CaseDecorator.STATUS_TRIAGE;
            update caseRecord;
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION);
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }


    @isTest
    static void testTenancyCoachingCaseOnCompletingFirstContactAttempt(){   
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
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildTenancyCoachingCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_URGENT;
            insert caseRecord;
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(10,nextBusinessDay);
            DateTime slaTargetDateTime = DateTime.newInstance(expectedDateTime.date(),Time.newInstance(17,0,0,0));
            caseRecord.CompletedMilestones__c = CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT;
            update caseRecord;
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT); 
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testTenancyCoachingCaseOnTriageStatusWithResolutionDate(){   
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
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildTenancyCoachingCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_URGENT;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            DateTime resolutionTargetDate = businessHourService.calculateTargetDate(
                CaseDecorator.TENANCY_COACHING_CASE_RESOLUTION_DAYS,
                caseRecord.SLAStartDate__c
            );
            DateTime slaResolutionTargetDate = businessHourService.calculateTargetDate(
                80,
                caseRecord.SLAStartDate__c
            );
            DateTime slaTargetDateTime = DateTime.newInstance(slaResolutionTargetDate.date(),Time.newInstance(17,0,0,0));
            caseRecord.ResolutionTargetDate__c = resolutionTargetDate.date();
            caseRecord.Status = CaseDecorator.STATUS_TRIAGE;
            update caseRecord;
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION);
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testTenancyCoachingCaseOnCompletingCustomerContact(){   
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
            List<Contact> contactsList = UthContact.getAll();
            Case caseRecord = UthCase.buildTenancyCoachingCase(contactsList[0].Id);
            caseRecord.Priority = CaseDecorator.PRIORITY_URGENT;
            insert caseRecord;
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(10,nextBusinessDay);
            DateTime slaTargetDateTime = DateTime.newInstance(expectedDateTime.date(),Time.newInstance(17,0,0,0));
            caseRecord.CompletedMilestones__c = CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT;
            update caseRecord;
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT);
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testChangesCaseFirstContactAttemptMilestone(){   
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();        
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                5,
                nextBusinessDay
            );
            DateTime slaTargetDateTime = DateTime.newInstance(
                expectedDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            List<YH_Tenancy__c> tenancyList = UthTenancy.getAll();
            Entitlement entitlement = UthEntitlement.get(EntitlementDecorator.CHANGES_ENTITLEMENT_PROCESS_NAME);
            Case caseRecord = UthCase.buildChangesCase(contactsList[0].Id);
            caseRecord.Status = CaseDecorator.STATUS_NEW;
            caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_SOLE_TO_JOINT;
            caseRecord.EntitlementId = entitlement.Id;
            caseRecord.Tenancy__c = tenancyList[0].Id;
            caseRecord.BusinessHoursId = businessHourService.businessHour.Id;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT);
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testChangesCaseResolutionMutualExchangeMilestone(){   
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();        
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            Integer numberOfDaysToAdd = CaseDecorator.CASE_MUTUALEXCHANGE_RESOLUTION_DAYS;
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                numberOfDaysToAdd,
                nextBusinessDay
            );
            DateTime slaTargetDateTime = DateTime.newInstance(
                expectedDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            List<YH_Tenancy__c> tenancyList = UthTenancy.getAll();
            Entitlement entitlement = UthEntitlement.get(EntitlementDecorator.CHANGES_ENTITLEMENT_PROCESS_NAME);
            Case caseRecord = UthCase.buildChangesCase(contactsList[0].Id,CaseDecorator.CASE_TYPE_MUTUAL_EXCHANGE,UthTenancy.getAll()[0].Id);
            caseRecord.Status = CaseDecorator.STATUS_NEW;
            caseRecord.EntitlementId = entitlement.Id;
            caseRecord.Tenancy__c = tenancyList[0].Id;
            caseRecord.BusinessHoursId = businessHourService.businessHour.Id;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION);
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }
    
    @isTest
    static void testChangesCaseResolutionMutualExchangeDecisionMilestone(){   
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.SEVEN_DAYS_NO_HOLIDAY_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();        
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            Integer numberOfDaysToAdd = CaseDecorator.CASE_MUTUALEXCHANGE_DECISION_DAYS;
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                numberOfDaysToAdd,
                nextBusinessDay
            );
            DateTime slaTargetDateTime = DateTime.newInstance(
                expectedDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            List<YH_Tenancy__c> tenancyList = UthTenancy.getAll();
            Entitlement entitlement = UthEntitlement.get(EntitlementDecorator.CHANGES_ENTITLEMENT_PROCESS_NAME);
            Case caseRecord = UthCase.buildChangesCase(contactsList[0].Id,CaseDecorator.CASE_TYPE_MUTUAL_EXCHANGE,UthTenancy.getAll()[0].Id);
            caseRecord.Status = CaseDecorator.STATUS_NEW;
            caseRecord.EntitlementId = entitlement.Id;
            caseRecord.Tenancy__c = tenancyList[0].Id;
            caseRecord.BusinessHoursId = businessHourService.businessHour.Id;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_MUTUALEXCHANGEDECISION);
            // ToDo - failing over the weekends and needs to be fixed
            //Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testChangesCaseCustomerContactMilestone(){   
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();        
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                10,
                nextBusinessDay
            );
            DateTime slaTargetDateTime = DateTime.newInstance(
                expectedDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            List<YH_Tenancy__c> tenancyList = UthTenancy.getAll();
            Entitlement entitlement = UthEntitlement.get(EntitlementDecorator.CHANGES_ENTITLEMENT_PROCESS_NAME);
            Case caseRecord = UthCase.buildChangesCase(contactsList[0].Id);
            caseRecord.Status = CaseDecorator.STATUS_NEW;
            caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_SOLE_TO_JOINT;
            caseRecord.EntitlementId = entitlement.Id;
            caseRecord.Tenancy__c = tenancyList[0].Id;
            caseRecord.BusinessHoursId = businessHourService.businessHour.Id;
            insert caseRecord;
            caseRecord.CompletedMilestones__c = CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT;
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT);
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testPermissionCaseFirstContactAttemptMilestone(){   
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PERMISSION_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PERMISSION_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();        
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                5,
                nextBusinessDay
            );
            DateTime slaTargetDateTime = DateTime.newInstance(
                expectedDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Entitlement entitlement = UthEntitlement.get(EntitlementDecorator.PERMISSION_ENTITLEMENT_PROCESS_NAME);
            YH_Tenancy__c tenancy = UthTenancy.getAll().get(0);
            Case caseRecord = UthCase.buildPermissionCase(contactsList[0].Id, tenancy.Id);
            caseRecord.Status = CaseDecorator.STATUS_NEW;
            caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_PERMISSION_FOR_A_LoDGER_OR_SUBLET;
            caseRecord.EntitlementId = entitlement.Id;
            caseRecord.BusinessHoursId = businessHourService.businessHour.Id;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT);
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testPermissionCaseCustomerContactMilestone(){   
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PERMISSION_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PERMISSION_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();        
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                10,
                nextBusinessDay
            );
            DateTime slaTargetDateTime = DateTime.newInstance(
                expectedDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            YH_Tenancy__c tenancy = UthTenancy.getAll().get(0);
            Entitlement entitlement = UthEntitlement.get(EntitlementDecorator.PERMISSION_ENTITLEMENT_PROCESS_NAME);
            Case caseRecord = UthCase.buildPermissionCase(contactsList[0].Id, tenancy.Id);
            caseRecord.Status = CaseDecorator.STATUS_NEW;
            caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_PERMISSION_FOR_A_LoDGER_OR_SUBLET;
            caseRecord.EntitlementId = entitlement.Id;
            caseRecord.BusinessHoursId = businessHourService.businessHour.Id;
            insert caseRecord;
            caseRecord.CompletedMilestones__c = CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT;
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT);
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testPlaceCaseFirstContactAttemptMilestone(){   
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();        
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                5,
                nextBusinessDay
            );
            DateTime slaTargetDateTime = DateTime.newInstance(
                expectedDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Entitlement entitlement = UthEntitlement.get(EntitlementDecorator.PLACE_ENTITLEMENT_PROCESS_NAME);
            Case caseRecord = UthCase.buildPlaceCase(contactsList[0].Id);
            caseRecord.Status = CaseDecorator.STATUS_NEW;
            caseRecord.EntitlementId = entitlement.Id;
            caseRecord.BusinessHoursId = businessHourService.businessHour.Id;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT);
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testPlaceCaseCustomerContactMilestone(){   
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();        
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                10,
                nextBusinessDay
            );
            DateTime slaTargetDateTime = DateTime.newInstance(
                expectedDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Entitlement entitlement = UthEntitlement.get(EntitlementDecorator.PLACE_ENTITLEMENT_PROCESS_NAME);
            Case caseRecord = UthCase.buildPlaceCase(contactsList[0].Id);
            caseRecord.Status = CaseDecorator.STATUS_NEW;
            caseRecord.EntitlementId = entitlement.Id;
            caseRecord.BusinessHoursId = businessHourService.businessHour.Id;
            insert caseRecord;
            caseRecord.CompletedMilestones__c = CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT;
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT);
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testTenancyCaseFirstContactAttemptMilestone(){   
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();        
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                5,
                nextBusinessDay
            );
            DateTime slaTargetDateTime = DateTime.newInstance(
                expectedDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Entitlement entitlement = UthEntitlement.get(EntitlementDecorator.TENANCY_ENTITLEMENT_PROCESS_NAME);
            Case caseRecord = UthCase.buildTenancyCase(contactsList[0].Id);
            caseRecord.Status = CaseDecorator.STATUS_NEW;
            caseRecord.EntitlementId = entitlement.Id;
            caseRecord.BusinessHoursId = businessHourService.businessHour.Id;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT);
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testTenancyDecantCaseFirstContactAttemptMilestone(){   
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();        
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                1,
                nextBusinessDay
            );
            DateTime slaTargetDateTime = DateTime.newInstance(
                expectedDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Entitlement entitlement = UthEntitlement.get(EntitlementDecorator.TENANCY_ENTITLEMENT_PROCESS_NAME);
            Case caseRecord = UthCase.buildTenancyCaseWithCaseType(contactsList[0].Id, CaseDecorator.CASETYPE_DECANT);
            caseRecord.Status = CaseDecorator.STATUS_NEW;
            caseRecord.EntitlementId = entitlement.Id;
            caseRecord.BusinessHoursId = businessHourService.businessHour.Id;
            insert caseRecord;
            caseRecord.DecantType__c = CaseDecorator.TENANCY_DECANT_CASE_TYPE_TEMPORARY;
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT);
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testTenancyCaseCustomerContactMilestone(){   
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();        
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                10,
                nextBusinessDay
            );
            DateTime slaTargetDateTime = DateTime.newInstance(
                expectedDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Entitlement entitlement = UthEntitlement.get(EntitlementDecorator.TENANCY_ENTITLEMENT_PROCESS_NAME);
            Case caseRecord = UthCase.buildTenancyCase(contactsList[0].Id);
            caseRecord.Status = CaseDecorator.STATUS_NEW;
            caseRecord.EntitlementId = entitlement.Id;
            caseRecord.BusinessHoursId = businessHourService.businessHour.Id;
            caseRecord.DecantType__c = CaseDecorator.TENANCY_DECANT_CASE_TYPE_TEMPORARY;
            insert caseRecord;
            caseRecord.CompletedMilestones__c = CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT;
            update caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT);
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testPermissionCaseResolutionMilestone(){   
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PERMISSION_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PERMISSION_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();        
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                20,
                nextBusinessDay
            );
            DateTime slaTargetDateTime = DateTime.newInstance(
                expectedDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Entitlement entitlement = UthEntitlement.get(EntitlementDecorator.PERMISSION_ENTITLEMENT_PROCESS_NAME);
            YH_Tenancy__c tenancy = UthTenancy.getAll().get(0);
            Case caseRecord = UthCase.buildPermissionCase(contactsList[0].Id, tenancy.Id);
            caseRecord.Status = CaseDecorator.STATUS_NEW;
            caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_PERMISSION_FOR_A_LoDGER_OR_SUBLET;
            caseRecord.EntitlementId = entitlement.Id;
            caseRecord.BusinessHoursId = businessHourService.businessHour.Id;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION);
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testTenancyCaseResolutionMilestone(){   
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();        
            DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
            DateTime expectedDateTime = businessHourService.calculateTargetDate(
                CaseDecorator.TENANCY_CASE_60_RESOLUTION_DAYS,
                nextBusinessDay
            );
            DateTime slaTargetDateTime = DateTime.newInstance(
                expectedDateTime.date(),
                Time.newInstance(17,0,0,0)
            );
            List<Contact> contactsList = UthContact.getAll();
            Entitlement entitlement = UthEntitlement.get(EntitlementDecorator.TENANCY_ENTITLEMENT_PROCESS_NAME);
            Case caseRecord = UthCase.buildTenancyCase(contactsList[0].Id);
            caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_UNAUTHORISED_OCCUPIER;
            caseRecord.Status = CaseDecorator.STATUS_NEW;
            caseRecord.EntitlementId = entitlement.Id;
            caseRecord.BusinessHoursId = businessHourService.businessHour.Id;
            caseRecord.DecantType__c = CaseDecorator.TENANCY_DECANT_CASE_TYPE_TEMPORARY;
            insert caseRecord;
            caseRecord = UthCase.get(caseRecord.Id);
            Test.stopTest();        
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION);
            Assert.areEqual(slaTargetDateTime,caseMilestontesList[0].TargetDate,'Target Date must be equal to sla target date');
        }
    }

    @isTest
    static void testMSisBeignCreated(){
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        CaseMilestoneTimeCalculator cmtc = new CaseMilestoneTimeCalculator();
        cmtc.caseMilestoneRec = null;

        CaseMilestoneTimeCalculator.MILESTONE_ACTION action;

        Test.startTest();
            action = cmtc.getNextAction();
        Test.stopTest();

        Assert.areEqual(CaseMilestoneTimeCalculator.MILESTONE_ACTION.MS_IS_BEING_CREATED, action,'Action should be MS_IS_BEING_CREATED');
    }

    @isTest
    static void testStartDateNotSynced(){
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id caseMilestoneRecId = TriggerTestUtility.getFakeId(CaseMilestone.SObjectType);
        
        CaseMilestoneTimeCalculator cmtc = new CaseMilestoneTimeCalculator();
        cmtc.caseRec = new Case(Id = caseRecId);
        cmtc.caseMilestoneRec = new CaseMilestone(Id = caseMilestoneRecId);

        CaseMilestoneTimeCalculator.MILESTONE_ACTION action;

        Test.startTest();
            action = cmtc.getNextAction();
        Test.stopTest();
        
        Assert.areEqual(CaseMilestoneTimeCalculator.MILESTONE_ACTION.STARTDATE_NOT_SYNCHED, action,'Action should be STARTDATE_NOT_SYNCHED');
    }

    @isTest
    static void testStartDateSyncedButDurationNotCalc(){
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id caseMilestoneRecId = TriggerTestUtility.getFakeId(CaseMilestone.SObjectType);
        
        CaseMilestoneTimeCalculator cmtc = new CaseMilestoneTimeCalculator();
        cmtc.caseRec = new Case(Id = caseRecId, MSIdsStartDateSynched__c = caseMilestoneRecId);
        cmtc.caseMilestoneRec = new CaseMilestone(Id = caseMilestoneRecId);

        CaseMilestoneTimeCalculator.MILESTONE_ACTION action;

        Test.startTest();
            action = cmtc.getNextAction();
        Test.stopTest();
        
        Assert.areEqual(CaseMilestoneTimeCalculator.MILESTONE_ACTION.STARTDATE_SYNCHED_BUT_DURATION_NOT_CALC, action,'Action should be STARTDATE_SYNCHED_BUT_DURATION_NOT_CALC');
    }

    @isTest
    static void testStartDateSyncedAndDurationCalc(){
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id caseMilestoneRecId = TriggerTestUtility.getFakeId(CaseMilestone.SObjectType);
        
        CaseMilestoneTimeCalculator cmtc = new CaseMilestoneTimeCalculator();
        cmtc.caseRec = new Case(Id = caseRecId, MSIdsStartDateSynched__c = caseMilestoneRecId, MSIdsDurationCalculated__c = caseMilestoneRecId);
        cmtc.caseMilestoneRec = new CaseMilestone(Id = caseMilestoneRecId);

        CaseMilestoneTimeCalculator.MILESTONE_ACTION action;

        Test.startTest();
            action = cmtc.getNextAction();
        Test.stopTest();
        
        Assert.areEqual(CaseMilestoneTimeCalculator.MILESTONE_ACTION.STARTDATE_SYNCHED_AND_DURATION_CALC, action,'Action should be STARTDATE_SYNCHED_AND_DURATION_CALC');
    }

    @isTest
    static void testcreatePlatfromEvent(){
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id caseMilestoneRecId = TriggerTestUtility.getFakeId(CaseMilestone.SObjectType);
        
        CaseMilestoneTimeCalculator cmtc = new CaseMilestoneTimeCalculator();
        cmtc.caseRec = new Case(Id = caseRecId, MSIdsStartDateSynched__c = caseMilestoneRecId, MSIdsDurationCalculated__c = caseMilestoneRecId);
        cmtc.caseMilestoneRec = new CaseMilestone(Id = caseMilestoneRecId);

        Test.startTest();
            cmtc.createPlatfromEvent();
        Test.stopTest();
    }

    @isTest
    static void testFeatureSwitchByPassNotEnabled(){
        UthFeatureSwitches.disableByPassCaseMilestoneRecalcLogic();
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        CaseMilestoneTimeCalculator cmtc = new CaseMilestoneTimeCalculator();
        cmtc.caseMilestoneRec = null;

        CaseMilestoneTimeCalculator.MILESTONE_ACTION action;

        Test.startTest();
            action = cmtc.getNextAction();
        Test.stopTest();

        Assert.areEqual(CaseMilestoneTimeCalculator.MILESTONE_ACTION.MS_IS_BEING_CREATED, action,'Action should be MS_IS_BEING_CREATED When Bypas featureswitchis disabled');
    }

    @isTest
    static void testFeatureSwitchByPassEnabled(){
        UthFeatureSwitches.enableByPassCaseMilestoneRecalcLogic();
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        CaseMilestoneTimeCalculator cmtc = new CaseMilestoneTimeCalculator();
        cmtc.caseMilestoneRec = null;

        CaseMilestoneTimeCalculator.MILESTONE_ACTION action;

        Test.startTest();
            action = cmtc.getNextAction();
        Test.stopTest();

        Assert.areEqual(CaseMilestoneTimeCalculator.MILESTONE_ACTION.STARTDATE_SYNCHED_AND_DURATION_CALC, action,'Action should be STARTDATE_SYNCHED_AND_DURATION_CALC When Bypas featureswitchis enabled');
    }
}