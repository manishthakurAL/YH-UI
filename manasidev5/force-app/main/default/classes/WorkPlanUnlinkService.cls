public inherited sharing class WorkPlanUnlinkService {
    
    private Map<Id, ServiceAppointment> saMap;
    private set<Id> operativeIds;

    private list<WorkPlan> workPlansToUnlink{
        get{
            if(this.workPlansToUnlink == null){
                this.workPlansToUnlink = new list<WorkPlan>();
                this.operativeIds = new set<Id>();                
                for(WorkPlan wpRec : [SELECT Id,Name,ServiceAppointment__c,AssignedResourceId__c 
                        FROM WorkPlan 
                        WHERE ServiceAppointment__c IN :this.saMap.keyset()]){
                    operativeIds.add(wpRec.AssignedResourceId__c);
                    wpRec.ServiceAppointment__c = null;
					wpRec.IsServiceAppointmentLinked__c = false;
                    wpRec.AssignedResourceId__c = null;
                    wpRec.Name = wpRec.Name.indexOf(ServiceAppointmentDecorator.KEYWORD_FOR) > -1 ? wpRec.Name.substring(0, wpRec.Name.indexOf(ServiceAppointmentDecorator.KEYWORD_FOR)-1) : wpRec.Name;
                    this.workPlansToUnlink.add(wpRec);
                }
            }
            return this.workPlansToUnlink;
        }
        set;
    }
    
    public WorkPlanUnlinkService(map<Id, ServiceAppointment> saMap){
        this.saMap = saMap;
    }

    public void validateAndUnlink(){ 
        if(!this.workPlansToUnlink.isEmpty()){
            update this.workPlansToUnlink;
            
            if(!this.operativeIds.isEmpty()){
                new WorkPlanSharingService(this.workPlansToUnlink, this.operativeIds).unshareWorkPlans();
            }
        }
    }

    public without sharing class WorkPlanUnlinkQueueable implements Queueable{

        private Map<Id, ServiceAppointment> saMap;
        
        public WorkPlanUnlinkQueueable(map<Id, ServiceAppointment> saMap){
            this.saMap = saMap;
        }
        
        public void execute(QueueableContext context) {       
            new WorkPlanUnlinkService(saMap).validateAndUnlink();
        }         
    }
}