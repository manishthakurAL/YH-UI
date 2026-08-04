trigger WorkStepTrigger on WorkStep (
    after update
    
) {
    new MetadataTriggerHandler().run();
}