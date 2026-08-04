trigger ApplicationTrigger on YH_Application__c (after update) {
    new MetadataTriggerHandler().run();
}