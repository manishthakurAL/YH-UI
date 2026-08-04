public with sharing class TA_IndependenceForm_BI_CheckPermission implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<IndependenceForm__c> newList){
        ValidateProcessObjectPermissions.validate(newList, IndependenceForm__c.SobjectType);
    }
}