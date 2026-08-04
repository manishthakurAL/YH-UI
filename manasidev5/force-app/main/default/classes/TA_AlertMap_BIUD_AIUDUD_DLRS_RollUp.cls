public without sharing class TA_AlertMap_BIUD_AIUDUD_DLRS_RollUp implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate, TriggerAction.BeforeDelete, TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.AfterDelete, TriggerAction.afterUnDelete{

    public void beforeInsert(List<AlertMap__c> newList){
        invokeDlrsTriggerLogic();
    }

    public void beforeUpdate(List<AlertMap__c> newList, List<AlertMap__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void beforeDelete(List<AlertMap__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterInsert(List<AlertMap__c> newList){
        invokeDlrsTriggerLogic();
    }

    public void afterUpdate(List<AlertMap__c> newList, List<AlertMap__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterDelete(List<AlertMap__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterUnDelete(List<AlertMap__c> newList){
        invokeDlrsTriggerLogic();
    } 

    private void invokeDlrsTriggerLogic(){
        dlrs.RollupService.triggerHandler(AlertMap__c.SObjectType);
    }
}