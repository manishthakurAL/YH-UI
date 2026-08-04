public with sharing class TA_Property_AIU_ManageAlert implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate {
    
    public void afterInsert(List<YH_Property__c> newList){
        ManageAlertBasedOnSobjectFactory.getInstance(newList.getSObjectType())?.setUpAlerts(newList, null);
    }

    public void afterUpdate(List<YH_Property__c> newList, List<YH_Property__c> oldList){
        ManageAlertBasedOnSobjectFactory.getInstance(newList.getSObjectType())?.setUpAlerts(newList, oldList);
    }
}