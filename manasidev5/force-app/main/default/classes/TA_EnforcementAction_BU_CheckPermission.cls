public with sharing class TA_EnforcementAction_BU_CheckPermission implements TriggerAction.BeforeUpdate {
public void beforeUpdate(List<EnforcementAction__c> newList, List<EnforcementAction__c> oldList){
        ValidateProcessObjectPermissions.validate(newList, EnforcementAction__c.SobjectType);
    }  
}