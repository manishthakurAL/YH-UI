public without sharing class TA_DraftContainer_BU_SubmitProcess implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<DraftContainer__c> newList, List<DraftContainer__c> oldList){
        Set<Id> submittedDraftContainersIds = new Set<Id>();
        List<DraftContainer__c> submittedDraftContainers = new List<DraftContainer__c>();
        Map<Id, DraftContainer__c> oldMap = new Map<Id, DraftContainer__c>(oldList);
        for(DraftContainer__c draftContainer : newList){
            if(draftContainer.Status__c == DraftContainerDecorator.STATUS_SUBMITTED && oldMap.get(draftContainer.Id).Status__c != DraftContainerDecorator.STATUS_SUBMITTED){
                submittedDraftContainersIds.add(draftContainer.Id);
                submittedDraftContainers.add(draftContainer);
            }
        }

        if( !submittedDraftContainersIds.isEmpty() ){
            for(DraftContainer__c draftContainer : submittedDraftContainers){
                draftContainer.Status__c = DraftContainerDecorator.STATUS_PROCESSED;
            }
        }
    } 
}