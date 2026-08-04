public without sharing class TA_Contact_BIUD_AIUDUD_DLRS_RollUpLogic implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate, TriggerAction.BeforeDelete, TriggerAction.AfterInsert, TriggerAction.AfterUpdate, TriggerAction.AfterDelete, TriggerAction.afterUnDelete{

    public void beforeInsert(List<Contact> newList){
        invokeDlrsTriggerLogic();
    }

    public void beforeUpdate(List<Contact> newList, List<Contact> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void beforeDelete(List<Contact> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterInsert(List<Contact> newList){
        invokeDlrsTriggerLogic();
    }

    public void afterUpdate(List<Contact> newList, List<Contact> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterDelete(List<Contact> oldList){
        invokeDlrsTriggerLogic();
    } 

    public void afterUnDelete(List<Contact> newList){
        invokeDlrsTriggerLogic();
    } 

    private void invokeDlrsTriggerLogic(){
        dlrs.RollupService.triggerHandler(Contact.SObjectType);
    }
}