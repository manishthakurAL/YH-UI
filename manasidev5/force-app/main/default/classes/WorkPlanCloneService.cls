public inherited sharing class WorkPlanCloneService{

    private Map<Id, set<Id>> saIdsByWoIdMap;
    private Map<Id, ServiceAppointment> saMap;
    set<Id> wpTemplateIdSet; 

    
    private Map<Id, Id> firstSaIdByWoIdMap{
        get{
            if(this.firstSaIdByWoIdMap == null){
                this.firstSaIdByWoIdMap = new Map<Id, Id>();
                this.saIdsByWoIdMap = new Map<Id, set<Id>>();
                for(ServiceAppointment saRec : this.saMap.values()){
                    if(!this.firstSaIdByWoIdMap.containskey(saRec.ParentRecordId)){
                        this.firstSaIdByWoIdMap.put(saRec.ParentRecordId, saRec.Id);
                    }else{
                        if(!this.saIdsByWoIdMap.containskey(saRec.ParentRecordId)){
                            this.saIdsByWoIdMap.put(saRec.ParentRecordId, new set<Id>{saRec.Id});
                        }else{
                            this.saIdsByWoIdMap.get(saRec.ParentRecordId).add(saRec.Id);
                        }
                    }    
                }
            }
            return this.firstSaIdByWoIdMap;
        }
        set;
    }
    
    private Map<Id, AssignedResource> arBySaIdMap{
        get{
            if(this.arBySaIdMap == null){
                this.arBySaIdMap = new Map<Id, AssignedResource>();
                if(!this.saMap.isEmpty()){
                    for(AssignedResource ar : [SELECT Id, ServiceAppointmentId, ServiceResource.Name, ServiceResource.RelatedRecordId 
                            FROM AssignedResource where ServiceAppointmentId IN :this.saMap.keyset()]){
                        this.arBySaIdMap.put(ar.ServiceAppointmentId, ar);
                    }
                }
            }
            return this.arBySaIdMap;
        }
        set;
    }
    
    private map<Id, set<Id>> wpTemplateIdsByWoIdMap{
        get{
            if(this.wpTemplateIdsByWoIdMap == null){
                this.wpTemplateIdsByWoIdMap = new map<Id, set<Id>>();
                this.wpTemplateIdSet = new set<Id>();
                for(Workplan wpRec : [SELECT Id,WorkPlanTemplateId,ParentRecordId,WorkPlanTemplate__c,AssignedResourceId__c 
                        FROM WorkPlan 
                        WHERE ParentRecordId IN :this.saIdsByWoIdMap.keyset() AND 
                        (WorkPlanTemplateId != NULL OR WorkPlanTemplate__c != NULL) AND 
                        (WorkPlanTemplate__r.IsApplicableToServiceAppointment__c = true OR 
                        WorkPlanTemplate.IsApplicableToServiceAppointment__c = true)]){
                    Id WorkPlanTemplateId;
                    if(wpRec.WorkPlanTemplateId != null){
                        WorkPlanTemplateId = wpRec.WorkPlanTemplateId;
                    }else if(wpRec.WorkPlanTemplate__c != null){
                        WorkPlanTemplateId = wpRec.WorkPlanTemplate__c;
                    }
                    if(!this.wpTemplateIdsByWoIdMap.containskey(wpRec.ParentRecordId)){
                        this.wpTemplateIdsByWoIdMap.put(wpRec.ParentRecordId, new set<Id>{WorkPlanTemplateId});
                    }else{
                        this.wpTemplateIdsByWoIdMap.get(wpRec.ParentRecordId).add(WorkPlanTemplateId);
                    }
                    this.wpTemplateIdSet.add(WorkPlanTemplateId);
                }
            }
            return this.wpTemplateIdsByWoIdMap;
        }
        set;
    }
    
    private map<Id, list<WorkPlanTemplateEntry>> workPlanTemplateEntriesMap{
        get{
            if(this.workPlanTemplateEntriesMap == null){
                this.workPlanTemplateEntriesMap = new map<Id, list<WorkPlanTemplateEntry>>();        
                if(!this.wpTemplateIdSet.isEmpty()){
                    for(WorkPlanTemplateEntry wpTempEntryRec : [SELECT Id,WorkPlanTemplateId,WorkStepTemplateId,WorkStepTemplate.ActionDefinition,
                            WorkStepTemplate.IsActive,WorkStepTemplate.Description,WorkStepTemplate.Name,ExecutionOrder 
                            FROM WorkPlanTemplateEntry 
                            WHERE WorkPlanTemplateId IN :this.wpTemplateIdSet AND WorkStepTemplate.IsActive = true]){
                        if(!this.workPlanTemplateEntriesMap.containskey(wpTempEntryRec.WorkPlanTemplateId)){
                            this.workPlanTemplateEntriesMap.put(wpTempEntryRec.WorkPlanTemplateId, new list<WorkPlanTemplateEntry>{wpTempEntryRec});
                        }else{
                            this.workPlanTemplateEntriesMap.get(wpTempEntryRec.WorkPlanTemplateId).add(wpTempEntryRec);
                        }
                    }
                }
            }
            return this.workPlanTemplateEntriesMap;
        }
        set;
    } 
    
    private map<Id, WorkPlanTemplate> workPlantemplatesMap{
        get{
            if(this.workPlantemplatesMap == null){
                this.workPlantemplatesMap = new map<Id, WorkPlanTemplate>();
                if(!this.wpTemplateIdSet.isEmpty()){
                    this.workPlantemplatesMap = new map<Id, WorkPlanTemplate>([SELECT Id,Name,RelativeExecutionOrder, IsActive, 
                            Description, IsApplicableToServiceAppointment__c 
                            FROM WorkPlanTemplate 
                            WHERE Id IN :this.wpTemplateIdSet AND IsActive = true AND IsApplicableToServiceAppointment__c = true]);
                }
            }
            return this.workPlantemplatesMap;
        }
        set;
    }    

    private map<Id,WorkPlan> workPlanToUpdate{
        get{
            if(this.workPlanToUpdate == null){
                this.workPlanToUpdate = new map<Id,WorkPlan>();
                map<Id, set<Id>> templateIdsByWoIdMap = new map<Id, set<Id>>();
                for(Workplan wpRec : [SELECT Id,Name,ParentRecordId,ServiceAppointment__c,WorkPlanTemplate__c,WorkPlanTemplateId,AssignedResourceId__c 
                        FROM WorkPlan 
                        WHERE ParentRecordId IN :this.firstSaIdByWoIdMap.keyset() AND 
                        IsApplicableToServiceAppointment__c = true 
                        ORDER BY ServiceAppointment__c NULLS FIRST, WorkPlanTemplateId NULLS LAST]){
                    if(wpRec.ServiceAppointment__c == null){
                        Id wpTemplateId;
                        boolean linkWpAndSa = false;
                        if(wpRec.WorkPlanTemplateId != null){
                            wpTemplateId = wpRec.WorkPlanTemplateId;
                        }else if(wpRec.WorkPlanTemplate__c != null){
                            wpTemplateId = wpRec.WorkPlanTemplate__c;
                        }
                        if(templateIdsByWoIdMap.containskey(wpRec.ParentRecordId)){
                            if(!templateIdsByWoIdMap.get(wpRec.ParentRecordId).contains(wpTemplateId)){
                                linkWpAndSa = true;
                            }
                        }else{
                            linkWpAndSa = true;
                        }
                        if(linkWpAndSa){
                            wpRec.ServiceAppointment__c = this.firstSaIdByWoIdMap.get(wpRec.ParentRecordId);
                            wpRec.IsServiceAppointmentLinked__c = true;
                            wpRec.Name = wpRec.Name + ServiceAppointmentDecorator.SPACE + ServiceAppointmentDecorator.KEYWORD_FOR + ServiceAppointmentDecorator.SPACE + this.saMap.get(wpRec.ServiceAppointment__c).AppointmentNumber;
                            if(this.arBySaIdMap.containskey(wpRec.ServiceAppointment__c)){
                                wpRec.Name = wpRec.Name + ServiceAppointmentDecorator.SPACE + ServiceAppointmentDecorator.HYPHEN + ServiceAppointmentDecorator.SPACE + this.arBySaIdMap.get(wpRec.ServiceAppointment__c).ServiceResource.Name;
                                wpRec.AssignedResourceId__c = this.arBySaIdMap.get(wpRec.ServiceAppointment__c).ServiceResource.RelatedRecordId;
                            }
                            this.workPlanToUpdate.put(wpRec.Id, wpRec);
                        }

                        if(templateIdsByWoIdMap.containskey(wpRec.ParentRecordId)){
                            templateIdsByWoIdMap.get(wpRec.ParentRecordId).add(wpTemplateId);
                        }else{
                            templateIdsByWoIdMap.put(wpRec.ParentRecordId, new set<Id>{wpTemplateId});
                        }
                    }else if(!templateIdsByWoIdMap.containskey(wpRec.ParentRecordId)){
                        if(this.saIdsByWoIdMap.containskey(wpRec.ParentRecordId)){
                            this.saIdsByWoIdMap.get(wpRec.ParentRecordId).add(this.firstSaIdByWoIdMap.get(wpRec.ParentRecordId));
                        }else{
                            this.saIdsByWoIdMap.put(wpRec.ParentRecordId, new set<Id>{this.firstSaIdByWoIdMap.get(wpRec.ParentRecordId)});
                        }
                    }
                }
            }
            return this.workPlanToUpdate;
        }
        set;
    }

    private list<WorkPlan> workPlanToInsert{
        get{
            if(this.workPlanToInsert == null){
                this.workPlanToInsert = new list<WorkPlan>();
                for(Id woId : this.saIdsByWoIdMap.keyset()){
                    for(Id saId : this.saIdsByWoIdMap.get(woId)){
                        if(this.wpTemplateIdsByWoIdMap.containskey(woId)){
                            for(Id wptId : this.wpTemplateIdsByWoIdMap.get(woId)){
                                WorkPlanTemplate wpt = this.workPlantemplatesMap.get(wptId);
                                if(wpt != null){
                                    WorkPlan wpRec = new WorkPlan();
                                    wpRec.ParentRecordId = woId;
                                    wpRec.Name = wpt.Name + ServiceAppointmentDecorator.SPACE + ServiceAppointmentDecorator.KEYWORD_FOR + ServiceAppointmentDecorator.SPACE + this.saMap.get(saId).AppointmentNumber;
                                    wpRec.Name = wpRec.Name + ServiceAppointmentDecorator.SPACE + ServiceAppointmentDecorator.HYPHEN + ServiceAppointmentDecorator.SPACE +this.arBySaIdMap.get(saId).ServiceResource.Name;
                                    wpRec.ExecutionOrder = wpt.RelativeExecutionOrder;
                                    wpRec.ServiceAppointment__c = saId;
                            		wpRec.IsServiceAppointmentLinked__c = true;
                                    wpRec.AssignedResourceId__c = this.arBySaIdMap.get(saId).ServiceResource.RelatedRecordId;
                                    wpRec.WorkPlanTemplate__c = wpt.Id;
                                    wpRec.IsApplicableToServiceAppointment__c = true;
                                    this.workPlanToInsert.add(wpRec);                        
                                }
                            }
                        }
                    }
                }
            }
            return this.workPlanToInsert;
        }
        set;
    }

    private list<WorkStep> workStepToInsert{
        get{
            if(this.workStepToInsert == null){
                this.workStepToInsert = new list<WorkStep>();
                for(workPlan wpRec : this.workPlanToInsert){
                    for(WorkPlanTemplateEntry wpte : this.workPlanTemplateEntriesMap.get(wpRec.WorkPlanTemplate__c)){
                        WorkStep wsRec = new WorkStep();
                        wsRec.Name = wpte.WorkStepTemplate.Name;
                        wsRec.WorkPlanId = wpRec.Id;
                        wsRec.ExecutionOrder = wpte.ExecutionOrder;
                        wsRec.Description = wpte.WorkStepTemplate.Description;
                        if(wpte.WorkStepTemplate.ActionDefinition != null){
                            wsRec.ActionDefinition = wpte.WorkStepTemplate.ActionDefinition;
                        }
                        this.workStepToInsert.add(wsRec);
                    }
                }
            }
            return this.workStepToInsert;
        }
        set;
    }    

    public WorkPlanCloneService(map<Id, ServiceAppointment> saMap){
        this.saMap = saMap;
    }

    public void validateAndClone() {               
        updateExistingWorkPlan();        
        createNewWorkPlanAndSteps();
        createWorkPlanShare();
    }

    private void updateExistingWorkPlan(){
        if(!this.firstSaIdByWoIdMap.isEmpty()){        
            if(!this.workPlanToUpdate.isEmpty()){
                update this.workPlanToUpdate.values();
            }
        }
    }
    
    private void createNewWorkPlanAndSteps(){  
        if(!this.saIdsByWoIdMap.isEmpty()){
            if(!this.workPlanToInsert.isEmpty()){
                Insert this.workPlanToInsert;
            }              
            if(!workStepToInsert.isEmpty()){
                Insert this.workStepToInsert;
            }
        }
    }
    
    private void createWorkPlanShare(){
        list<WorkPlan> wpToShare = new list<WorkPlan>();
        if(this.workPlanToUpdate != null && !this.workPlanToUpdate.isEmpty()){
            wpToShare.addAll(this.workPlanToUpdate.values());
        }
        if(this.workPlanToInsert != null && !this.workPlanToInsert.isEmpty()){
            wpToShare.addAll(this.workPlanToInsert);
        }
        if(!wpToShare.isEmpty()){            
            new WorkPlanSharingService(wpToShare).shareWorkPlans();
        }
    }


    public without sharing class WorkPlanCloneQueueable implements Queueable{ 
        
        private Map<Id, ServiceAppointment> saMap;

        public WorkPlanCloneQueueable(map<Id, ServiceAppointment> saMap){
            this.saMap = saMap;
        }
        
        public void execute(QueueableContext context) {       
            new WorkPlanCloneService(saMap).validateAndClone();
        }
    }
}