public without sharing class TA_DraftContainer_AU_SubmitProcess implements TriggerAction.AfterUpdate {
    public void afterUpdate(List<DraftContainer__c> newList, List<DraftContainer__c> oldList){
        Set<Id> submittedDraftContainersIds = new Set<Id>();
        Map<Id, Id> caseIdsByDraftContainerIds = new Map<Id, Id>();
        Map<Id, Id> taskIdsByDraftContainerIds = new Map<Id, Id>();
        List<DraftContainer__c> submittedDraftContainers = new List<DraftContainer__c>();
        Map<Id, DraftContainer__c> oldMap = new Map<Id, DraftContainer__c>(oldList);
        for(DraftContainer__c draftContainer : newList){
            if(draftContainer.Status__c == DraftContainerDecorator.STATUS_PROCESSED && oldMap.get(draftContainer.Id).Status__c != draftContainer.status__c){
                submittedDraftContainersIds.add(draftContainer.Id);
                caseIdsByDraftContainerIds.put(draftContainer.Id, draftContainer.Case__c);
                taskIdsByDraftContainerIds.put(draftContainer.Id, draftContainer.TaskId__c);
            }
        }
        
        if( !submittedDraftContainersIds.isEmpty() ){
            Set<Id> contentDocumentIds = new Set<Id>();
            List<ContentDocumentLink> newlyAddedCDL = new List<ContentDocumentLink>();
            ContentDocumentLinkService service = new ContentDocumentLinkService();
            List<ContentDocumentLink> links = service.getContentDocumentLinks(submittedDraftContainersIds);
            for(ContentDocumentLink link : links){
                Id recordId = caseIdsByDraftContainerIds.get(link.LinkedEntityId);
                if( !String.isBlank(recordId) ){
                    newlyAddedCDL.add(new ContentDocumentLink(
                        LinkedEntityId = recordId,
                        contentDocumentId = link.ContentDocumentId
                    ));
                }
                recordId = taskIdsByDraftContainerIds.get(link.LinkedEntityId);
                if( !String.isBlank(recordId) ){
                    newlyAddedCDL.add(new ContentDocumentLink(
                        LinkedEntityId = recordId,
                        contentDocumentId = link.ContentDocumentId
                    ));
                }                
            }
            insert newlyAddedCDL;
            delete links;
        }

    } 
}