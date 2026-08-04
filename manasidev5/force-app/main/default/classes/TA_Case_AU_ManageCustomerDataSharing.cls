public with sharing class TA_Case_AU_ManageCustomerDataSharing implements TriggerAction.AfterUpdate{
    List<Id> recordSharingCaseIds = new List<Id>();
    List<Id> ownershipChangedCaseIds = new List<Id>();
    List<Id> removeSharingCaseIds = new List<Id>();
    public static Boolean executeCustomerDataSharing = false;

    public void afterUpdate(List<Case> newList, List<Case> oldList) {
        Map<Id, Case> oldMap = new Map<Id, Case>(oldList);
        for(Case caseRecord : newList){
            String caseRecordType = RecordTypeUtility.getRecordTypeDeveloperNameById(CaseDecorator.SOBJECT_TYPE_CASE, caseRecord.RecordTypeId);

            if(caseRecord.CustomerSharingReasons__c != null){
                // Case sharing reason or contact changed on case
                if(caseRecord.CustomerSharingReasons__c != oldMap.get(caseRecord.Id).CustomerSharingReasons__c || caseRecord.ContactID != oldMap.get(caseRecord.Id).ContactID){
                    recordSharingCaseIds.add(caseRecord.Id);
                }else if(executeCustomerDataSharing || caseRecord.OwnerId != oldMap.get(caseRecord.Id).OwnerId){
                    ownershipChangedCaseIds.add(caseRecord.Id);
                }
            } else if(caseRecord.CustomerSharingReasons__c == null){
                if(caseRecord.CustomerSharingReasons__c != oldMap.get(caseRecord.Id).CustomerSharingReasons__c){
                    removeSharingCaseIds.add(caseRecord.Id);
                }
            }
        }

        if(!recordSharingCaseIds.isEmpty()){
            new ManageCustomerDataSharingService(
                recordSharingCaseIds, 
                ManageCustomerDataSharingService.CHANGE_TYPE.RECORD_RECALCULATE_SHARING,
                ManageCustomerDataSharingService.TRIGGER_CONTEXT.UPDATE_RECORD).shareRecords();
        }

        if(!ownershipChangedCaseIds.isEmpty()){
            new ManageCustomerDataSharingService(
                ownershipChangedCaseIds, 
                ManageCustomerDataSharingService.CHANGE_TYPE.RECORD_OWNERSHIP_CHANGED,
                ManageCustomerDataSharingService.TRIGGER_CONTEXT.UPDATE_RECORD).shareRecords();
        }

        if(!removeSharingCaseIds.isEmpty()){
            new ManageCustomerDataSharingService(
                removeSharingCaseIds, 
                ManageCustomerDataSharingService.CHANGE_TYPE.RECORD_REMOVE_SHARING,
                ManageCustomerDataSharingService.TRIGGER_CONTEXT.UPDATE_RECORD).shareRecords();
        }
    }
}