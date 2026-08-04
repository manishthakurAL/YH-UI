trigger MemberTrigger on Member__c (
    before delete,
    before insert,
    before update,
    after delete,
    after insert,
    after undelete,
    after update
) {
    new MetadataTriggerHandler().run();
}