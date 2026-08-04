trigger MonitoringFormTrigger on Monitoring_Form__c
(before insert,
before update) {
    new MetadataTriggerHandler().run();
}