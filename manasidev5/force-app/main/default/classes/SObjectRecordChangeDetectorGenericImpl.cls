public with sharing class SObjectRecordChangeDetectorGenericImpl extends SObjectRecordChangeDetector {
    public override void setCreatedInSystemOnInsert(Sobject newRecord){
        this.setCreatedInSystem(newRecord);
    }

    public override void identifyChanges(Sobject newRecord, Sobject oldRecord){
        this.identifyFieldChanges(newRecord, oldRecord);
    }

    public override void syncIntegrationStatus(Sobject newRecord, Sobject oldRecord){
        this.syncIntegrationStatusOnUpdate(newRecord, oldRecord);
    }

    public override void clearLastSynchDirectionOnRecord(Sobject newRecord){
        this.clearLastSynchDirection(newRecord);
    }
}