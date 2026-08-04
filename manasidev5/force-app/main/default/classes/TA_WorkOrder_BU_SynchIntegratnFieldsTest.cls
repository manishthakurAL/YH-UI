@isTest
public with sharing class TA_WorkOrder_BU_SynchIntegratnFieldsTest {
    
    @TestSetup
    static void makeData(){
        Pricebook2 pricebook = UthPricebook.create('Custom',null, Date.today(), Date.today().addYears(3));
        Product2 product = UthProduct.create();
        PricebookEntry pbEntry = UthPriceBookEntry.create(pricebook.Id, product.Id);
    }

    @isTest
    static void testWOUpdateFromSF(){
        WorkOrder workOrderRecord = UthWorkOrder.create('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today(), null);
        Test.startTest();
            workOrderRecord.Status = WorkOrderDecorator.STATUS_CANCELED;
            update workOrderRecord;
        Test.stopTest();

        Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY, UthWorkOrder.getAllWOsWithSAs()[0].IntegrationStatus__c, 'Integration status should be populated');
        Assert.isNotNull(UthWorkOrder.getAllWOsWithSAs()[0].LastSalesforceIntStatusTSinMS__c, 'Integration Salesforce Timestamp should be populated');    
    }

    @isTest
    static void testWOUpdateFromOrchard(){
        WorkOrder workOrderRecord = UthWorkOrder.build('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today(), null);
        workOrderRecord.IntegrationStatus__c = SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED ;      
        Decimal timestampInMS = (Decimal) System.currentTimeMillis();
        TriggerBase.bypass('WorkOrder');
            insert workOrderRecord;
        TriggerBase.clearBypass('WorkOrder');
        Test.startTest();
            workOrderRecord.Status = WorkOrderDecorator.STATUS_CANCELED;
            workOrderRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED;
            workOrderRecord.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_EXTERNAL_TO_SF;
            workOrderRecord.LastMuleSoftIntStatusTSinMS__c = timestampInMS + 100;
            update workOrderRecord;
        Test.stopTest();
        workOrderRecord = UthWorkOrder.getAllWOsWithSAs()[0];
        Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED, workOrderRecord.IntegrationStatus__c, 'Integration status should be populated');
        Assert.isNotNull(workOrderRecord.LastMuleSoftIntStatusTSinMS__c, 'Integration Salesforce Timestamp should be populated');    
        Assert.isNull(workOrderRecord.LastSynchDirection__c, 'Last Synch Direction should be null');   

    }

    @isTest
    static void testWOUpdateFromOrchardOldStatusReady(){
        WorkOrder workOrderRecord = UthWorkOrder.build('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today(), null);
        workOrderRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY;
        Decimal timestampInMS = (Decimal) System.currentTimeMillis();
        TriggerBase.bypass('WorkOrder');
        insert workOrderRecord;
        TriggerBase.clearBypass('WorkOrder');
        Test.startTest();
            workOrderRecord.Status = WorkOrderDecorator.STATUS_CANCELED;
            workOrderRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED;
            workOrderRecord.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_EXTERNAL_TO_SF;
            workOrderRecord.LastMuleSoftIntStatusTSinMS__c = timestampInMS + 100;
            update workOrderRecord;
        Test.stopTest();
        
        workOrderRecord = UthWorkOrder.getAllWOsWithSAs()[0];

        Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY, workOrderRecord.IntegrationStatus__c, 'Integration status should be populated');
        Assert.areEqual(timestampInMS + 100, workOrderRecord.LastMuleSoftIntStatusTSinMS__c, 'Integration MS  Timestamp should be populated');    
        Assert.areNotEqual(timestampInMS , workOrderRecord.LastSalesforceIntStatusTSinMS__c, 'Integration Salesforce Timestamp should NOT be same as initial timestamp'); 
        Assert.isNull(workOrderRecord.LastSynchDirection__c, 'Last Synch Direction should be null');   

    }

    @isTest
    static void testWOUpdateFromSalesforceSFTSGreaterthenMSTS(){
        WorkOrder workOrderRecord = UthWorkOrder.build('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today(), null);
        Decimal timestampInMS = (Decimal) System.currentTimeMillis();
        workOrderRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY;
        workOrderRecord.LastSalesforceIntStatusTSinMS__c = timestampInMS;
        TriggerBase.bypass('WorkOrder');
        insert workOrderRecord;
        TriggerBase.clearBypass('WorkOrder');
        Test.startTest();
            workOrderRecord.Status = WorkOrderDecorator.STATUS_CANCELED;
            workOrderRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED;
            workOrderRecord.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_SF_TO_EXTERNAL;
            workOrderRecord.LastMuleSoftIntStatusTSinMS__c = timestampInMS - 100;
            update workOrderRecord;
        Test.stopTest();
        workOrderRecord = UthWorkOrder.getAllWOsWithSAs()[0];
        Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY, workOrderRecord.IntegrationStatus__c, 'Integration status should be populated');
        Assert.isNull(workOrderRecord.LastSynchDirection__c, 'Last Synch Direction should be null');   

    }

    @isTest
    static void testWOUpdateFromSalesforceErrorCondition(){
        WorkOrder workOrderRecord = UthWorkOrder.build('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today(), null);
        Decimal timestampInMS = (Decimal) System.currentTimeMillis();
        TriggerBase.bypass('WorkOrder');
        insert workOrderRecord;
        TriggerBase.clearBypass('WorkOrder');
        try{
        Test.startTest();
            workOrderRecord.Status = WorkOrderDecorator.STATUS_CANCELED;
            workOrderRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED;
            workOrderRecord.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_SF_TO_EXTERNAL;
            workOrderRecord.LastMuleSoftIntStatusTSinMS__c = timestampInMS - 100;
            update workOrderRecord;
        Test.stopTest();
        }catch(Exception e){
            Assert.areEqual(true, e.getMessage().contains(Label.SynchErrorMessage));
        }
    }

    @isTest
    static void bulkWorkOrderUpdateTest(){
        Decimal timestampInMS = (Decimal) System.currentTimeMillis();
        List<WorkOrder> workOrderList = new List<WorkOrder>();
        TriggerBase.bypass('WorkOrder');
        for(Integer i=0 ; i <=1; i++){
            WorkOrder aworkOrder = UthWorkOrder.build('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today(), null);
            aworkOrder.LastSalesforceIntStatusTSinMS__c = timestampInMS;
            workOrderList.add(aworkOrder);
        }
        for(Integer i = 2; i <= 3 ;i++){
           workOrderList.add(UthWorkOrder.build('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today(), null));
        }
        insert workOrderList;
        TriggerBase.clearBypass('WorkOrder');
        Test.startTest();
        workOrderList = UthWorkOrder.getAllWOsWithSAs();
        workOrderList[0].Status = WorkOrderDecorator.STATUS_CANCELED;
        workOrderList[0].IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED;
        workOrderList[0].LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_EXTERNAL_TO_SF;
        workOrderList[0].LastMuleSoftIntStatusTSinMS__c = timestampInMS + 100;
        workOrderList[1].Status = WorkOrderDecorator.STATUS_CANCELED;
        workOrderList[1].IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED;
        workOrderList[1].LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_SF_TO_EXTERNAL;
        workOrderList[1].LastMuleSoftIntStatusTSinMS__c = timestampInMS - 100;

        for(Integer i=2; i<=3; i++){
            workOrderList[i].Status = WorkOrderDecorator.STATUS_CANCELED;
            workOrderList[i].IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED;
            workOrderList[i].LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_SF_TO_EXTERNAL;
            workOrderList[i].LastMuleSoftIntStatusTSinMS__c = timestampInMS - 100;
        }
        update workOrderList;
        Test.stopTest();
        workOrderList = UthWorkOrder.getAllWOsWithSAs();
        for(Integer i=2; i<=3; i++){
            Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED, workOrderList[i].IntegrationStatus__c, 'Integration status should be populated');
            Assert.isNull(workOrderList[i].LastSynchDirection__c, 'Last Synch Direction should be null');   
        }
        Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED, workOrderList[0].IntegrationStatus__c, 'Integration status should be populated');
        Assert.isNull(workOrderList[0].LastSynchDirection__c, 'Last Synch Direction should be null');  
        Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY, workOrderList[1].IntegrationStatus__c, 'Integration status should be populated');
        Assert.isNull(workOrderList[1].LastSynchDirection__c, 'Last Synch Direction should be null');   
    }

     @isTest
    static void testWOUpdateFromOrchardStatusCompletedToNewOtherDatapointChanged(){
        WorkOrder workOrderRecord = UthWorkOrder.build('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today(), null);
        workOrderRecord.IntegrationStatus__c = SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY ; 
        workOrderRecord.Status = WorkOrderDecorator.STATUS_COMPLETED;     
        Decimal timestampInMS = (Decimal) System.currentTimeMillis();
        TriggerBase.bypass('WorkOrder');
            insert workOrderRecord;
        TriggerBase.clearBypass('WorkOrder');
        Test.startTest();
            workOrderRecord.Status = WorkOrderDecorator.STATUS_NEW;
            workOrderRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED;
            workOrderRecord.LastMuleSoftIntStatusTSinMS__c = timestampInMS + 100;
            workOrderRecord.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_EXTERNAL_TO_SF;
            workOrderRecord.OverallTargetDateFromOrchard__c = System.today() + 10;
            update workOrderRecord;
        Test.stopTest();
        workOrderRecord = UthWorkOrder.getAllWOsWithSAs()[0];
        Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY, workOrderRecord.IntegrationStatus__c, 'Integration status should be populated');
        Assert.isNull(workOrderRecord.LastSynchDirection__c, 'Last Synch Direction should be null');   
        Assert.areEqual(workOrderRecord.Status, WorkOrderDecorator.STATUS_NEW);  
    }

     @isTest
    static void testWOUpdateFromOrchardStatusCompletedToNew(){
        WorkOrder workOrderRecord = UthWorkOrder.build('12345',  UthPricebook.getCustomPricebook()[0].Id, System.today(), null);
        workOrderRecord.IntegrationStatus__c = SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY ; 
        workOrderRecord.Status = WorkOrderDecorator.STATUS_COMPLETED;     
        Decimal timestampInMS = (Decimal) System.currentTimeMillis();
        TriggerBase.bypass('WorkOrder');
            insert workOrderRecord;
        TriggerBase.clearBypass('WorkOrder');
        Test.startTest();
            workOrderRecord.Status = WorkOrderDecorator.STATUS_NEW;
            workOrderRecord.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_EXTERNAL_TO_SF;
            workOrderRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED;
            workOrderRecord.LastMuleSoftIntStatusTSinMS__c = timestampInMS + 100;
            workOrderRecord.ActiveSORs__c = 'Active SORs';
            update workOrderRecord;
        Test.stopTest();
        workOrderRecord = UthWorkOrder.getAllWOsWithSAs()[0];
        Assert.areEqual(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY, workOrderRecord.IntegrationStatus__c, 'Integration status should be populated');
        Assert.isNotNull(workOrderRecord.LastMuleSoftIntStatusTSinMS__c, 'Integration Salesforce Timestamp should be populated');    
        Assert.isNull(workOrderRecord.LastSynchDirection__c, 'Last Synch Direction should be null');   
        Assert.areEqual(workOrderRecord.Status, WorkOrderDecorator.STATUS_COMPLETED);   


    }
}