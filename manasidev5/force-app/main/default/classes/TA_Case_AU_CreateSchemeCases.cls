public with sharing class TA_Case_AU_CreateSchemeCases implements TriggerAction.AfterUpdate{
    public void afterUpdate(List<Case> newList, List<Case> oldList){
        Map<Id, Case> casesMap = new Map<Id, Case>(oldList);
        Set<Id> caseIds = new Set<Id>();
        for (Case caseRecord : newList) {
            if (caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_LETTINGS 
                && caseRecord.Status == CaseDecorator.STATUS_COMPLETE_CASE
                && caseRecord.CaseOutcome__c == CaseDecorator.CASE_OUTCOME_RESOLVED 
                && caseRecord.Status != casesMap.get(caseRecord.Id).Status
                && caseRecord.Tenancy__c != null) {
                caseIds.add(caseRecord.Id);
            }
        }
        
        if (!caseIds.isEmpty()) {
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Case_BI_SystemOriginValidation.class.getName());
            MetadataTriggerHandler.bypass(TA_IndependenceForm_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_IndependenceForm_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_MonitoringForm_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_MonitoringForm_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_InspectionCheck_BU_CheckPermission.class.getName());

            CaseSchemesService.processCaseForSchemes(caseIds);

            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_IndependenceForm_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_IndependenceForm_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_MonitoringForm_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_MonitoringForm_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Case_BI_SystemOriginValidation.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BU_CheckPermission.class.getName());
        }
    }
}