public with sharing class TA_TenancyIncident_BI_CheckPermission implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<TenancyIncident__c> newList){
        ValidateProcessObjectPermissions.validate(newList, TenancyIncident__c.SobjectType);
    }
}