public with sharing class TA_TerminationAmmend_BU_CheckPermission implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<TerminationAmendment__c> newList, List<TerminationAmendment__c> oldList){
        ValidateProcessObjectPermissions.validate(newList, TerminationAmendment__c.SobjectType);
    }
}