public with sharing class TA_TenancyChange_BI_CheckPermission  implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<TenancyChange__c> newList){
        ValidateProcessObjectPermissions.validate(newList, TenancyChange__c.SobjectType);
    }
}