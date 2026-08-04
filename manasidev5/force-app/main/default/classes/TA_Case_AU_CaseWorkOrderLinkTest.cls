@isTest
public with sharing class TA_Case_AU_CaseWorkOrderLinkTest {
    @TestSetup
    static void makeData(){
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        TriggerBase.bypass('Case');

        UthWorkOrder.create('123456');
        UthWorkOrder.create('7890');
        UthWorkOrder.create('899');

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

        Case caseAwaabsLaw = UthCase.buildAwaabsLawCase(contact.Id, tenancy.Id);
        caseAwaabsLaw.Priority = CaseDecorator.PRIORITY_SLIGHT;
        insert caseAwaabsLaw;

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        TriggerBase.clearBypass('Case');        
    }

    @isTest
    static void linkCaseToWorkOrder(){
        Test.startTest();
            Case caseAwaabsLaw = UthCase.getAll()[0];
            caseAwaabsLaw.Status = CaseDecorator.CASE_STATUS_AWAAB_ACTION;
            caseAwaabsLaw.OrchardJobNumber__c = '123456';
            update caseAwaabsLaw;
        Test.stopTest();
        Assert.areEqual(caseAwaabsLaw.Id ,UthWorkOrder.getAllWOsWithSAs()[0].CaseId, 'Case should be associated to the work order');
    }

    @isTest
    static void linkCaseToWorkOrderWithAlreadyLinkedCase(){
        WorkOrder aworkorder = UthWorkOrder.getAllWOsWithSAs()[0];
        Case caseAwaabsLawOld = UthCase.buildAwaabsLawCase(UthContact.getAll()[0].Id, UthTenancy.getAll()[0].Id);
        caseAwaabsLawOld.OrchardJobNumber__c = '123456';
        insert caseAwaabsLawOld;
        aworkorder.CaseId = caseAwaabsLawOld.Id;
        update aworkorder;
        Test.startTest();
            Case caseAwaabsLaw = UthCase.getAll()[0];
            caseAwaabsLaw.Status = CaseDecorator.CASE_STATUS_AWAAB_ACTION;
            caseAwaabsLaw.OrchardJobNumber__c = '123456';
            update caseAwaabsLaw;
        Test.stopTest();
        Assert.areEqual(caseAwaabsLaw.Id ,UthWorkOrder.getAllWOsWithSAs()[0].CaseId, 'Case should be associated to the work order');
        Assert.areNotEqual(caseAwaabsLawOld.Id ,UthWorkOrder.getAllWOsWithSAs()[0].CaseId, 'New Case should be associated to the work order');
    }

    @isTest
    static void linkCaseToWorkOrderFurtherWorksNumber(){
        Test.startTest();
            Case caseAwaabsLaw = UthCase.getAll()[0];
            caseAwaabsLaw.FurtherWorksJobNumber__c = '3456,7890,899,123456';
            update caseAwaabsLaw;
        Test.stopTest();
        Assert.areEqual(caseAwaabsLaw.Id ,UthWorkOrder.getAllWOsWithSAs()[0].CaseId, 'Case should be associated to the work order');
    }

     @isTest
    static void linkCaseToWorkOrderBulk(){
        List<Case> casesToUpdate = new List<Case>();
        Test.startTest();
            Case caseAwaabsLaw = UthCase.getAll()[0];
            caseAwaabsLaw.FurtherWorksJobNumber__c = '3456,7890';
            casesToUpdate.add(caseAwaabsLaw);
            Case caseAwaabsLawNew  = UthCase.createAwaabsLawCase(UthContact.getAll()[0].Id, UthTenancy.getAll()[0].Id);
            caseAwaabsLawNew.FurtherWorksJobNumber__c = '123456';
            casesToUpdate.add(caseAwaabsLawNew);
            Case caseAwaabsLaw2  = UthCase.createAwaabsLawCase(UthContact.getAll()[0].Id, UthTenancy.getAll()[0].Id);
            caseAwaabsLaw2.FurtherWorksJobNumber__c = '899';
            casesToUpdate.add(caseAwaabsLaw2);
            update casesToUpdate;
        Test.stopTest();
        List<Case> cases = UthCase.getAll();
        Assert.areEqual(cases[0].Id ,UthWorkOrder.getAllWOsWithSAs()[1].CaseId, 'Case should be associated to the work order');
        Assert.areEqual(cases[1].Id ,UthWorkOrder.getAllWOsWithSAs()[0].CaseId, 'Case should be associated to the work order');
        Assert.areEqual(cases[2].Id ,UthWorkOrder.getAllWOsWithSAs()[2].CaseId, 'Case should be associated to the work order');
    }
}