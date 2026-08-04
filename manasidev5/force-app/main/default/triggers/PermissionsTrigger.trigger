trigger PermissionsTrigger on Permissions__c (before insert,
before update) {
    new MetadataTriggerHandler().run();
}