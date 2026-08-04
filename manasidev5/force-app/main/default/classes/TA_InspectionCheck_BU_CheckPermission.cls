public with sharing class TA_InspectionCheck_BU_CheckPermission implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<YH_Inspection_Checklist__c> newList, List<YH_Inspection_Checklist__c> oldList){
        ValidateProcessObjectPermissions.validate(newList, YH_Inspection_Checklist__c.SobjectType);
    }
}