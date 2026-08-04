public with sharing class TA_TenancyChange_BU_CheckPermission implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<TenancyChange__c> newList, List<TenancyChange__c> oldList){
        ValidateProcessObjectPermissions.validate(newList, TenancyChange__c.SobjectType);
    }
}