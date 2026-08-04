trigger TerminationTrigger on Termination__c (before insert, before update) {
    new MetadataTriggerHandler().run();
}