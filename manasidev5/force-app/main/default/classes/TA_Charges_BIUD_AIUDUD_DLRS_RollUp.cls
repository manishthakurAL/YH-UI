public without sharing class TA_Charges_BIUD_AIUDUD_DLRS_RollUp implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate, TriggerAction.BeforeDelete, TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.AfterDelete, TriggerAction.afterUnDelete{

    public void beforeInsert(List<Charges__c> newList){
        invokeDlrsTriggerLogic();
    }

    public void beforeUpdate(List<Charges__c> newList, List<Charges__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void beforeDelete(List<Charges__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterInsert(List<Charges__c> newList){
        invokeDlrsTriggerLogic();
    }

    public void afterUpdate(List<Charges__c> newList, List<Charges__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterDelete(List<Charges__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterUnDelete(List<Charges__c> newList){
        invokeDlrsTriggerLogic();
    } 

    private void invokeDlrsTriggerLogic(){
        dlrs.RollupService.triggerHandler(Charges__c.SObjectType);
    }
}