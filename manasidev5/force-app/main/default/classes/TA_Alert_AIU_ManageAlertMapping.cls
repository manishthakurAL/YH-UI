public with sharing class TA_Alert_AIU_ManageAlertMapping implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate{

    public void afterInsert(List<Alert__c> newList){
        List<Id> activeAlertIdList = new List<Id>();
        for(Alert__c alertRec : newList){
            if(alertRec.IsActiveValue__c){
                activeAlertIdList.add(alertRec.Id);
            }
        }
        
        if(!activeAlertIdList.isEmpty()){
            new ManageAlertMappingService(
                activeAlertIdList, 
                ManageAlertMappingService.CHANGE_TYPE.RECORD_ACTVIATED,
                ManageAlertMappingService.TRIGGER_CONTEXT.INSERT_RECORD).createAlertMappingRecords();
        }
    }

    public void afterUpdate(List<Alert__c> newList, List<Alert__c> oldList){
        Map<Id, Alert__c> oldMap = new Map<Id, Alert__c>(oldList);
        List<Id> activeAlertIdList = new List<Id>();
        for(Alert__c alertRec : newList){
            if(alertRec.IsActiveValue__c && alertRec.IsActiveValue__c != oldMap.get(alertRec.Id).IsActiveValue__c){
                activeAlertIdList.add(alertRec.Id);
            }
        }
        
        if(!activeAlertIdList.isEmpty()){
            new ManageAlertMappingService(
                activeAlertIdList, 
                ManageAlertMappingService.CHANGE_TYPE.RECORD_ACTVIATED,
                ManageAlertMappingService.TRIGGER_CONTEXT.UPDATE_RECORD).createAlertMappingRecords();
        }
    }
}