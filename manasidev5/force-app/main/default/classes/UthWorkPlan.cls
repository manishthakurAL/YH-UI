@isTest
public with sharing class UthWorkPlan {
    
    public static WorkPlan createWorkPlan(WorkOrder wo1){
        WorkPlan wp = new WorkPlan();
        wp.Name = 'Test Plan Template';
        wp.IsApplicableToServiceAppointment__c = true;
        wp.ExecutionOrder = 1;
        wp.ParentRecordId = wo1.Id;
        wp.WorkPlanTemplate__c = UthWorkPlanTemplate.getAll()[0].Id;
        Insert wp;
        return wp;
    }
    
    public static WorkPlan createWorkPlanWithoutTemplate(WorkOrder wo1){
        WorkPlan wp = new WorkPlan();
        wp.Name = 'Test Plan Template';
        wp.IsApplicableToServiceAppointment__c = true;
        wp.ExecutionOrder = 1;
        wp.ParentRecordId = wo1.Id;
        Insert wp;
        return wp;
    }
    
    public static WorkStep createWorkStep(WorkPlan wp){
        WorkStep ws = new WorkStep();
        ws.Name = 'Test Step Template';
        ws.WorkPlanId = wp.Id;
        ws.ExecutionOrder = 1;
        Insert ws;
        return ws;
    }

    public static list<WorkPlan> getAll(Id ParentRecordId){
        return Database.query('SELECT '+
                String.join(new List<String>(WorkPlan.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM WorkPlan WHERE ParentRecordId =: ParentRecordId');
    }

    public static list<WorkPlan> getAll(){
        return Database.query('SELECT '+
                String.join(new List<String>(WorkPlan.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ', (SELECT '+
                String.join(new List<String>(WorkStep.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM WorkSteps)'
                + ' FROM WorkPlan');
    }

    public static list<WorkPlan> getAllWithWorkSteps(Id ParentRecordId){
        return Database.query('SELECT '+
                String.join(new List<String>(WorkPlan.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ', (SELECT '+
                String.join(new List<String>(WorkStep.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM WorkSteps)'
                + ' FROM WorkPlan WHERE ParentRecordId =: ParentRecordId');
    }
}