@isTest
public with sharing class UthWorkPlanTemplate {

    public static WorkPlanTemplate setupWorkPlanStepTemplate(){
        WorkPlanTemplate wp = createWorkPlan();
        WorkStepTemplate ws = createWorkStep();
        WorkPlanTemplateEntry wpe = createWorkPlanEntries(wp, ws);
        return wp;
    }

    public static WorkPlanTemplate createWorkPlan(){
        WorkPlanTemplate wp = new WorkPlanTemplate();
        wp.Name = 'Test Plan Template';
        wp.IsActive = true;
        wp.IsApplicableToServiceAppointment__c = true;
        wp.RelativeExecutionOrder = 1;
        Insert wp;
        return wp;
    }
    
    public static WorkStepTemplate createWorkStep(){
        WorkStepTemplate ws = new WorkStepTemplate();
        ws.Name = 'Test Step Template';
        ws.IsActive = true;
        Insert ws;
        return ws;
    }
    
    public static WorkPlanTemplateEntry createWorkPlanEntries(WorkPlanTemplate wp, WorkStepTemplate ws){
        WorkPlanTemplateEntry wpe = new WorkPlanTemplateEntry();
        wpe.WorkPlanTemplateId = wp.Id;
        wpe.WorkStepTemplateId = ws.Id;
        wpe.ExecutionOrder = 1;
        Insert wpe;
        return wpe;
    }

    public static list<WorkPlanTemplate> getAll(){
        return Database.query('SELECT '+
                String.join(new List<String>(WorkPlanTemplate.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM WorkPlanTemplate');
    }
}