trigger IndependenceFormTrigger on IndependenceForm__c (before insert, before update) {
    new MetadataTriggerHandler().run();
}