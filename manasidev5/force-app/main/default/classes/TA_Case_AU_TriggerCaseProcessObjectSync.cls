public with sharing class TA_Case_AU_TriggerCaseProcessObjectSync implements TriggerAction.AfterUpdate{
    
    public void afterUpdate(List<Case> newList, List<Case> oldList){
        CaseProcessObjectSyncService.get().syncCaseToProcessObject(newList,  new Map<Id, Case>(oldList));
    }
}