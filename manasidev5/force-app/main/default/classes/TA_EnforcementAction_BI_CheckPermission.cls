public with sharing class TA_EnforcementAction_BI_CheckPermission implements TriggerAction.BeforeInsert {
public void beforeInsert(List<EnforcementAction__c> newList){
        ValidateProcessObjectPermissions.validate(newList, EnforcementAction__c.SobjectType);
    } 
}