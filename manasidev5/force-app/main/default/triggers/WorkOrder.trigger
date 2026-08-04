trigger WorkOrder on WorkOrder (
    before insert,
    before update
) {
    new MetadataTriggerHandler().run();
}