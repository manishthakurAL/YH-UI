@isTest(seeAllData=false)
public with sharing class TA_Case_AIU_TriggerCaseSyncStartDateTest {
    
    @testSetup
    static void setUpTestData(){
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact; 
    }


    static testMethod void testInsertCase() {
        Contact contact = UthContact.getAll()[0];
        Case cse = UthCase.buildComplaintCase(contact.Id);
        
        Test.startTest();
            cse.SLAStartDate__c = Date.today();
            insert cse;
        Test.stopTest();

        List<EventBusSubscriber> result = UthEventBusSubscriber.getAllWithTopicAndName('CaseMilestoneEvent__e', FlowDecorator.FLOW_ATF_CMSE_SYNC_START_DATE);
        
        Assert.areEqual(1,result.size(),'EventBusSubscriber size should be 1');
        Assert.areEqual(1,result[0].Position,'Position should be 1');
    }

    static testMethod void testUpdateCase() {
        Contact contact = UthContact.getAll()[0];
        Case cse = UthCase.buildComplaintCase(contact.Id);
        insert cse;

        Test.startTest();
            cse.SLAStartDate__c = Date.today();
            update cse;
        Test.stopTest();

        List<EventBusSubscriber> result = UthEventBusSubscriber.getAllWithTopicAndName('CaseMilestoneEvent__e', FlowDecorator.FLOW_ATF_CMSE_SYNC_START_DATE);
        
        Assert.areEqual(1,result.size(),'EventBusSubscriber size should be 1');
        Assert.areEqual(2,result[0].Position,'Position should be 2');
    }
}