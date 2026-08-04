trigger TenancyIncidentTrigger on TenancyIncident__c (before insert,
before update, after update) {
    new MetadataTriggerHandler().run();
}