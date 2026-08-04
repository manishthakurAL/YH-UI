public with sharing class TA_TenancyIncident_BU_CheckPermission implements TriggerAction.BeforeUpdate{
    public void beforeUpdate(List<TenancyIncident__c> newList, List<TenancyIncident__c> oldList){
        ValidateProcessObjectPermissions.validate(newList, TenancyIncident__c.SobjectType);
    }
}