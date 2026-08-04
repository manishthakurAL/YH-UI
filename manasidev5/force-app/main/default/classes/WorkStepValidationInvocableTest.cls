@isTest
public with sharing class WorkStepValidationInvocableTest {
    @TestSetup
    static void makeData(){
        TriggerBase.bypass('ServiceAppointment');
        OperatingHours opHours = new OperatingHours(Name = 'TestHours');
        insert opHours;

        ServiceTerritory territory = new ServiceTerritory(
            Name = 'Territory1',
            OperatingHoursId = opHours.Id,
            IsActive = true
        );
        insert territory;
        ServiceResource sr = UthServiceResource.create();
        ServiceTerritoryMember member = new ServiceTerritoryMember(
            ServiceTerritoryId = territory.Id,
            ServiceResourceId = sr.Id,
            EffectiveStartDate = System.today()
        );
        insert member;
        WorkOrder wo = UthWorkOrder.create('12345');
        ServiceAppointment sa = UthServiceAppointment.create(wo.Id);
        ServiceResourceStep__c srs = UthServiceResourceStep.create(sr.Id);
        UthAssignedResource.create(new Set<Id>{sa.Id}, sr.Id);

    }

    @isTest
    static void testWorkStepValidation(){
        WorkStepValidationInvocable.ValidateRequest vr = new WorkStepValidationInvocable.ValidateRequest();
        vr.operativeId = UserInfo.getUserId();
        Test.startTest();
        WorkStepValidationInvocable.ValidationResponse  response = WorkStepValidationInvocable.validateWorkStep(new List<WorkStepValidationInvocable.ValidateRequest>{vr})[0];
        Test.stopTest();
        Assert.isNotNull(response.message, 'Message should be populated as daily actions are not completefd');
        Assert.isFalse(response.canProceed, 'Operative is not proceedable');
    }

    @isTest
    static void testWorkStepValidationAbsentOperative(){
        WorkStepValidationInvocable.ValidateRequest vr = new WorkStepValidationInvocable.ValidateRequest();
        vr.operativeId = UserInfo.getUserId();
        ServiceResourceStep__c srs = UthServiceResourceStep.getAll()[0];
        srs.ReadyToWork__c = DailyActionsDecorator.NO;
        srs.CanYouProceedWithFirstSA__c = DailyActionsDecorator.NO;
        update srs;
        Test.startTest();
        WorkStepValidationInvocable.ValidationResponse  response = WorkStepValidationInvocable.validateWorkStep(new List<WorkStepValidationInvocable.ValidateRequest>{vr})[0];
        Test.stopTest();
        Assert.isNotNull(response.message, 'Message should be populated as daily actions are not completed');
        Assert.isFalse(response.canProceed, 'Operative is not proceedable');
        Assert.isTrue(response.message.containsIgnoreCase('not working'), 'Message should be populated as daily actions are not completefd');


    }

    @isTest
    static void testWorkStepValidationProceedable(){
        WorkStepValidationInvocable.ValidateRequest vr = new WorkStepValidationInvocable.ValidateRequest();
        vr.operativeId = UserInfo.getUserId();
        ServiceResourceStep__c srs = UthServiceResourceStep.getAll()[0];
        srs.VanCheckDT__c = Datetime.now();
        srs.AbsOrIssueReportingCheckDT__c = Datetime.now();
        update srs;
        Test.startTest();
        WorkStepValidationInvocable.ValidationResponse  response = WorkStepValidationInvocable.validateWorkStep(new List<WorkStepValidationInvocable.ValidateRequest>{vr})[0];
        Test.stopTest();
        Assert.isNull(response.message, 'Message should not be populated as daily actions are not completefd');
        Assert.isTrue(response.canProceed, 'Operative is  proceedable');
    }
}