public with sharing class TA_Case_AU_MEXTenancyUpdate implements TriggerAction.AfterUpdate {

    public void afterUpdate(List<Case> newList, List<Case> oldList){
        Map<Id, Case> oldMap = new Map<Id, Case>(oldList);
        Map<Id, Case> newMap = new Map<Id, Case>(newList);
        Map<Id, Case> mexCaseMap = new Map<Id, Case>();

        for(Case c : newList){
            if(TriggerBase.idToNumberOfTimesSeenAfterUpdate.get(c.id) == 1
                && c.recordTypeId == CaseDecorator.RECORD_TYPE_ID_CHANGES
                && c.CaseType__c == CaseDecorator.CASE_TYPE_MUTUAL_EXCHANGE 
                && c.status != oldMap.get(c.Id).status 
                && c.status == CaseDecorator.STATUS_STAGE_CLOSED
                && c.CaseOutcome__c == CaseDecorator.CASE_OUTCOME_COMPLETED ){
                    mexCaseMap.put(c.Id, c);
            }
        }
        
        if(!mexCaseMap.isEmpty()){
            new MEXTenancyUpdateService(mexCaseMap).applyChanges();
        }
        
    }
}