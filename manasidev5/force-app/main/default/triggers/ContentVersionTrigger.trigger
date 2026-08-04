trigger ContentVersionTrigger on ContentVersion (before insert, before update) {
    new MetadataTriggerHandler().run();
}