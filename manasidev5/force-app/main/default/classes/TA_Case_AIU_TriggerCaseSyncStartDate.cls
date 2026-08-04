public with sharing class TA_Case_AIU_TriggerCaseSyncStartDate implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate{
    
    public void afterInsert(List<Case> newList){
        this.checkStartDateAndFireEvent(newList, null);
    }

    public void afterUpdate(List<Case> newList, List<Case> oldList){
        this.checkStartDateAndFireEvent(newList, oldList);
    }

    public void checkStartDateAndFireEvent(List<Case> newList, List<Case> oldList){
        Map<Id, Case> newMap = new Map<Id, Case>(newList);
        Set<Id> caseIds = new Set<Id>();
        for(Case caseRecord : newList){
            if (    caseRecord.SLAStartDate__c != null && 
                    (caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_COMPLAINTS
                    || caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_MONEY_COACHING
                    || caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_TENANCY_COACHING
                    || caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_SAFEGUARDING
                    || caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_PERMISSION
                    || caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_CHANGES
                    || caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_PLACE
                    || caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_TENANCY
                    || caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_BREACH_ASB
                    || caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_EMAILRESPONSE
                    || caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_GENERAL_ENQUIRY
                    || caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_MANAGED_MOVE
                    || caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_CUSTOMER_FEEDBACK)
                ) {
                    caseIds.add(caseRecord.Id);

            }
        }
        
        if(!caseIds.isEmpty()){
            List<CaseMilestoneEvent__e> caseMSEvents = new List<CaseMilestoneEvent__e>();
            for(Id caseId : caseIds){
                caseMSEvents.add(new CaseMilestoneEvent__e(CaseId__c = caseId)
                );
            }
            List<Database.SaveResult> results = EventBus.publish(caseMSEvents);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' + err.getStatusCode());
                    }
                }
            }
        }
    }
}