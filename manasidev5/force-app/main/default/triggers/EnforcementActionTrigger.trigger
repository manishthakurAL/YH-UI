trigger EnforcementActionTrigger on EnforcementAction__c (before insert, before update) {
    new MetadataTriggerHandler().run();
}