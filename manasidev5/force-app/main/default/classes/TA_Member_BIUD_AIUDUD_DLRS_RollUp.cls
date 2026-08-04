public without sharing class TA_Member_BIUD_AIUDUD_DLRS_RollUp implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate, TriggerAction.BeforeDelete, TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.AfterDelete, TriggerAction.afterUnDelete{

    public void beforeInsert(List<Member__c> newList){
        invokeDlrsTriggerLogic();
    }

    public void beforeUpdate(List<Member__c> newList, List<Member__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void beforeDelete(List<Member__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterInsert(List<Member__c> newList){
        invokeDlrsTriggerLogic();
    }

    public void afterUpdate(List<Member__c> newList, List<Member__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterDelete(List<Member__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterUnDelete(List<Member__c> newList){
        invokeDlrsTriggerLogic();
    } 

    private void invokeDlrsTriggerLogic(){
        dlrs.RollupService.triggerHandler(Member__c.SObjectType);
    }
}