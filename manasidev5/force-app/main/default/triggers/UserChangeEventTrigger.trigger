trigger UserChangeEventTrigger on UserChangeEvent (after insert) {
    new MetadataTriggerHandler().run();
}