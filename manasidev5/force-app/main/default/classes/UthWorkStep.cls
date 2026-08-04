public with sharing class UthWorkStep {  
    
    public static WorkStep build(WorkPlan wp, String name){
        WorkStep ws = new WorkStep();
        ws.Name = name;
        ws.WorkPlanId = wp.Id;
        ws.ExecutionOrder = 1;
        return ws;
    }

    public static List<WorkStep> getAll(){
        return Database.query('SELECT '+
            String.join(new List<String>(WorkStep.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
            + ' FROM WorkStep');
    }
}