public with sharing class TA_Triage_BI_CheckPermission implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<Triage__c> newList){
        ValidateProcessObjectPermissions.validate(newList, Triage__c.SobjectType);
    }
}