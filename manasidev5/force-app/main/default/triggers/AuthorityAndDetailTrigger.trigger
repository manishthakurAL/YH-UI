trigger AuthorityAndDetailTrigger on AuthorityAndDetail__c (
    after update, before insert, before update
) {
    new MetadataTriggerHandler().run();
}