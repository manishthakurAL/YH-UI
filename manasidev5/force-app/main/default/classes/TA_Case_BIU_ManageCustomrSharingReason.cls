public without sharing class TA_Case_BIU_ManageCustomrSharingReason implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {
    public void beforeInsert(List<Case> newList){
        List<Case> cases = new List<Case>();
        for(Case caseRecord: newList){
            if( !String.isBlank(caseRecord.CaseType__c)){
                cases.add(caseRecord);
            }
        }

        if(! cases.isEmpty()){
            CaseExternalSharingByCaseTypeManager manager = new CaseExternalSharingByCaseTypeManager(cases, null);
            manager.manageCaseSharingReason();
        }
    }

    public void beforeUpdate(List<Case> newList, List<Case> oldList){
        Map<Id, Case> oldCaseMap = new Map<Id, Case>(oldList);
        List<Case> cases = new List<Case>();
        Map<Id, Case> oldCases = new Map<Id, Case>();
        for(Case caseRecord : newList){
            if( !String.isBlank(caseRecord.CaseType__c) && 
                    (   caseRecord.CaseType__c != oldCaseMap.get(caseRecord.Id).CaseType__c || 
                        caseRecord.RecordTypeId != oldCaseMap.get(caseRecord.Id).RecordTypeId ||
                        caseRecord.CaseReadyForSharing__c != oldCaseMap.get(caseRecord.Id).CaseReadyForSharing__c ||
                        caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_TENANCY ||
                        caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_GENERAL_ENQUIRY
                    )
            ){
                cases.add(caseRecord);
                oldCases.put(caseRecord.Id, oldCaseMap.get(caseRecord.Id));
            }
        }
        if(!cases.isEmpty()){
            CaseExternalSharingByCaseTypeManager manager = new CaseExternalSharingByCaseTypeManager(cases, oldCases);
            manager.manageCaseSharingReason();
        }
    }   
}