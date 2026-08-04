public with sharing class TA_TenancyChange_AU_ManageChanges implements TriggerAction.AfterUpdate{
    public void afterUpdate(List<TenancyChange__c> newList, List<TenancyChange__c> oldList) {
        Map<Id, TenancyChange__c> oldMap = new Map<Id, TenancyChange__c>(oldList);
        Map<Id, TenancyChange__c> newMap = new Map<Id, TenancyChange__c>(newList);
        Map<Id,TenancyChange__c> tenancyChangeByCaseIdMap  = new Map<Id,TenancyChange__c>();

        for(TenancyChange__c tcRec : newList){
            if(newMap.get(tcRec.Id).CaseStatus__c != oldMap.get(tcRec.Id).CaseStatus__c && 
                    newMap.get(tcRec.Id).CaseStatus__c == CaseDecorator.STATUS_STAGE_CLOSED && 
                    (tcRec.CaseOutcome__c == CaseDecorator.CASE_OUTCOME_APPROVED ||
                    tcRec.CaseOutcome__c == CaseDecorator.CASE_OUTCOME_COMPLETED ) &&
                    TenancyChangeService.MANAGE_MEMBERS_FOR_CHANGE_CASETYPES.contains(tcRec.ParentCaseType__c) ){
                tenancyChangeByCaseIdMap.put(tcRec.case__c, tcRec);
            }
        }

        if(!tenancyChangeByCaseIdMap.isEmpty()){
            Map<Id, String> tenancyChangeErrorById = new TenancyChangeService(tenancyChangeByCaseIdMap).applyChanges();
            for(Id tenancyChangeId : tenancyChangeErrorById.keySet()){
                newMap.get(tenancyChangeId).addError(tenancyChangeErrorById.get(tenancyChangeId));
            }
        }
    }
}