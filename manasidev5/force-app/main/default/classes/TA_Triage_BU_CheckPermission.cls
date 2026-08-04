public with sharing class TA_Triage_BU_CheckPermission implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<Triage__c> newList, List<Triage__c> oldList){
        ValidateProcessObjectPermissions.validate(newList, Triage__c.SobjectType);
    }  
}