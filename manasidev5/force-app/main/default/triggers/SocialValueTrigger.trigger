trigger SocialValueTrigger on SocialValue__c (before insert, before update) {
    new MetadataTriggerHandler().run();
}