trigger PortalRecordSharingEvent on PortalRecordSharingEvent__e (
    after insert
) {
    new MetadataTriggerHandler().run();
}