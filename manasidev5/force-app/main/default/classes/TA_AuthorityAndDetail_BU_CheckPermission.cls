public with sharing class TA_AuthorityAndDetail_BU_CheckPermission implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<AuthorityAndDetail__c> newList, List<AuthorityAndDetail__c> oldList){
        ValidateProcessObjectPermissions.validate(newList, AuthorityAndDetail__c.SobjectType);
    }
}