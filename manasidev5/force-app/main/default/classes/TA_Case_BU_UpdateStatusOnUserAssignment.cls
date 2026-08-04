public with sharing class TA_Case_BU_UpdateStatusOnUserAssignment implements TriggerAction.BeforeUpdate {
    
    private static final String USER_PREFIX = '005';
    private static final String QUEUE_PREFIX = '00G';
    
    public void beforeUpdate(List<Case> newList, List<Case> oldList) {
        Map<Id, Case> oldMap = new Map<Id, Case>(oldList); 
        for (Case newCase : newList) {
            Case oldCase = oldMap.get(newCase.Id); 
            if(newCase.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_TERMINATION &&
               newCase.Tenancy__c == null && newCase.Origin == CaseDecorator.CASE_ORIGIN_GUEST_PORTAL){
                break;
            }
            if (String.valueOf(oldCase.OwnerId).startsWith(QUEUE_PREFIX) &&
                    String.valueOf(newCase.OwnerId).startsWith(USER_PREFIX) && 
                    CaseAssignmentRuleService.CaseAssignmentRulesById.containsKey(oldCase.OwnerId)) {
                newCase.SubStatus__c = CaseAssignmentRuleService.CaseAssignmentRulesById.get(oldCase.OwnerId)?.SubStatus__c;
                newCase.Status = CaseAssignmentRuleService.CaseAssignmentRulesById.get(oldCase.OwnerId)?.Status__c;
            }
        }
    }
}