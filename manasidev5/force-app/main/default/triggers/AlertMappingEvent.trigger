trigger AlertMappingEvent on AlertMappingEvent__e (
    after insert
) {
    new MetadataTriggerHandler().run();
}