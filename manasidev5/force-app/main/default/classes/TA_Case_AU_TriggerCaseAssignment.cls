public with sharing class TA_Case_AU_TriggerCaseAssignment implements TriggerAction.AfterUpdate{
    
    public void afterUpdate(List<Case> newList, List<Case> oldList){
        CaseAssignmentTriggerService.triggerCaseAssignmentRules(newList, new Map<Id, Case>(oldList));
    }
}