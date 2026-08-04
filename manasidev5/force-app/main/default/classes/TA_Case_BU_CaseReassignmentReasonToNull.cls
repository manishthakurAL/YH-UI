public with sharing class TA_Case_BU_CaseReassignmentReasonToNull implements TriggerAction.BeforeUpdate{
    
    public void beforeUpdate(List<Case> newList, List<Case> oldList){
        
        Map<Id, Case> oldCasesMap = new Map<Id, Case>(oldList);
        for(Case caseRecord : newList) {
            if(caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_GENERAL_ENQUIRY &&
                caseRecord.OwnerId != oldCasesMap.get(caseRecord.Id).OwnerId &&
                (caseRecord.Status != CaseDecorator.STATUS_NEW &&
                caseRecord.Status != CaseDecorator.STATUS_EMAIL_RESPONSE_RECEIVED)){
                    if(caseRecord.CaseReAssignmentReason__c == null) {
                        caseRecord.addError(system.Label.GeneralEnquiryCaseOwnerChangeReassignmentReaosnRequired);
                    }else{
                        caseRecord.CaseReAssignmentReason__c = null;
                    }
            }
        }
    }
}