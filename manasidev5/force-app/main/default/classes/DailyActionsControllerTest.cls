@isTest
public with sharing class DailyActionsControllerTest {
    @testSetup
    static void setUpTestData(){
        ServiceResourceStep__c srs = UthServiceResourceStep.create();
    }

    @isTest
    static void testGetServiceResourceStep(){
        Assert.isNotNull(DailyActionsController.getDailyActionRecord(),'No Service Resource Step record found');
    }

    @isTest
    static void updateServiceResourceStepTest(){
        ServiceResourceStep__c serviceResourceStepRecord = UthServiceResourceStep.getAll()[0];
        serviceResourceStepRecord.OutcomeOfTLCall__c = 'test';
        String  serviceResourceStepRecordString = JSON.serialize(serviceResourceStepRecord);
        Test.startTest();
            DailyActionsController.upadteDailyActionRecord(serviceResourceStepRecordString);
        Test.stopTest();
        Assert.areEqual('test', UthServiceResourceStep.getAll()[0].OutcomeOfTLCall__c,'Value should be equal');
    }


}