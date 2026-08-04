public without sharing class TA_Alert_BIUD_AIUDUD_DLRS_RollUp implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate, TriggerAction.BeforeDelete, TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.AfterDelete, TriggerAction.afterUnDelete{

    public void beforeInsert(List<Alert__c> newList){
        invokeDlrsTriggerLogic();
    }

    public void beforeUpdate(List<Alert__c> newList, List<Alert__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void beforeDelete(List<Alert__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterInsert(List<Alert__c> newList){
        invokeDlrsTriggerLogic();
    }

    public void afterUpdate(List<Alert__c> newList, List<Alert__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterDelete(List<Alert__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterUnDelete(List<Alert__c> newList){
        invokeDlrsTriggerLogic();
    } 

    private void invokeDlrsTriggerLogic(){
        dlrs.RollupService.triggerHandler(Alert__c.SObjectType);
    }
}