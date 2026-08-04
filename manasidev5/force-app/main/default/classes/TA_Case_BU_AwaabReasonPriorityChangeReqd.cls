public with sharing class TA_Case_BU_AwaabReasonPriorityChangeReqd implements TriggerAction.BeforeUpdate {
    public static void beforeUpdate(List<Case> newList, List<Case> oldList) {
        Map<Id,Case> oldMap = new Map<Id,Case>(oldList);
        Map<Id, Case> newMap = new Map<Id, Case>(newList);

        for (Case acase : newList) {
            Case oldCaseRecord = oldMap.get(acase.Id); 
            if (acase.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_AWAABSLAW && 
                        acase.Priority != oldCaseRecord.Priority &&
                        String.isNotBlank(oldCaseRecord.Priority) && String.isBlank(acase.PriorityChangeReason__c )) {
              acase.addError(Label.AwaabReasonForPriorityRequired);
            }
        }
    }
}