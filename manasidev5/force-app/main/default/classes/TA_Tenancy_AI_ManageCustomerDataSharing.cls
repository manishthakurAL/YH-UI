public with sharing class TA_Tenancy_AI_ManageCustomerDataSharing implements TriggerAction.AfterInsert{
    List<Id> activeTenancyIds = new List<Id>();

    public void afterInsert(List<YH_Tenancy__c> newList){
        for(YH_Tenancy__c tenancyRecord : newList){
            if(tenancyRecord.Active__c == TRUE){
                activeTenancyIds.add(tenancyRecord.Id);
            }
        }

        if(!activeTenancyIds.isEmpty()){
            new ManageCustomerDataSharingService(
                activeTenancyIds, 
                ManageCustomerDataSharingService.CHANGE_TYPE.RECORD_ACTVIATED,
                ManageCustomerDataSharingService.TRIGGER_CONTEXT.INSERT_RECORD).shareRecords();
        }
    }
}