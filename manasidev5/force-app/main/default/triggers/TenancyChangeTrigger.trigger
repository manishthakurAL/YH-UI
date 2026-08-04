trigger TenancyChangeTrigger on TenancyChange__c (after update, before insert, before update) {
    new MetadataTriggerHandler().run();
}