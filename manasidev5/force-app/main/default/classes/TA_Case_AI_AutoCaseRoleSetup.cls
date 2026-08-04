public without sharing class TA_Case_AI_AutoCaseRoleSetup implements TriggerAction.AfterInsert,TriggerAction.AfterUpdate{

    public static Boolean updateFromReporterFlow = false;
    public void afterUpdate(List<Case> newList, List<Case> oldList){
        Map<Id, Case> newMap = new Map<Id, Case>(newList);
        Map<Id, Case> oldMap = new Map<Id,Case>(oldList);
        Map<Id,Case> caseIdCaseMap  = new Map<Id,Case>();
        Map<Id,List<String>> fieldsListByCaseId = new Map<Id,List<String>>();

        for(Case caseRecord : newList){
            String caseRecordType = RecordTypeUtility.getRecordTypeDeveloperNameById(CaseDecorator.SOBJECT_TYPE_CASE, caseRecord.RecordTypeId);
            if( updateFromReporterFlow && 
               (
                   (caseRecord.Origin == CaseDecorator.CASE_ORIGIN_GUEST_PORTAL 
                		&& (caseRecord.Reporter__c != oldMap.get(caseRecord.Id).Reporter__c)) 
                   || (caseRecord.Origin == CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL 
                		&& (caseRecord.ContactId != oldMap.get(caseRecord.Id).ContactId)
                   		&& caseRecordType == CaseDecorator.RECORD_TYPE_BREACH )
               )
              ){
                caseIdCaseMap.put(caseRecord.Id, caseRecord);
                fieldsListByCaseId.put(caseRecord.Id,new List<String>{CaseDecorator.FIELD_REPORTER});
                if(caseRecordType == CaseDecorator.RECORD_TYPE_COMPLAINTS 
                   || caseRecord.casetype__c == CaseDecorator.TYPE_COMPLIMENT
                   || caseRecord.casetype__c == CaseDecorator.TYPE_SUGGESTION
				   || (caseRecordType == CaseDecorator.RECORD_TYPE_BREACH
                        && caseRecord.Origin == CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL)  ){
                        fieldsListByCaseId.get(caseRecord.Id).add(CaseDecorator.FIELD_CONTACT);
                   }
            }
        }
        
        if(!caseIdCaseMap.isEmpty()){
            Map<Id, String> caseErrorById = new CaseRoleSetupService(caseIdCaseMap,fieldsListByCaseId).setupCaseRoles();
            for(Id caseId : caseErrorById.keySet()){
                newMap.get(caseId).addError(caseErrorById.get(caseId));
            }
        }
    }
    
    public void afterInsert(List<Case> newList){
        Map<Id, Case> newMap = new Map<Id, Case>(newList);
        Map<Id,Case> caseIdCaseMap  = new Map<Id,Case>();

        for(Case caseRecord : newList){
            String caseRecordType = RecordTypeUtility.getRecordTypeDeveloperNameById(CaseDecorator.SOBJECT_TYPE_CASE, caseRecord.RecordTypeId);
            Boolean isNewMCCFlowVersion = new FeatureFlags(caseRecord).isNewMCCFlowVersion();
            Boolean isCreateByScheduledFlow = new FeatureFlags(caseRecord).isCreatedviascheduledFlow();
            if(isNewMCCFlowVersion || isCreateByScheduledFlow 
                || caseRecord.Origin == CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL 
                || caseRecord.Origin == CaseDecorator.CASE_ORIGIN_GUEST_PORTAL){
                caseIdCaseMap.put(caseRecord.Id, caseRecord);
            }
        }
        
        if(!caseIdCaseMap.isEmpty()){
            Map<Id, String> caseErrorById = new CaseRoleSetupService(caseIdCaseMap).setupCaseRoles();
            for(Id caseId : caseErrorById.keySet()){
                newMap.get(caseId).addError(caseErrorById.get(caseId));
            }
        }
    }
}