public with sharing class TA_MonitoringForm_BU_CheckPermission implements TriggerAction.BeforeUpdate{
    public void beforeUpdate(List<Monitoring_Form__c> newList, List<Monitoring_Form__c> oldList){
        ValidateProcessObjectPermissions.validate(newList, Monitoring_Form__c.SobjectType);
    }
}