@isTest(seeAllData=false)
public with sharing class CaseSLACalculationServiceTest {
    
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

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact'); 
    }

    @isTest
    static void testCalculateSLADatesForChangesCaseOnCreate(){  
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
        List <Case> newList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId, 
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_NO_SUCCESSOR,
            CaseDecorator.RECORD_TYPE_ID_CHANGES)};
        Test.startTest();
            DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2025, 06, 30) ,Time.newInstance(10,0,0,0));
            DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2025, 08, 26) ,Time.newInstance(17,0,0,0));
            (new CaseSLACalculationService(startDateTime)).calculateSLADates(newList, null);
        Test.stopTest();        
        Assert.areEqual(expectedDateTime.date(),newList[0].SLAEndDate__c.date(),'Both must be equal');
    }


    @isTest
    static void testCalculateSLADatesForChangesCaseOnCreateMutualExchange(){  
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
        List <Case> newList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId, 
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.CASE_TYPE_MUTUAL_EXCHANGE,
            CaseDecorator.RECORD_TYPE_ID_CHANGES)};
        Test.startTest();
            DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2025, 06, 30) ,Time.newInstance(10,0,0,0));
            DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2025, 10, 21) ,Time.newInstance(17,0,0,0));
            DateTime mutualexchangedecisiondate =  Datetime.newInstance(Date.newInstance(2025, 08, 11) ,Time.newInstance(17,0,0,0));
            (new CaseSLACalculationService(startDateTime)).calculateSLADates(newList, null);
        Test.stopTest();        
        Assert.areEqual(expectedDateTime.date(),newList[0].SLAEndDate__c.date(),'Both must be equal');
        Assert.isTrue(newList[0].RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT),'It should include first contact attempt milestone');
        Assert.isTrue(newList[0].RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION),'It should include resolution milestone');
        Assert.isTrue(newList[0].RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_MUTUALEXCHANGEDECISION),'It should include decision milestone');
        Assert.areEqual(mutualexchangedecisiondate.date(),newList[0].MutualExchangeDecisionSLAEndDate__c.date(),'Both must be equal');
        
    }

    @isTest
    static void testCalculateSLADatesForChangesCaseOnCompletingFirstContactAttempt(){  
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
        List <Case> newList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId, 
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_NO_SUCCESSOR,
            CaseDecorator.RECORD_TYPE_ID_CHANGES)};
        Map<Id, Case> oldMap = new Map<Id, Case>{ caseRecId => newList[0].clone()};
        newList[0].CompletedMilestones__c = CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT;
        Test.startTest();
            DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2025, 06, 30) ,Time.newInstance(10,0,0,0));
            DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2025, 10, 21) ,Time.newInstance(17,0,0,0));
            (new CaseSLACalculationService(startDateTime)).calculateSLADates(newList, oldMap);
        Test.stopTest();        
        Assert.isTrue(newList[0].RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT),'It should include Customer contact attempt milestone');        
    }

    @isTest
    static void testCalculateSLADatesForPermissionCaseOnCreate(){  
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
        List <Case> newList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId, 
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.CASE_TYPE_PERMISSION_DISABLED_PARKING,
            CaseDecorator.RECORD_TYPE_ID_PERMISSION)};
        Test.startTest();
            DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2025, 06, 30) ,Time.newInstance(10,0,0,0));
            DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2025, 09, 23) ,Time.newInstance(17,0,0,0));
            (new CaseSLACalculationService(startDateTime)).calculateSLADates(newList, null);
        Test.stopTest();        
        Assert.areEqual(expectedDateTime.date(),newList[0].SLAEndDate__c.date(),'Both must be equal');
        Assert.isTrue(newList[0].RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT),'It should include first contact attempt milestone');
        Assert.isTrue(newList[0].RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION),'It should include resolution milestone');
        
    }

    @isTest
    static void testCalculateSLADatesForPermissionCaseOnCompletingFirstContactAttempt(){  
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
        List <Case> newList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId, 
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.CASE_TYPE_PERMISSION_DISABLED_PARKING,
            CaseDecorator.RECORD_TYPE_ID_PERMISSION)};
        Map<Id, Case> oldMap = new Map<Id, Case>{ caseRecId => newList[0].clone()};
        newList[0].CompletedMilestones__c = CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT;
        Test.startTest();
            DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2025, 06, 30) ,Time.newInstance(10,0,0,0));
            DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2025, 09, 23) ,Time.newInstance(17,0,0,0));
            (new CaseSLACalculationService(startDateTime)).calculateSLADates(newList, oldMap);
        Test.stopTest();        
        Assert.isTrue(newList[0].RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT),'It should include Customer contact milestone');
    }

    @isTest
    static void testCalculateSLADatesForPlaceCaseOnCreate(){  
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
        List <Case> newList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId, 
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.CASE_TYPE_PLACE,
            CaseDecorator.RECORD_TYPE_ID_PLACE)};
        Test.startTest();
            DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2025, 06, 30) ,Time.newInstance(10,0,0,0));
            DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2025, 09, 23) ,Time.newInstance(17,0,0,0));
            (new CaseSLACalculationService(startDateTime)).calculateSLADates(newList, null);
        Test.stopTest();        
        Assert.isTrue(newList[0].RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT),'It should include first contact attempt milestone');        
    }

    @isTest
    static void testCalculateSLADatesForPlaceCaseOnCompletingFirstContactAttempt(){  
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
        List <Case> newList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId, 
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.CASE_TYPE_PLACE,
            CaseDecorator.RECORD_TYPE_ID_PLACE)};
        Map<Id, Case> oldMap = new Map<Id, Case>{ caseRecId => newList[0].clone()};
        newList[0].CompletedMilestones__c = CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT;
        Test.startTest();
            DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2025, 06, 30) ,Time.newInstance(10,0,0,0));
            DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2025, 09, 23) ,Time.newInstance(17,0,0,0));
            (new CaseSLACalculationService(startDateTime)).calculateSLADates(newList, oldMap);
        Test.stopTest();        
        Assert.isTrue(newList[0].RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT),'It should include first contact attempt milestone');        
    }

    @isTest
    static void testCalculateSLADatesForTenancyCaseOnCreate(){  
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);

        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
        List <Case> newList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId, 
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.TYPE_ABANDONED_GOODS,
            CaseDecorator.RECORD_TYPE_ID_TENANCY)};

        Test.startTest();
            DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2025, 06, 30) ,Time.newInstance(10,0,0,0));
            DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2025, 07, 28) ,Time.newInstance(17,0,0,0));
            (new TenancyResolutionSLACalculationService(startDateTime)).calculateSLADates(newList, null);
        Test.stopTest();        
        
        Assert.areEqual(expectedDateTime.date(),newList[0].SLAEndDate__c.date(),'Both must be equal');
    }

    @isTest
    static void testCalculateSLADatesForTenancyCaseOnCompletingFirstContactAttempt(){  
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);

        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
        List <Case> newList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId, 
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.TYPE_ABANDONED_GOODS,
            CaseDecorator.RECORD_TYPE_ID_TENANCY)};
        Map<Id, Case> oldMap = new Map<Id, Case>{ caseRecId => newList[0].clone()};
        newList[0].CompletedMilestones__c = CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT;
        Test.startTest();
            DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2025, 06, 30) ,Time.newInstance(10,0,0,0));
            DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2025, 07, 14) ,Time.newInstance(17,0,0,0));
            (new CaseSLACalculationService(startDateTime)).calculateSLADates(newList, oldMap);
        Test.stopTest();        
        Assert.areEqual(expectedDateTime.date(),newList[0].SLAEndDate__c.date(),'Both must be equal');
    }

    @isTest
    static void testCalculateSLADatesForTenancyCaseOnCompletingFirstContactAttempt_Decant(){  
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
        List <Case> newList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId,  
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.CASETYPE_DECANT,
            CaseDecorator.RECORD_TYPE_ID_TENANCY)};
        Map<Id, Case> oldMap = new Map<Id, Case>{ caseRecId => newList[0].clone()};
        newList[0].CompletedMilestones__c = CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT;
        Test.startTest();
            DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2025, 06, 30) ,Time.newInstance(10,0,0,0));
            DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2025, 07, 07) ,Time.newInstance(17,0,0,0));
            (new CaseSLACalculationService(startDateTime)).calculateSLADates(newList, oldMap);
        Test.stopTest();        
        Assert.areEqual(expectedDateTime.date(),newList[0].SLAEndDate__c.date(),'Both must be equal');
    }
    
    @isTest
    static void testCalculateResoolutionSLADatesForChangeCaseOnCreate(){  
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
        List <Case> newList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId, 
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.CASE_TYPE_SOLE_TO_JOINT,
            CaseDecorator.RECORD_TYPE_ID_CHANGES)};
        Test.startTest();
            DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2025, 06, 30) ,Time.newInstance(10,0,0,0));
            DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2025, 07, 28) ,Time.newInstance(17,0,0,0));
            (new CaseSLACalculationService(startDateTime)).calculateSLADates(newList, null);
        Test.stopTest();        
        Assert.areEqual(expectedDateTime.date(),newList[0].SLAEndDate__c.date(),'Both must be equal');
        Assert.isTrue(newList[0].RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION),'It should include resolution milestone');
        
    }

    @isTest
    static void testCalculateResolution40SLADatesForChangeCaseOnCreate(){  
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
        Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
        List <Case> newList = new List <Case>{UthCase.buildFakeCaseWithType(
            caseRecId, 
            contactRecId, 
            UserInfo.getUserId(),
            CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_NO_SUCCESSOR,
            CaseDecorator.RECORD_TYPE_ID_CHANGES)};
        Test.startTest();
            DateTime startDateTime =  Datetime.newInstance(Date.newInstance(2025, 06, 30) ,Time.newInstance(10,0,0,0));
            DateTime expectedDateTime =  Datetime.newInstance(Date.newInstance(2025, 08, 26) ,Time.newInstance(17,0,0,0));
            (new CaseSLACalculationService(startDateTime)).calculateSLADates(newList, null);
        Test.stopTest();        
        Assert.areEqual(expectedDateTime.date(),newList[0].SLAEndDate__c.date(),'Both must be equal');
        Assert.isTrue(newList[0].RunMilestonesFor__c.contains(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION),'It should include resolution milestone');
        
    }

}