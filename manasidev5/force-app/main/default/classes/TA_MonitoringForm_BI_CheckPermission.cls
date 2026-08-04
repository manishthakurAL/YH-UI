public with sharing class TA_MonitoringForm_BI_CheckPermission implements TriggerAction.BeforeInsert{
    public void beforeInsert(List<Monitoring_Form__c> newList){
        ValidateProcessObjectPermissions.validate(newList, Monitoring_Form__c.SobjectType);
    }
}