public inherited sharing class WorkStepFileNameTweakingService {
    
    private Map<Id, WorkStep> WorkStepMap;    
    
    private String getDateTimeFormat{
        get{
            if(getDateTimeFormat == null){
                getDateTimeFormat = System.Now().format('dd') +
                System.Now().format('MM') +
                System.Now().format('yy') +
                System.Now().format('HH') +
                System.Now().format('mm');
            }
            return this.getDateTimeFormat;
        }
        set;
    }  

    private Map<String, Integer> saWsToCounter{
        get{
            if(this.saWsToCounter == null){
                this.saWsToCounter = new Map<String, Integer>();
            }
            return this.saWsToCounter;
        }
        set;
    } 

    private Map<Id, List<WorkStep>> workStepsBySaId{
        get{
            if(this.workStepsBySaId == null){
                this.workStepsBySaId = new Map<Id, List<WorkStep>>();
                for(WorkStep workStepRec : this.WorkStepMap.values()){
                    if(String.isNotBlank(workStepRec.ServiceAppointment__c)){
                        if(!this.workStepsBySaId.containsKey(workStepRec.ServiceAppointment__c)){
                            this.workStepsBySaId.put(workStepRec.ServiceAppointment__c, new List<WorkStep>{workStepRec});
                        }else{
                            this.workStepsBySaId.get(workStepRec.ServiceAppointment__c).add(workStepRec);
                        }
                    }
                }
            }            
            return this.workStepsBySaId;
        }        
        set;
    }

    private List<ContentDocumentLink> cdlList{
        get{
            if(this.cdlList == null){
                this.cdlList = new List<ContentDocumentLink>();
                if(this.workStepsBySaId != null && !this.workStepsBySaId.isEmpty()){
                    this.cdlList = [SELECT Id, LinkedEntityId, LinkedEntity.Name, ContentDocumentId, ContentDocument.Title   
                                    FROM ContentDocumentLink 
                                    WHERE LinkedEntityId IN :this.workStepsBySaId.keyset()];   
                }                
            }
            return this.cdlList;
        }
        set;
    }

    private Map<Id, ContentDocument> contentDocumentToUpsert{
        get{
            if(this.contentDocumentToUpsert == null){
                this.contentDocumentToUpsert = new Map<Id, ContentDocument>();
                for(ContentDocumentLink cdlRec : this.cdlList){
                    List<WorkStep> workSteps = new List<WorkStep>();
                    if(this.workStepsBySaId.containsKey(cdlRec.LinkedEntityId)){
                        workSteps = this.workStepsBySaId.get(cdlRec.LinkedEntityId);
                    }
                    for(WorkStep workStepRec : workSteps){
                        List<String> fileNames = workStepRec.UploadedFileNames__c.split(';');
                        for(String fileName : fileNames){
                            if(fileName.equals(cdlRec.ContentDocument.Title)){
                                String key = cdlRec.LinkedEntityId +'-'+ workStepRec.Id;
                                if(!this.saWsToCounter.containsKey(key)){
                                    this.saWsToCounter.put(key, 1);
                                }else{
                                    this.saWsToCounter.put(key, this.saWsToCounter.get(key) + 1);
                                }
                                Integer counter = this.saWsToCounter.get(key);
                                String title = getTitle(cdlRec, workStepRec, counter);
                                this.contentDocumentToUpsert.put(cdlRec.ContentDocumentId, 
                                    new ContentDocument(
                                        Id = cdlRec.ContentDocumentId, 
                                        Title = title,
                                        description  = title
                                    )
                                );
                            }
                        }
                    }
                }
                    
            }
            return this.contentDocumentToUpsert;
        }
        set;
    }
        
    
    public WorkStepFileNameTweakingService(List<WorkStep> workSteps) {
        this.WorkStepMap = new Map<Id, WorkStep>(workSteps);
    }

    public void execute(){
        if(!this.contentDocumentToUpsert.isEmpty()){
            upsert this.contentDocumentToUpsert.values();
        }
    }

    private String getTitle(ContentDocumentLink cdlRec, WorkStep workStepRec, Integer counter){
        String dateTimeF = this.getDateTimeFormat;
        return workStepRec.Name + '_' + cdlRec.LinkedEntity.Name + '_' + dateTimeF + '_' + counter;
    }

    public without sharing class WorkStepFileNameTweakingQueueable implements Queueable{ 
        private List<WorkStep> workSteps = new List<WorkStep>();

        public WorkStepFileNameTweakingQueueable(List<WorkStep> workSteps){
            this.workSteps = workSteps;
        }
        
        public void execute(QueueableContext context) {    
            new WorkStepFileNameTweakingService(workSteps).execute();
        }
    }

}