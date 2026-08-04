trigger AccountTrigger on Account (
    after insert,
    after update,
    before update
) {
    new MetadataTriggerHandler().run();
}