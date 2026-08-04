@isTest
public with sharing class TA_WOLI_BI_SynchIntegrationFieldsTest {
    @TestSetup
    static void makeData(){
        Pricebook2 pricebook = UthPricebook.create('Custom',null, Date.today(), Date.today().addYears(3));
        Product2 product = UthProduct.create();
        PricebookEntry pbEntry = UthPriceBookEntry.create(pricebook.Id, product.Id);
    }
    
    @isTest
    static void testWOLIInsertInSF(){
        WorkOrder workOrderRecord = UthWorkOrder.create('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today());
        WorkOrderLineItem aWorkOrderLineItem = UthWorkOrderLineItem.build(workOrderRecord.Id, UthPriceBookEntry.getAll()[0].Id, null);
        aWorkOrderLineItem.Quantity = 1;
        Test.startTest();
            insert aWorkOrderLineItem;
        Test.stopTest();
        Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY, UthWorkOrderLineItem.getAll()[0].IntegrationStatus__c, 'Integration status should be populated');
        Assert.isNotNull(UthWorkOrderLineItem.getAll()[0].LastSalesforceIntStatusTSinMS__c, 'Integration Salesforce Timestamp should be populated');
        Assert.areEqual(SobjectRecordChangeDetectorDecorator.CREATED_IN_SYSTEM_SALESFORCE, UthWorkOrderLineItem.getAll()[0].CreatedInSystem__c, 'Created In system is SF');
        Assert.isNull(UthWorkOrderLineItem.getAll()[0].LastSynchDirection__c, 'Last synch direction should be blank');
        Assert.isNull(UthWorkOrderLineItem.getAll()[0].LastMuleSoftSyncedTSinMS__c, 'Mulesoft TS should not be set');
        Assert.isNull(UthWorkOrderLineItem.getAll()[0].LastMuleSoftIntStatusTSinMS__c, 'Mulesoft TS should not be set');
    }

     @isTest
    static void testWOLIInsertInOrchard(){
        Decimal sfinitialtimestamp = (Decimal) System.currentTimeMillis() - 100000;
        WorkOrder workOrderRecord = UthWorkOrder.create('12345',   UthPricebook.getCustomPricebook()[0].Id, System.today());
        WorkOrderLineItem aWorkOrderLineItem = UthWorkOrderLineItem.build(workOrderRecord.Id, UthPriceBookEntry.getAll()[0].Id, SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED);
        aWorkOrderLineItem.Quantity = 1;
        aWorkOrderLineItem.LastSynchDirection__c = SobjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_EXTERNAL_TO_SF;
        aWorkOrderLineItem.LastMuleSoftSyncedTSinMS__c = sfinitialtimestamp;
        aWorkOrderLineItem.LastMuleSoftIntStatusTSinMS__c = sfinitialtimestamp;
        Test.startTest();
            insert aWorkOrderLineItem;
        Test.stopTest();

        Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED, UthWorkOrderLineItem.getAll()[0].IntegrationStatus__c, 'Integration status should not be set to  ready');
        Assert.isNull(UthWorkOrderLineItem.getAll()[0].LastSalesforceIntStatusTSinMS__c, 'Integration Salesforce Timestamp should not be populated');
        Assert.areEqual(SobjectRecordChangeDetectorDecorator.CREATED_IN_SYSTEM_ORCHARD, UthWorkOrderLineItem.getAll()[0].CreatedInSystem__c, 'Created In system is SF');
        Assert.areEqual(sfinitialtimestamp, UthWorkOrderLineItem.getAll()[0].LastMuleSoftSyncedTSinMS__c, 'Mulesoft TS should not be modified');
        Assert.areEqual(sfinitialtimestamp, UthWorkOrderLineItem.getAll()[0].LastMuleSoftIntStatusTSinMS__c, 'Mulesoft TS should not be modified');
        Assert.isNull(UthWorkOrderLineItem.getAll()[0].LastSynchDirection__c, 'Last synch direction should be blank');
    }
}