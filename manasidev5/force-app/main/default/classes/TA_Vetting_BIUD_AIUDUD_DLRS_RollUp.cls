public without sharing class TA_Vetting_BIUD_AIUDUD_DLRS_RollUp implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate, TriggerAction.BeforeDelete, TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.AfterDelete, TriggerAction.afterUnDelete{

    public void beforeInsert(List<Vetting__c> newList){
        invokeDlrsTriggerLogic();
    }

    public void beforeUpdate(List<Vetting__c> newList, List<Vetting__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void beforeDelete(List<Vetting__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterInsert(List<Vetting__c> newList){
        invokeDlrsTriggerLogic();
    }

    public void afterUpdate(List<Vetting__c> newList, List<Vetting__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterDelete(List<Vetting__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterUnDelete(List<Vetting__c> newList){
        invokeDlrsTriggerLogic();
    } 

    private void invokeDlrsTriggerLogic(){
        dlrs.RollupService.triggerHandler(Vetting__c.SObjectType);
    }
}