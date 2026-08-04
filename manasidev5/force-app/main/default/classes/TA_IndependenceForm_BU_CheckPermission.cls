public with sharing class TA_IndependenceForm_BU_CheckPermission implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<IndependenceForm__c> newList, List<IndependenceForm__c> oldList){
        ValidateProcessObjectPermissions.validate(newList, IndependenceForm__c.SobjectType);
    }
}