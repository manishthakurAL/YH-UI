trigger TerminationAmendmentTrigger on TerminationAmendment__c (before insert, before update) {
    new MetadataTriggerHandler().run();
}