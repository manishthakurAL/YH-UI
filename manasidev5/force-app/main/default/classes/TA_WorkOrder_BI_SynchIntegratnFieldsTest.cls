@isTest
public with sharing class TA_WorkOrder_BI_SynchIntegratnFieldsTest {
    @TestSetup
    static void makeData(){
        Pricebook2 pricebook = UthPricebook.create('Custom',null, Date.today(), Date.today().addYears(3));
        Product2 product = UthProduct.create();
        PricebookEntry pbEntry = UthPriceBookEntry.create(pricebook.Id, product.Id);
    }
    
    @isTest
    static void testWOLIInsertInSF(){
        Test.startTest();
            WorkOrder workOrderRecord = UthWorkOrder.create('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today(), WorkOrderDecorator.STATUS_CANCELED);
        Test.stopTest();
        workOrderRecord = UthWorkOrder.getAllWOsWithSAs()[0];
        Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY, workOrderRecord.IntegrationStatus__c, 'Integration status should be populated');
        Assert.isNotNull(workOrderRecord.LastSalesforceIntStatusTSinMS__c, 'Integration Salesforce Timestamp should be populated');
        Assert.areEqual(SobjectRecordChangeDetectorDecorator.CREATED_IN_SYSTEM_SALESFORCE, workOrderRecord.CreatedInSystem__c, 'Created In system is SF');
        Assert.isNull(workOrderRecord.LastSynchDirection__c, 'Last synch direction should be blank');
    }

     @isTest
    static void testWOLIInsertInOrchard(){
        Decimal timestampInMs = (Decimal) System.currentTimeMillis() - 100;
        WorkOrder workOrderRecord = UthWorkOrder.build('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today(), WorkOrderDecorator.STATUS_CANCELED);
        workOrderRecord.LastSynchDirection__c = SobjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_EXTERNAL_TO_SF;
        workOrderRecord.IntegrationStatus__c = SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED;
        workOrderRecord.LastMuleSoftSyncedTSinMS__c = timestampInMs;
        workOrderRecord.LastMuleSoftIntStatusTSinMS__c = timestampInMs;
        Test.startTest();
            insert workOrderRecord;
        Test.stopTest();
        workOrderRecord = UthWorkOrder.getAllWOsWithSAs()[0];
        Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED, workOrderRecord.IntegrationStatus__c, 'Integration status should not be set to  ready');
        Assert.isNull(workOrderRecord.LastSalesforceIntStatusTSinMS__c, 'Integration Salesforce Timestamp should not be populated');
        Assert.areEqual(SobjectRecordChangeDetectorDecorator.CREATED_IN_SYSTEM_ORCHARD, workOrderRecord.CreatedInSystem__c, 'Created In system is SF');
        Assert.isNull(workOrderRecord.LastSynchDirection__c, 'Last synch direction should be blank');
        Assert.areEqual(timestampInMs, workOrderRecord.LastMuleSoftSyncedTSinMS__c, 'Mulesoft TS should not be changed');
        Assert.areEqual(timestampInMs, workOrderRecord.LastMuleSoftIntStatusTSinMS__c, 'Mulesoft TS should not be changed');

    }
}