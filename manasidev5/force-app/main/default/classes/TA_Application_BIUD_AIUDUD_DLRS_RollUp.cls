public without sharing class TA_Application_BIUD_AIUDUD_DLRS_RollUp implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate, TriggerAction.BeforeDelete, TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.AfterDelete, TriggerAction.afterUnDelete{

    public void beforeInsert(List<YH_Application__c> newList){
        invokeDlrsTriggerLogic();
    }

    public void beforeUpdate(List<YH_Application__c> newList, List<YH_Application__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void beforeDelete(List<YH_Application__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterInsert(List<YH_Application__c> newList){
        invokeDlrsTriggerLogic();
    }

    public void afterUpdate(List<YH_Application__c> newList, List<YH_Application__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterDelete(List<YH_Application__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterUnDelete(List<YH_Application__c> newList){
        invokeDlrsTriggerLogic();
    } 

    private void invokeDlrsTriggerLogic(){
        dlrs.RollupService.triggerHandler(YH_Application__c.SObjectType);
    }
}