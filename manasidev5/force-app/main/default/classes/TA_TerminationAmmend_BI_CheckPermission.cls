public with sharing class TA_TerminationAmmend_BI_CheckPermission implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<TerminationAmendment__c> newList){
        ValidateProcessObjectPermissions.validate(newList, TerminationAmendment__c.SobjectType);
    }
}