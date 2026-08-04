trigger ContentDocumentTrigger on ContentDocument (before delete, after insert) {
    new MetadataTriggerHandler().run();
}