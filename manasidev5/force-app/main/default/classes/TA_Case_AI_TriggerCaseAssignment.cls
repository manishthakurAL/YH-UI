public with sharing class TA_Case_AI_TriggerCaseAssignment implements TriggerAction.AfterInsert{
    
    public void afterInsert(List<Case> newList){
        CaseAssignmentTriggerService.triggerCaseAssignmentRules(newList, null);
    }
}