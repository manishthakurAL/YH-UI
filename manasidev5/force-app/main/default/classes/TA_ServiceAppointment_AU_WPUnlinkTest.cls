@isTest
private class TA_ServiceAppointment_AU_WPUnlinkTest {
    
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
        for(ServiceAppointment saRec : saMap.values()){
            saRec.Status = ServiceAppointmentDecorator.STATUS_DISPATCHED;
            saRec.AssignedOperativeOrchardIdInFS__c = 'T001';
        }
        update saMap.values();
		FSL.GlobalAPIS.addStatusTransition(ServiceAppointmentDecorator.STATUS_DISPATCHED, ServiceAppointmentDecorator.STATUS_NONE);
		FSL.GlobalAPIS.addStatusTransition(ServiceAppointmentDecorator.STATUS_SCHEDULED, ServiceAppointmentDecorator.STATUS_DISPATCHED);
		FSL.GlobalAPIS.addStatusTransition(ServiceAppointmentDecorator.STATUS_DISPATCHED, ServiceAppointmentDecorator.STATUS_COMPLETED);
    }

    @isTest
    static void workplanUnLink() {
        list<ServiceAppointment> saList = UthServiceAppointment.getAll();        

        for(ServiceAppointment saRec : saList){
            saRec.status = ServiceAppointmentDecorator.STATUS_NONE;
        }

        Test.startTest();       
        update saList;
        Test.stopTest();

        map<Id, WorkPlan> wpMap = new map<Id, WorkPlan>(UthWorkPlan.getAll());
        for(WorkPlan wpRec : wpMap.values()){
            system.Assert.areEqual(null, wpRec.ServiceAppointment__c);
        	system.Assert.areEqual(false, wpRec.IsServiceAppointmentLinked__c);
            system.Assert.areEqual('Test Plan Template', wpRec.Name);
        }

        list<WorkPlanShare> wpShareList = UthWorkPlanShare.getAll(new list<Id>(wpMap.keyset()), new list<Id>{UthServiceResource.getAll()[0].RelatedRecordId});
        system.assert.areEqual(0, wpShareList.size());
    }

    @isTest
    static void workplanUnLinkNegative() {
        list<ServiceAppointment> saList = UthServiceAppointment.getAll();        

        for(ServiceAppointment saRec : saList){
            saRec.status = ServiceAppointmentDecorator.STATUS_COMPLETED;
        }

        Test.startTest();        
        update saList;
        Test.stopTest();

        map<Id, WorkPlan> wpMap = new map<Id, WorkPlan>(UthWorkPlan.getAll());
        for(WorkPlan wpRec : wpMap.values()){
            system.Assert.areNotEqual(null, wpRec.ServiceAppointment__c);
        	system.Assert.areEqual(true, wpRec.IsServiceAppointmentLinked__c);
            system.Assert.areEqual(true, wpRec.Name.startsWith('Test Plan Template for SA-'));
            system.Assert.areEqual(true, wpRec.Name.endsWith('- Tech Resource'));
        }

        list<WorkPlanShare> wpShareList = UthWorkPlanShare.getAll(new list<Id>(wpMap.keyset()), new list<Id>{UthServiceResource.getAll()[0].RelatedRecordId});
        system.assert.areEqual(4, wpShareList.size());
    }

}