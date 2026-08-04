trigger TaskTrigger on Task (
    after insert,
    before update
) {
    new MetadataTriggerHandler().run();
}