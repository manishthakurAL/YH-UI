public with sharing class TA_SocialValue_BU_CheckPermission implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<SocialValue__c> newList, List<SocialValue__c> oldList){
        ValidateProcessObjectPermissions.validate(newList, SocialValue__c.SobjectType);
    }
}