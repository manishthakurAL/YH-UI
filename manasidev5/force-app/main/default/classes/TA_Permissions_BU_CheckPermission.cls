public with sharing class TA_Permissions_BU_CheckPermission implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<Permissions__c> newList, List<Permissions__c> oldList){
        ValidateProcessObjectPermissions.validate(newList, Permissions__c.SobjectType);
    }
}