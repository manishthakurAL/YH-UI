public with sharing class TA_Termination_BU_CheckPermission implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<Termination__c> newList, List<Termination__c> oldList){
        ValidateProcessObjectPermissions.validate(newList, Termination__c.SobjectType);
    }
}