@isTest(seeAllData=false)
public class PlaceResolutionSLACalculationServiceTest {

    @testSetup
    static void setUpTestData(){
        UthFeatureSwitches.enableCasePlaceRT();
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        
        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact;

        Entitlement placeEntitlement = UthEntitlement.buildPlaceEntitlement(account.Id);
        insert placeEntitlement;

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact'); 
    }

    @isTest
    static void testCalculateSLADatesForLandDisputes(){  
        Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_CREATE_AT_NEW).Id;
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
            
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
                DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
                DateTime expectedDateTime = businessHourService.calculateTargetDate(
                    CaseDecorator.PLACE_LAND_DISPUTES_CASE_SLA_DAYS,
                    nextBusinessDay
                );
                List<Contact> contactsList = UthContact.getAll();
                Case caseRecord = UthCase.buildPlaceWithTypeCase(contactsList[0].Id, CaseDecorator.CASE_TYPE_LAND_DISPUTES);
                insert caseRecord;
            Test.stopTest();        
            
            caseRecord = UthCase.get(caseRecord.Id);
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAEndDate__c.date(),'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLADatesForLandDisputesVerifyCaseMilestone(){  
        Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_CREATE_AT_NEW).Id;
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        Id permissionSetIdUpdate = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_UPDATE).Id;
        PermissionSetAssignment permissionSetAssignmentNwNew = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetIdUpdate);
        if (permissionSetAssignmentNwNew == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetIdUpdate);
        }
            
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
                DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
                DateTime expectedDateTime = businessHourService.calculateTargetDate(
                    CaseDecorator.PLACE_LAND_DISPUTES_CASE_SLA_DAYS,
                    nextBusinessDay
                );
                DateTime resolutionTargetDate = DateTime.newInstance(
                    expectedDateTime.date(),
                    Time.newInstance(17,0,0,0)
                );
                List<Contact> contactsList = UthContact.getAll();
                Case caseRecord = UthCase.buildPlaceWithTypeCase(contactsList[0].Id, CaseDecorator.CASE_TYPE_LAND_DISPUTES);
                insert caseRecord;

                caseRecord.Status = CaseDecorator.SUB_STATUS_REVIEW;
                update caseRecord;
            Test.stopTest();        
            
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION); 
            Assert.areEqual(resolutionTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to resolution target date');
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAEndDate__c.date(),'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLADatesForAbandonedVehiclesVerifyCaseMilestone(){  
        Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_CREATE_AT_NEW).Id;
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        Id permissionSetIdUpdate = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_UPDATE).Id;
        PermissionSetAssignment permissionSetAssignmentNwNew = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetIdUpdate);
        if (permissionSetAssignmentNwNew == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetIdUpdate);
        }

        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
                DateTime nextBusinessDay =  businessHourService.getNextBusinessDay(System.now(),null);
                DateTime expectedDateTime = businessHourService.calculateTargetDate(
                    CaseDecorator.PLACE_ABANDONED_VEHICLES_CASE_SLA_DAYS,
                    nextBusinessDay
                );
                DateTime resolutionTargetDate = DateTime.newInstance(
                    expectedDateTime.date(),
                    Time.newInstance(17,0,0,0)
                );
                List<Contact> contactsList = UthContact.getAll();
                Case caseRecord = UthCase.buildPlaceWithTypeCase(contactsList[0].Id, CaseDecorator.CASE_TYPE_ABANDONED_VEHICLES);
                insert caseRecord;

                caseRecord.Status = CaseDecorator.SUB_STATUS_REVIEW;
                update caseRecord;
            Test.stopTest();        
            
            caseRecord = UthCase.get(caseRecord.Id);
            List<CaseMilestone> caseMilestontesList = UthCaseMilestone.getByMilestoneName(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION); 
            Assert.areEqual(resolutionTargetDate,caseMilestontesList[0].TargetDate,'Target Date must be equal to resolution target date');
            Assert.areEqual(nextBusinessDay.date(),caseRecord.SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),caseRecord.SLAEndDate__c.date(),'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLADatesForLandDisputesWithPreDefinedDates(){  
        Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_CREATE_AT_NEW).Id;
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
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
            CaseDecorator.CASE_TYPE_LAND_DISPUTES,
            CaseDecorator.RECORD_TYPE_ID_PLACE)};

        System.runAs(new User(Id = currentUserId)) {+
            Test.startTest();
                DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2024, 10, 24) ,Time.newInstance(10,0,0,0));
                DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2024, 12, 19) ,Time.newInstance(17,0,0,0));
                new PlaceResolutionSLACalculationService(startDateTime).calculateSLADates(newList, null);
            Test.stopTest();   
            
            Assert.areEqual(startDateTime.date(),newList[0].SLAStartDate__c.date(),'Both must be equal');
            Assert.areEqual(expectedDateTime.date(),newList[0].SLAEndDate__c.date(),'Both must be equal');
        }
    }

    @isTest
    static void testCalculateSLADatesForAbandonedVehiclesWithPreDefinedDates(){  
        Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_CREATE_AT_NEW).Id;
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
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
            CaseDecorator.CASE_TYPE_ABANDONED_VEHICLES,
            CaseDecorator.RECORD_TYPE_ID_PLACE)};

        System.runAs(new User(Id = currentUserId)) {+
            Test.startTest();
                DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2024, 10, 24) ,Time.newInstance(10,0,0,0));
                DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2025, 01, 21) ,Time.newInstance(17,0,0,0));
                new PlaceResolutionSLACalculationService(startDateTime).calculateSLADates(newList, null);
            Test.stopTest();        
            
            Assert.areEqual(startDateTime.date(),newList[0].SLAStartDate__c.date(),'Both must be equal');
            //Assert.areEqual(expectedDateTime.date(),newList[0].SLAEndDate__c.date(),'Both must be equal');
        }
    }
}