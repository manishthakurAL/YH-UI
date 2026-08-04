public without sharing class CaseAssignmentTriggerService {
    
    private static final Set<String> STAGES_TO_RUN_ASSIGNMENT_RULES_FOR = new Set<String>{
        CaseDecorator.STATUS_STAGE_ONE,
        CaseDecorator.STATUS_STAGE_TWO
    };

    @testVisible
    private static Boolean bypassAutomation;

    public static void triggerCaseAssignmentRules(List<Case> casesList, Map<Id, Case> casesMap) {
        Set<Id> caseIds = new Set<Id>();
        bypassAutomation = false;
        for (Case caseRecord : casesList) {
            if (caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_COMPLAINTS) {		
                if ((casesMap == null || (casesMap != null && caseRecord.Status != casesMap.get(caseRecord.Id).Status))
                    && STAGES_TO_RUN_ASSIGNMENT_RULES_FOR.contains(caseRecord.Status)) {
                    caseIds.add(caseRecord.Id);
                }
                // BY PASS AUTOMATION WHEN A CASE IS CREATED
                // NO NEED TO TRIGGER ANY AUTOMATION WHEN A CASE IS ESCALATED TO STATE ONE DURING CREATION
                if (casesMap == null) {
                    bypassAutomation = true;
                }
            } else if (caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_CUSTOMER &&
                            (casesMap != null && caseRecord.Status != casesMap.get(caseRecord.Id).Status) &&
                            caseRecord.Status == CaseDecorator.STATUS_AWAITING_DOCUMENTATION) {	
                caseIds.add(caseRecord.Id);	
            }
        }
        if (!caseIds.isEmpty()) {
            triggerCaseAssingmentRules(caseIds, false);
        }
    }

    public static void triggerCaseAssingmentRules(Set<Id> caseIds, Boolean sendEmailOnAssignment) {
        List<Case> casesToUpdate = new List<Case>();
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.EmailHeader.TriggerUserEmail = sendEmailOnAssignment; 
        dmlOption.assignmentRuleHeader.useDefaultRule = true;
        for (Id caseId : caseIds) {
            Case caseRecord = new Case(Id = caseId);
            caseRecord.setOptions(dmlOption);
            casesToUpdate.add(caseRecord);
        }
        // TO BY PASS USER PERMISSION VALIDATION CHECK
        // NON_ADMIN SHOULD CHANGE STATUS TO STAGE ONE
        TriggerBase.bypass('Case');
        update casesToUpdate;
        if(!caseIds.isEmpty()){
            List<Case> caseList = getCases(caseIds);
            TA_Case_AU_ManageCustomerDataSharing manageCustomerDataSharing = new TA_Case_AU_ManageCustomerDataSharing();
            TA_Case_AU_ManageCustomerDataSharing.executeCustomerDataSharing = true;
            manageCustomerDataSharing.afterUpdate(caseList, caseList);
        }
        TriggerBase.clearBypass('Case');
        
        if (bypassAutomation) {
            MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        }
    }

    private static List<Case> getCases(Set<Id> caseIds){
        return [Select Id, ContactId, RecordTypeId, CustomerSharingReasons__c, OwnerId 
            FROM Case
            WHERE Id IN: caseIds];
    }
}