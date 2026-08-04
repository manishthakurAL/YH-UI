public with sharing class TA_Case_AI_ManageCustomerDataSharing implements TriggerAction.AfterInsert{
    List<Id> recordSharingCaseIds = new List<Id>();

    public void afterInsert(List<Case> newList){
        for(Case caseRecord : newList){
            if(caseRecord.CustomerSharingReasons__c != null){
                recordSharingCaseIds.add(caseRecord.Id);
            }
        }

        if(!recordSharingCaseIds.isEmpty()){
            new ManageCustomerDataSharingService(
                recordSharingCaseIds, 
                ManageCustomerDataSharingService.CHANGE_TYPE.RECORD_RECALCULATE_SHARING,
                ManageCustomerDataSharingService.TRIGGER_CONTEXT.INSERT_RECORD).shareRecords();
        }
    }
}