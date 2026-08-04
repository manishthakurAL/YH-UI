public with sharing class TA_SocialValue_BI_CheckPermission implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<SocialValue__c> newList){
        ValidateProcessObjectPermissions.validate(newList, SocialValue__c.SobjectType);
    }
}