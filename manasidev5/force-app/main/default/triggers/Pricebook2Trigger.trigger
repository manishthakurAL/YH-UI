trigger Pricebook2Trigger on Pricebook2 (
    before insert,
    before update
) {
    new MetadataTriggerHandler().run();
}