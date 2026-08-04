public without sharing class TA_Case_BIUD_AIUDUD_DLRS_RollUpLogic implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate, TriggerAction.BeforeDelete, TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.AfterDelete, TriggerAction.afterUnDelete{

    public void beforeInsert(List<Case> newList){
        invokeDlrsTriggerLogic();
    }

    public void beforeUpdate(List<Case> newList, List<Case> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void beforeDelete(List<Case> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterInsert(List<Case> newList){
        invokeDlrsTriggerLogic();
    }

    public void afterUpdate(List<Case> newList, List<Case> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterDelete(List<Case> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterUnDelete(List<Case> newList){
        invokeDlrsTriggerLogic();
    } 

    private void invokeDlrsTriggerLogic(){
        dlrs.RollupService.triggerHandler(Case.SObjectType);
    }
}