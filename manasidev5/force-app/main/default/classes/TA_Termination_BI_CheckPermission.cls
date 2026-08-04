public with sharing class TA_Termination_BI_CheckPermission implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<Termination__c> newList){
        ValidateProcessObjectPermissions.validate(newList, Termination__c.SobjectType);
    }
}