trigger AccountTrigger on Account (
    before insert,
    after insert,
    after update,
    before update
) {
    new MetadataTriggerHandler().run();
}