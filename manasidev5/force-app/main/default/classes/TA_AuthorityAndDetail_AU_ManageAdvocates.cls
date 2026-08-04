public with sharing class TA_AuthorityAndDetail_AU_ManageAdvocates  implements TriggerAction.AfterUpdate {

    public void afterUpdate(List<AuthorityAndDetail__c> newList, List<AuthorityAndDetail__c> oldList) {
        Map<Id, AuthorityAndDetail__c> oldMap = new Map<Id, AuthorityAndDetail__c>(oldList);
        Map<Id, AuthorityAndDetail__c> newMap = new Map<Id, AuthorityAndDetail__c>(newList);
        Map<Id,AuthorityAndDetail__c> authorityAndDetailByCaseIdMap  = new Map<Id,AuthorityAndDetail__c>();

        for(AuthorityAndDetail__c adRec : newList){
            if(newMap.get(adRec.Id).CaseStatus__c != oldMap.get(adRec.Id).CaseStatus__c && 
                    newMap.get(adRec.Id).CaseStatus__c == CaseDecorator.STATUS_STAGE_CLOSED && 
                    adRec.CaseOutcome__c == CaseDecorator.CASE_OUTCOME_APPROVED &&
                    AuthorityAndDetailService.MANAGE_ADVOCATES_FOR_CUSTOMER_CASETYPES.contains(adRec.ParentCaseType__c) ){
                        authorityAndDetailByCaseIdMap.put(adRec.case__c, adRec);
            }
        }

        if(!authorityAndDetailByCaseIdMap.isEmpty()){
            Map<Id, String> authDetailErrorById = new AuthorityAndDetailService(authorityAndDetailByCaseIdMap).applyChanges();
            for(Id authDetailId : authDetailErrorById.keySet()){
                newMap.get(authDetailId).addError(authDetailErrorById.get(authDetailId));
            }
        }
    }
}