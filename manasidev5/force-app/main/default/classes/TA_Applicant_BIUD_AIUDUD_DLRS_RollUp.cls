public without sharing class TA_Applicant_BIUD_AIUDUD_DLRS_RollUp implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate, TriggerAction.BeforeDelete, TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.AfterDelete, TriggerAction.afterUnDelete{

    public void beforeInsert(List<Applicant__c> newList){
        invokeDlrsTriggerLogic();
    }

    public void beforeUpdate(List<Applicant__c> newList, List<Applicant__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void beforeDelete(List<Applicant__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterInsert(List<Applicant__c> newList){
        invokeDlrsTriggerLogic();
    }

    public void afterUpdate(List<Applicant__c> newList, List<Applicant__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterDelete(List<Applicant__c> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterUnDelete(List<Applicant__c> newList){
        invokeDlrsTriggerLogic();
    } 

    private void invokeDlrsTriggerLogic(){
        dlrs.RollupService.triggerHandler(Applicant__c.SObjectType);
    }
}