trigger PropertyTrigger on YH_Property__c (after insert, after update) {
    new MetadataTriggerHandler().run();
}