trigger TriageTrigger on Triage__c (
    before insert,
    before update) {
    new MetadataTriggerHandler().run();
}