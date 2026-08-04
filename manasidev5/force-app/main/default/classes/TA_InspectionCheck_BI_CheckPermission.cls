public with sharing class TA_InspectionCheck_BI_CheckPermission implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<YH_Inspection_Checklist__c> newList){
        ValidateProcessObjectPermissions.validate(newList, YH_Inspection_Checklist__c.SobjectType);
    }
}