public with sharing class TA_Permissions_BI_CheckPermission implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<Permissions__c> newList){
        ValidateProcessObjectPermissions.validate(newList, Permissions__c.SobjectType);
    }
}