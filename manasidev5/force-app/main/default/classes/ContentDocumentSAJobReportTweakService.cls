public without sharing class ContentDocumentSAJobReportTweakService {

    private Map<Id, ContentDocument> cdMap;
    List<Id> linkedEntityIdList;

    private Map<Id, ContentDocumentLink> cdLinkMap{
        get{
            if(this.cdLinkMap == null){
                this.cdLinkMap = new Map<Id, ContentDocumentLink>();
                this.linkedEntityIdList = new List<Id>();
                for(ContentDocumentLink cdlRec : [SELECT Id, ContentDocumentId, LinkedEntityId 
                                FROM ContentDocumentLink 
                                WHERE ContentDocumentId IN :this.cdMap.keySet()]){
                    if(cdlRec.LinkedEntityId != null && cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == ServiceAppointmentDecorator.SOBJECT_APINAME){
                        this.cdLinkMap.put(cdlRec.Id, cdlRec);   
                        this.linkedEntityIdList.add(cdlRec.LinkedEntityId);                     
                    }
                }
            }
            return this.cdLinkMap;
        }
        set;
    }

    private Map<Id, ServiceAppointment> saMap{
        get{
            if(this.saMap == null){
                this.saMap = new Map<Id, ServiceAppointment>();
                for(ServiceAppointment saRec : [SELECT Id, AppointmentNumber, ParentWorkOrder__r.WorkOrderNumber
                                FROM ServiceAppointment 
                                WHERE Id IN :this.linkedEntityIdList]){
                    this.saMap.put(saRec.Id, saRec);
                }
            }
            return this.saMap;
        }
        set;
    }

    private List<ContentDocument> cdToUpdateList{
        get{
            if(this.cdToUpdateList == null){
                this.cdToUpdateList = new List<ContentDocument>();
                for(ContentDocumentLink cdlRec : this.cdLinkMap.values()){                 
                    if(this.saMap.containsKey(cdlRec.LinkedEntityId)){     
                        this.cdToUpdateList.add(
                            new ContentDocument(
                                Id = cdlRec.ContentDocumentId,
                                Title = String.format('{0} {1} {2} {3}', new List<String>{
                                    this.saMap.get(cdlRec.LinkedEntityId).ParentWorkOrder__r.WorkOrderNumber,
                                    this.saMap.get(cdlRec.LinkedEntityId).AppointmentNumber,
                                    ContentDocumentDecorator.FS_DMC_JOB_SERVICE_REPORT,
                                    DateTime.now().format('yyyy-MM-dd HH:mm')
                                })
                            )
                        );
                    }
                }
            }
            return this.cdToUpdateList;
        }
        set;
    }

    public ContentDocumentSAJobReportTweakService(List<ContentDocument> cdList){
        this.cdMap = new Map<Id, ContentDocument>(cdList);
    }

    public void tweakJobReportName(){
        if(!this.cdToUpdateList.isEmpty()){
            update this.cdToUpdateList;
        }
    }

    public inherited sharing class ContentDocumentSAJobReportTweakQueueable implements Queueable{ 
        
        private List<ContentDocument> cdList;

        public ContentDocumentSAJobReportTweakQueueable(List<ContentDocument> cdList){
            this.cdList = cdList;
        }
        
        public void execute(QueueableContext context) {       
            new ContentDocumentSAJobReportTweakService(this.cdList).tweakJobReportName();
        }
    }
}