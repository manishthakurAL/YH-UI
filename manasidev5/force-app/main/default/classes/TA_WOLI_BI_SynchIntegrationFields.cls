public with sharing class TA_WOLI_BI_SynchIntegrationFields implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<WorkOrderLineItem> newList){
        SObjectRecordChangeDetectorManager sobjectRecordChangeDetectorInstance = new SObjectRecordChangeDetectorManager(newList, null);
        sobjectRecordChangeDetectorInstance.setCreatedInSystem();
        sobjectRecordChangeDetectorInstance.identifySynchChanges();
        sobjectRecordChangeDetectorInstance.clearLastSynchDirection();
    }
}