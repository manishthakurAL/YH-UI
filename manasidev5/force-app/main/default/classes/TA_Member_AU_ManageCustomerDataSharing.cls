public with sharing class TA_Member_AU_ManageCustomerDataSharing implements TriggerAction.AfterUpdate{
    List<Id> activeMemberIds = new List<Id>();
    List<Id> deactivatedMemberIds = new List<Id>();

    public void afterUpdate(List<Member__c> newList, List<Member__c> oldList){
        Map<Id, Member__c> oldMap = new Map<Id, Member__c>(oldList);
        for(Member__c memberRecord : newList){
            if(memberRecord.IsActiveValue__c == TRUE && memberRecord.IsActiveValue__c != oldMap.get(memberRecord.Id).IsActiveValue__c){
                activeMemberIds.add(memberRecord.Id);
            }

            if(memberRecord.IsActiveValue__c == FALSE && memberRecord.IsActiveValue__c != oldMap.get(memberRecord.Id).IsActiveValue__c){
                deactivatedMemberIds.add(memberRecord.Id);
            }
        }

        if(!activeMemberIds.isEmpty()){
            new ManageCustomerDataSharingService(
                activeMemberIds, 
                ManageCustomerDataSharingService.CHANGE_TYPE.RECORD_ACTVIATED,
                ManageCustomerDataSharingService.TRIGGER_CONTEXT.UPDATE_RECORD).shareRecords();
        }

        if(!deactivatedMemberIds.isEmpty()){
            new ManageCustomerDataSharingService(
                deactivatedMemberIds, 
                ManageCustomerDataSharingService.CHANGE_TYPE.RECORD_DEACTIVATED,
                ManageCustomerDataSharingService.TRIGGER_CONTEXT.UPDATE_RECORD).shareRecords();
        }
    }
}