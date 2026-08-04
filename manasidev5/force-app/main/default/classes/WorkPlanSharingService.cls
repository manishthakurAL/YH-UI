public without sharing class WorkPlanSharingService {

    private map<Id,WorkPlan> workPlanMap;
    private set<Id> operativeIds;

    private list<WorkPlanShare> workPlanShareInsert{
        get{
            if(this.workPlanShareInsert == null){
                this.workPlanShareInsert = new list<WorkPlanShare>();
                for(WorkPlan wpRec : this.workPlanMap.values()){
                    if(wpRec.AssignedResourceId__c != null){
                        WorkPlanShare wsRec = new WorkPlanShare();
                        wsRec.ParentId = wpRec.Id;
                        wsRec.UserOrGroupId = wpRec.AssignedResourceId__c;
                        wsRec.AccessLevel = ServiceAppointmentDecorator.SHARE_ACCESS_EDIT;
                        wsRec.RowCause = ServiceAppointmentDecorator.SHARE_ACCESS_MANUAL;
                        this.workPlanShareInsert.add(wsRec);
                    }
                }
            }            
            return this.workPlanShareInsert;
        }
        set;
    }

    private list<WorkPlanShare> workPlanShareDelete{
        get{
            if(this.workPlanShareDelete == null){
                this.workPlanShareDelete = new list<WorkPlanShare>();
                this.workPlanShareDelete = [SELECT Id,ParentId,UserOrGroupId 
                        FROM WorkPlanShare 
                        WHERE ParentId IN :this.workPlanMap.keyset() AND
                        UserOrGroupId IN :this.operativeIds AND
                        AccessLevel = :ServiceAppointmentDecorator.SHARE_ACCESS_EDIT AND
                        RowCause = :ServiceAppointmentDecorator.SHARE_ACCESS_MANUAL];
            }
            return this.workPlanShareDelete;
        }
        set;
    }

    public WorkPlanSharingService(list<WorkPlan> workPlans){
        this.workPlanMap = new map<Id,WorkPlan>(workPlans);
    }

    public WorkPlanSharingService(list<WorkPlan> workPlans, set<Id> operativeIds){
        this.workPlanMap = new map<Id,WorkPlan>(workPlans);
        this.operativeIds = operativeIds;
    }

    public void shareWorkPlans(){
        if(!this.workPlanShareInsert.isEmpty()){
            Insert this.workPlanShareInsert;
        } 
    }

    public void unshareWorkPlans(){
        if(!this.workPlanShareDelete.isEmpty()){
            Delete this.workPlanShareDelete;
        } 
    }
}