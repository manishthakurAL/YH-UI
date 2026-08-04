@isTest
public with sharing class TA_ServiceAppointment_AU_WPCloneTest {

    @TestSetup
    static void dataSetup(){
        
        TriggerBase.bypass('ServiceAppointment');

        UthFieldService.basicSetup();
        WorkPlanTemplate wpt = UthWorkPlanTemplate.setupWorkPlanStepTemplate();

        WorkOrder wo1 = UthWorkOrder.create('ORCH01');
        WorkOrder wo2 = UthWorkOrder.create('ORCH02');
        UthWorkPlan.createWorkStep(UthWorkPlan.createWorkPlan(wo1));
        UthWorkPlan.createWorkStep(UthWorkPlan.createWorkPlan(wo2));
        list<ServiceAppointment> saList = UthServiceAppointment.create(new map<Id, Integer>{wo1.Id=>2, wo2.Id=>2});
        map<Id, ServiceAppointment> saMap = new map<Id, ServiceAppointment>(saList);        
        UthAssignedResource.create(saMap.keyset(), UthServiceResource.getAll()[0].Id);        
        TriggerBase.clearBypass('ServiceAppointment');

    }

    @isTest
    static void workplanLink() {
        list<WorkOrder> woList = UthWorkOrder.getAllWOsWithSAs();
        WorkOrder wo;

        for(WorkOrder w : woList){
            if(w.OrchardJobNumber__c == 'ORCH01'){
                wo = w;
            }
        }
        ServiceAppointment sa01 = wo.ServiceAppointments[0];
        ServiceAppointment sa02 = wo.ServiceAppointments[1];

        Test.startTest();
        sa01.Status = ServiceAppointmentDecorator.STATUS_DISPATCHED;
        sa01.AssignedOperativeOrchardIdInFS__c = 'T001';
        update sa01;
        Test.stopTest();

        list<WorkPlan> wpList = UthWorkPlan.getAll(wo.Id);
        system.Assert.areEqual(1, wpList.size());
        system.Assert.areEqual(sa01.Id, wpList[0].ServiceAppointment__c);
        system.Assert.areEqual(true, wpList[0].IsServiceAppointmentLinked__c);

        list<WorkPlanShare> wpShareList = UthWorkPlanShare.getAll(new list<Id>{wpList[0].Id}, new list<Id>{UthServiceResource.getAll()[0].RelatedRecordId});
        system.assert.areEqual(1, wpShareList.size());
    }

    @isTest
    static void workplanLinkNegative() {
        list<WorkOrder> woList = UthWorkOrder.getAllWOsWithSAs();
        WorkOrder wo;
        for(WorkOrder w : woList){
            if(w.OrchardJobNumber__c == 'ORCH01'){
                wo = w;
            }
        }
        WorkPlan wp = UthWorkPlan.getAll(wo.Id)[0];
        wp.IsApplicableToServiceAppointment__c = false;
        update wp;
        ServiceAppointment sa01 = wo.ServiceAppointments[0];
        ServiceAppointment sa02 = wo.ServiceAppointments[1];

        Test.startTest();
        sa01.Status = ServiceAppointmentDecorator.STATUS_DISPATCHED;
        sa01.AssignedOperativeOrchardIdInFS__c = 'T001';
        update sa01;
        Test.stopTest();

        list<WorkPlan> wpList = UthWorkPlan.getAll(wo.Id);
        system.Assert.areEqual(1, wpList.size());
        system.Assert.areEqual(null, wpList[0].ServiceAppointment__c);
        system.Assert.areEqual(false, wpList[0].IsServiceAppointmentLinked__c);
        
        list<WorkPlanShare> wpShareList = UthWorkPlanShare.getAll(new list<Id>{wpList[0].Id}, new list<Id>{UthServiceResource.getAll()[0].RelatedRecordId});
        system.assert.areEqual(0, wpShareList.size());
    }

    @isTest
    static void workplanClone() {
        list<WorkOrder> woList = UthWorkOrder.getAllWOsWithSAs();
        WorkOrder wo;
        list<ServiceAppointment> saList = new list<ServiceAppointment>();

        for(WorkOrder w : woList){
            if(w.OrchardJobNumber__c == 'ORCH01'){
                wo = w;
                for(ServiceAppointment sa : w.ServiceAppointments){
                    sa.status = ServiceAppointmentDecorator.STATUS_DISPATCHED;
                    sa.AssignedOperativeOrchardIdInFS__c = 'T001';
                    saList.add(sa);
                }
            }
        }

        Test.startTest();
        update saList;
        Test.stopTest();

        list<WorkPlan> wpList = UthWorkPlan.getAllWithWorkSteps(wo.Id);
        system.Assert.areEqual(2, wpList.size());
        
        for(WorkPlan w : wpList){
            system.Assert.areNotEqual(null, w.ServiceAppointment__c);
            system.Assert.areEqual(true, w.Name.startsWith('Test Plan Template for SA-'));
            system.Assert.areEqual(true, w.Name.endsWith('- Tech Resource'));
            system.Assert.areEqual(1, w.WorkSteps.size());
        }        

        list<WorkPlanShare> wpShareList = UthWorkPlanShare.getAll(new list<Id>{wpList[0].Id,wpList[1].Id}, new list<Id>{UthServiceResource.getAll()[0].RelatedRecordId});
        system.assert.areEqual(2, wpShareList.size());
    }

    @isTest
    static void workplanCloneNegative() {
        list<WorkOrder> woList = UthWorkOrder.getAllWOsWithSAs();
        WorkOrder wo;
        list<ServiceAppointment> saList = new list<ServiceAppointment>();

        for(WorkOrder w : woList){
            if(w.OrchardJobNumber__c == 'ORCH01'){
                wo = w;
                for(ServiceAppointment sa : w.ServiceAppointments){
                    sa.status = ServiceAppointmentDecorator.STATUS_DISPATCHED;
                    sa.AssignedOperativeOrchardIdInFS__c = 'T001';
                    saList.add(sa);
                }
            }
        }
        
        WorkPlanTemplate wpt = UthWorkPlanTemplate.getAll()[0];
        wpt.IsApplicableToServiceAppointment__c = false;
        update wpt;        
        WorkPlan wp = UthWorkPlan.getAll(wo.Id)[0];
        wp.IsApplicableToServiceAppointment__c = false;
        update wp;

        Test.startTest();
        update saList;
        Test.stopTest();

        list<WorkPlan> wpList = UthWorkPlan.getAllWithWorkSteps(wo.Id);
        system.Assert.areEqual(1, wpList.size());
        system.Assert.areEqual(null, wpList[0].ServiceAppointment__c);
        system.Assert.areEqual('Test Plan Template', wpList[0].Name);
        system.Assert.areEqual(1, wpList[0].WorkSteps.size());
        
        list<WorkPlanShare> wpShareList = UthWorkPlanShare.getAll(new list<Id>{wpList[0].Id}, new list<Id>{UthServiceResource.getAll()[0].RelatedRecordId});
        system.assert.areEqual(0, wpShareList.size());
    }

    @isTest
    static void workPlanCloneWithMultipleWorkOrders() {

        list<ServiceAppointment> saList = UthServiceAppointment.getAll();        

        for(ServiceAppointment saRec : saList){
            saRec.status = ServiceAppointmentDecorator.STATUS_DISPATCHED;
            saRec.AssignedOperativeOrchardIdInFS__c = 'T001';
        }

        Test.startTest();       
        update saList;
        Test.stopTest();

        map<Id, WorkPlan> wpMap = new map<Id, WorkPlan>(UthWorkPlan.getAll());
        system.Assert.areEqual(4, wpMap.size());
        for(WorkPlan wpRec : wpMap.values()){
            system.Assert.areNotEqual(null, wpRec.ServiceAppointment__c);
            system.Assert.areEqual(true, wpRec.Name.startsWith('Test Plan Template for SA-'));
            system.Assert.areEqual(true, wpRec.Name.endsWith('- Tech Resource'));
            system.Assert.areEqual(1, wpRec.WorkSteps.size());
        }
        list<WorkPlanShare> wpShareList = UthWorkPlanShare.getAll(new list<Id>(wpMap.keyset()), new list<Id>{UthServiceResource.getAll()[0].RelatedRecordId});
        system.assert.areEqual(4, wpShareList.size());
    }    

    @isTest
    static void workPlanCloneWithMultipleWorkOrdersNegative() {

        WorkPlanTemplate wpt = UthWorkPlanTemplate.getAll()[0];
        wpt.IsApplicableToServiceAppointment__c = false;
        update wpt;  

        list<WorkPlan> wpList = UthWorkPlan.getAll();
        for(WorkPlan wpRec : wpList){
            wpRec.IsApplicableToServiceAppointment__c = false;
        }
        update wpList;

        list<ServiceAppointment> saList = UthServiceAppointment.getAll();        

        for(ServiceAppointment saRec : saList){
            saRec.status = ServiceAppointmentDecorator.STATUS_DISPATCHED;
            saRec.AssignedOperativeOrchardIdInFS__c = 'T001';
        }

        Test.startTest();       
        update saList;
        Test.stopTest();

        map<Id, WorkPlan> wpMap = new map<Id, WorkPlan>(UthWorkPlan.getAll());
        system.Assert.areEqual(2, wpMap.size());

        for(WorkPlan wpRec : wpMap.values()){
            system.Assert.areEqual(null, wpRec.ServiceAppointment__c);
            system.Assert.areEqual('Test Plan Template', wpRec.Name);
        }
        list<WorkPlanShare> wpShareList = UthWorkPlanShare.getAll(new list<Id>(wpMap.keyset()), new list<Id>{UthServiceResource.getAll()[0].RelatedRecordId});
        system.assert.areEqual(0, wpShareList.size());
    }
}