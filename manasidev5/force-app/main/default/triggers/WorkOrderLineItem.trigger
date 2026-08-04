trigger WorkOrderLineItem on WorkOrderLineItem (
    before insert,
    before update) {
    new MetadataTriggerHandler().run();
}