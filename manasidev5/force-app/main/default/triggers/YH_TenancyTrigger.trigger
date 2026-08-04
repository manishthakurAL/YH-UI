trigger YH_TenancyTrigger on YH_Tenancy__c (
    before insert,
    after insert,
    before update,
    after update
) {
    new MetadataTriggerHandler().run();
}