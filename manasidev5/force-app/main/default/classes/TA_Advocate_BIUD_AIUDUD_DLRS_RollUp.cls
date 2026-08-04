public without sharing class TA_Advocate_BIUD_AIUDUD_DLRS_RollUp implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate, TriggerAction.BeforeDelete, TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.AfterDelete, TriggerAction.afterUnDelete{

    public void beforeInsert(List<Advocate__c> newList){
        invokeDlrsTriggerLogic();
    }

    public void beforeUpdate(List<Advocate__c> newList, List<Advocate__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void beforeDelete(List<Advocate__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterInsert(List<Advocate__c> newList){
        invokeDlrsTriggerLogic();
    }

    public void afterUpdate(List<Advocate__c> newList, List<Advocate__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterDelete(List<Advocate__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterUnDelete(List<Advocate__c> newList){
        invokeDlrsTriggerLogic();
    } 

    private void invokeDlrsTriggerLogic(){
        dlrs.RollupService.triggerHandler(Advocate__c.SObjectType);
    }
}