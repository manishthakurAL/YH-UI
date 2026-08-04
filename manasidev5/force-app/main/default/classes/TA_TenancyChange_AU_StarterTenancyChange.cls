public with sharing class TA_TenancyChange_AU_StarterTenancyChange implements TriggerAction.AfterUpdate {
    public void afterUpdate(List<TenancyChange__c> newList, List<TenancyChange__c> oldList) {
        Map<Id, TenancyChange__c> oldMap = new Map<Id, TenancyChange__c>(oldList);
        Map<Id, TenancyChange__c> newMap = new Map<Id, TenancyChange__c>(newList);
        Map<Id,TenancyChange__c> tenancyChangeByCaseIdMap  = new Map<Id,TenancyChange__c>();


        for(TenancyChange__c tcRec : newList){
            if(newMap.get(tcRec.Id).CaseStatus__c != oldMap.get(tcRec.Id).CaseStatus__c && 
                    newMap.get(tcRec.Id).CaseStatus__c == CaseDecorator.STATUS_STAGE_CLOSED && 
                    TenancyChangeService.MANAGE_CASEOUTCOME_STARTERTENANCIES.contains(tcRec.ParentCaseType__c) 
                    && (tcRec.CaseOutcome__c == CaseDecorator.CASE_OUTCOME_DEFER || tcRec.CaseOutcome__c == CaseDecorator.CASE_OUTCOME_EXTEND
                    || tcRec.CaseOutcome__c == CaseDecorator.CASE_OUTCOME_CONVERT)){
                        tenancyChangeByCaseIdMap.put(tcRec.case__c, tcRec);
            }
        }

        if(!tenancyChangeByCaseIdMap.isEmpty()){
             new TenancyChangeService(tenancyChangeByCaseIdMap).populateDatesOnTenancyBasedOnCaseOutcome();
        }
      
    }
}