trigger ContactTrigger on Contact (
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