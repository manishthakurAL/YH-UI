@isTest
public with sharing class TA_WOLI_BU_SynchIntegrationFieldsTest {
    
    @TestSetup
    static void makeData(){
        Pricebook2 pricebook = UthPricebook.create('Custom',null, Date.today(), Date.today().addYears(3));
        Product2 product = UthProduct.create();
        PricebookEntry pbEntry = UthPriceBookEntry.create(pricebook.Id, product.Id);
    }

    @isTest
    static void testWOLIUpdateFromSF(){
        WorkOrder workOrderRecord = UthWorkOrder.create('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today());
        WorkOrderLineItem aWorkOrderLineItem = UthWorkOrderLineItem.build(workOrderRecord.Id, UthPriceBookEntry.getAll()[0].Id, null);
        insert aWorkOrderLineItem;
        Test.startTest();
            aWorkOrderLineItem.ClaimQuantity__c = 1;
            update aWorkOrderLineItem;
        Test.stopTest();

        Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY, UthWorkOrderLineItem.getAll()[0].IntegrationStatus__c, 'Integration status should be populated');
        Assert.isNotNull(UthWorkOrderLineItem.getAll()[0].LastSalesforceIntStatusTSinMS__c, 'Integration Salesforce Timestamp should be populated');    
    }

    @isTest
    static void testWOLIUpdateFromOrchard(){
        WorkOrder workOrderRecord = UthWorkOrder.create('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today());
        Decimal timestampInMS = (Decimal) System.currentTimeMillis();
        TriggerBase.bypass('WorkOrderLineItem');
        WorkOrderLineItem aWorkOrderLineItem = UthWorkOrderLineItem.build(workOrderRecord.Id, UthPriceBookEntry.getAll()[0].Id, SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED);
        insert aWorkOrderLineItem;
        TriggerBase.clearBypass('WorkOrderLineItem');
        Test.startTest();
            aWorkOrderLineItem.Quantity = 1;
            aWorkOrderLineItem.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED;
            aWorkOrderLineItem.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_EXTERNAL_TO_SF;
            aWorkOrderLineItem.LastMuleSoftIntStatusTSinMS__c = timestampInMS + 100;
            update aWorkOrderLineItem;
        Test.stopTest();
        aWorkOrderLineItem = UthWorkOrderLineItem.getAll()[0];
        Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED, aWorkOrderLineItem.IntegrationStatus__c, 'Integration status should be populated');
        Assert.isNotNull(aWorkOrderLineItem.LastMuleSoftIntStatusTSinMS__c, 'Integration Salesforce Timestamp should be populated');    
        Assert.isNull(aWorkOrderLineItem.LastSynchDirection__c, 'Last Synch Direction should be null');   
    }

    @isTest
    static void testWOLIUpdateFromOrchardOldStatusReady(){
        WorkOrder workOrderRecord = UthWorkOrder.create('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today());
        Decimal timestampInMS = (Decimal) System.currentTimeMillis();
        TriggerBase.bypass('WorkOrderLineItem');
        WorkOrderLineItem aWorkOrderLineItem = UthWorkOrderLineItem.build(workOrderRecord.Id, UthPriceBookEntry.getAll()[0].Id, SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY);
        aWorkOrderLineItem.LastSalesforceIntStatusTSinMS__c = timestampInMS;
        insert aWorkOrderLineItem;
        TriggerBase.clearBypass('WorkOrderLineItem');
        Test.startTest();
            aWorkOrderLineItem.Quantity = 1;
            aWorkOrderLineItem.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED;
            aWorkOrderLineItem.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_EXTERNAL_TO_SF;
            aWorkOrderLineItem.LastMuleSoftIntStatusTSinMS__c = timestampInMS + 100;
            update aWorkOrderLineItem;
        Test.stopTest();
        
        aWorkOrderLineItem = UthWorkOrderLineItem.getAll()[0];

        Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY, aWorkOrderLineItem.IntegrationStatus__c, 'Integration status should be populated');
        Assert.areEqual(timestampInMS + 100, aWorkOrderLineItem.LastMuleSoftIntStatusTSinMS__c, 'Integration MS  Timestamp should be populated');    
        Assert.areNotEqual(timestampInMS , aWorkOrderLineItem.LastSalesforceIntStatusTSinMS__c, 'Integration Salesforce Timestamp should NOT be same as initial timestamp'); 
        Assert.isNull(aWorkOrderLineItem.LastSynchDirection__c, 'Last Synch Direction should be null');   

    }

    @isTest
    static void testWOLIUpdateFromSalesforceSFTSGreaterthenMSTS(){
        WorkOrder workOrderRecord = UthWorkOrder.create('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today());
        Decimal timestampInMS = (Decimal) System.currentTimeMillis();
        TriggerBase.bypass('WorkOrderLineItem');
        WorkOrderLineItem aWorkOrderLineItem = UthWorkOrderLineItem.build(workOrderRecord.Id, UthPriceBookEntry.getAll()[0].Id, SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY);
        aWorkOrderLineItem.LastSalesforceIntStatusTSinMS__c = timestampInMS;
        insert aWorkOrderLineItem;
        TriggerBase.clearBypass('WorkOrderLineItem');
        Test.startTest();
            aWorkOrderLineItem.Quantity = 1;
            aWorkOrderLineItem.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED;
            aWorkOrderLineItem.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_SF_TO_EXTERNAL;
            aWorkOrderLineItem.LastMuleSoftIntStatusTSinMS__c = timestampInMS - 100;
            update aWorkOrderLineItem;
        Test.stopTest();
        
        aWorkOrderLineItem = UthWorkOrderLineItem.getAll()[0];
        Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY, aWorkOrderLineItem.IntegrationStatus__c, 'Integration status should be populated');
        Assert.isNull(aWorkOrderLineItem.LastSynchDirection__c, 'Last Synch Direction should be null');   
    }

    @isTest
    static void testWOLIUpdateFromSalesforceErrorCondition(){
        WorkOrder workOrderRecord = UthWorkOrder.create('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today());
        Decimal timestampInMS = (Decimal) System.currentTimeMillis();
        TriggerBase.bypass('WorkOrderLineItem');
        WorkOrderLineItem aWorkOrderLineItem = UthWorkOrderLineItem.build(workOrderRecord.Id, UthPriceBookEntry.getAll()[0].Id, SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY);
        aWorkOrderLineItem.LastSalesforceIntStatusTSinMS__c = timestampInMS;
        insert aWorkOrderLineItem;
        TriggerBase.clearBypass('WorkOrderLineItem');
        try{
            Test.startTest();
                aWorkOrderLineItem.Quantity = 1;
                aWorkOrderLineItem.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED;
                aWorkOrderLineItem.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_SF_TO_EXTERNAL;
                aWorkOrderLineItem.LastMuleSoftIntStatusTSinMS__c = timestampInMS - 100;
                update aWorkOrderLineItem;
            Test.stopTest();
        }catch(Exception e){
            Assert.areEqual(true, e.getMessage().contains(Label.SynchErrorMessage));
        }
    }

     @isTest
    static void testWOLIUpdateFromExternaltoSFStatusError(){
        WorkOrder workOrderRecord = UthWorkOrder.create('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today());
        Decimal timestampInMS = (Decimal) System.currentTimeMillis();
        TriggerBase.bypass('WorkOrderLineItem');
        WorkOrderLineItem aWorkOrderLineItem = UthWorkOrderLineItem.build(workOrderRecord.Id, UthPriceBookEntry.getAll()[0].Id, SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY);
        aWorkOrderLineItem.LastSalesforceIntStatusTSinMS__c = timestampInMS;
        insert aWorkOrderLineItem;
        TriggerBase.clearBypass('WorkOrderLineItem');
        try{
            Test.startTest();
                aWorkOrderLineItem.Quantity = 1;
                aWorkOrderLineItem.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_ERROR;
                aWorkOrderLineItem.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_SF_TO_EXTERNAL;
                aWorkOrderLineItem.LastMuleSoftIntStatusTSinMS__c = timestampInMS - 100;
                update aWorkOrderLineItem;
            Test.stopTest();
        }catch(Exception e){
            Assert.areEqual(true, e.getMessage().contains(Label.SynchErrorMessageExtToSF));
        }
    }

    @isTest
    static void testWOLIUpdateFromSalesforceSFTSGreaterthenMSTSStatusError(){
        WorkOrder workOrderRecord = UthWorkOrder.create('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today());
        Decimal timestampInMS = (Decimal) System.currentTimeMillis();
        TriggerBase.bypass('WorkOrderLineItem');
        WorkOrderLineItem aWorkOrderLineItem = UthWorkOrderLineItem.build(workOrderRecord.Id, UthPriceBookEntry.getAll()[0].Id, SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY);
        aWorkOrderLineItem.LastSalesforceIntStatusTSinMS__c = timestampInMS;
        insert aWorkOrderLineItem;
        TriggerBase.clearBypass('WorkOrderLineItem');
        Test.startTest();
            aWorkOrderLineItem.Quantity = 1;
            aWorkOrderLineItem.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_ERROR;
            aWorkOrderLineItem.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_SF_TO_EXTERNAL;
            aWorkOrderLineItem.LastMuleSoftIntStatusTSinMS__c = timestampInMS - 100;
            update aWorkOrderLineItem;
        Test.stopTest();
        
        aWorkOrderLineItem = UthWorkOrderLineItem.getAll()[0];
        Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY, aWorkOrderLineItem.IntegrationStatus__c, 'Integration status should be populated');
        Assert.areEqual(timestampInMS - 100, aWorkOrderLineItem.LastMuleSoftIntStatusTSinMS__c, 'Mulesoft synch TS should not be updated');
        Assert.isNull(aWorkOrderLineItem.LastSynchDirection__c, 'Last Synch Direction should be null');   

    }

    @isTest
    static void testWOLIUpdateFromSalesforceMSTSGreaterthenMSFTSStatusError(){
        WorkOrder workOrderRecord = UthWorkOrder.create('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today());
        Decimal timestampInMS = (Decimal) System.currentTimeMillis();
        TriggerBase.bypass('WorkOrderLineItem');
        WorkOrderLineItem aWorkOrderLineItem = UthWorkOrderLineItem.build(workOrderRecord.Id, UthPriceBookEntry.getAll()[0].Id, SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY);
        aWorkOrderLineItem.LastSalesforceIntStatusTSinMS__c = timestampInMS;
        insert aWorkOrderLineItem;
        TriggerBase.clearBypass('WorkOrderLineItem');
        try{
        Test.startTest();
            aWorkOrderLineItem.Quantity = 1;
            aWorkOrderLineItem.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_ERROR;
            aWorkOrderLineItem.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_SF_TO_EXTERNAL;
            aWorkOrderLineItem.LastMuleSoftIntStatusTSinMS__c = timestampInMS - 100;
            update aWorkOrderLineItem;
        Test.stopTest();
        }catch(Exception e){
            Assert.areEqual(true, e.getMessage().contains(Label.SynchErrorMessage));
        } 
    }
}