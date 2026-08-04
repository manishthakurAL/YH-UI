public with sharing class TA_Tenancy_AU_ManageCustomerDataSharing implements TriggerAction.AfterUpdate{
    List<Id> activeTenancyIds = new List<Id>();
    List<Id> deactivatedTenancyIds = new List<Id>();

    public void afterUpdate(List<YH_Tenancy__c> newList, List<YH_Tenancy__c> oldList) {
        Map<Id, YH_Tenancy__c> oldMap = new Map<Id, YH_Tenancy__c>(oldList);
        for(YH_Tenancy__c tenancyRecord : newList){
            if(tenancyRecord.Active__c == TRUE && tenancyRecord.Active__c != oldMap.get(tenancyRecord.Id).Active__c){
                activeTenancyIds.add(tenancyRecord.Id);
            } 

            if(tenancyRecord.Active__c == FALSE && tenancyRecord.Active__c != oldMap.get(tenancyRecord.Id).Active__c){
                deactivatedTenancyIds.add(tenancyRecord.Id);
            }
        }

        if(!activeTenancyIds.isEmpty()){
            new ManageCustomerDataSharingService(
                activeTenancyIds, 
                ManageCustomerDataSharingService.CHANGE_TYPE.RECORD_ACTVIATED,
                ManageCustomerDataSharingService.TRIGGER_CONTEXT.UPDATE_RECORD).shareRecords();
        }

        if(!deactivatedTenancyIds.isEmpty()){
            new ManageCustomerDataSharingService(
                deactivatedTenancyIds, 
                ManageCustomerDataSharingService.CHANGE_TYPE.RECORD_DEACTIVATED,
                ManageCustomerDataSharingService.TRIGGER_CONTEXT.UPDATE_RECORD).shareRecords();
        }
    }
}