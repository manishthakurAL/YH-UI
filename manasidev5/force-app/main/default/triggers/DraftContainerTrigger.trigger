trigger DraftContainerTrigger on DraftContainer__c (before update, after update) {
     new MetadataTriggerHandler().run();
}