public with sharing class TA_AuthorityAndDetail_BI_CheckPermission implements TriggerAction.BeforeInsert  {
    public void beforeInsert(List<AuthorityAndDetail__c> newList){
        ValidateProcessObjectPermissions.validate(newList, AuthorityAndDetail__c.SobjectType);
    }
}