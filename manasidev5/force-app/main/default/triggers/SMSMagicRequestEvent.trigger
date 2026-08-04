trigger SMSMagicRequestEvent on SMSMagicRequestEvent__e (after insert) {

        new MetadataTriggerHandler().run();
        
}