public with sharing class TA_WOLI_BU_SynchIntegrationFields implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<WorkOrderLineItem> newList, List<WorkOrderLineItem> oldList){
        SObjectRecordChangeDetectorManager sobjectRecordChangeDetectorInstance = new SObjectRecordChangeDetectorManager(newList, new Map<Id, WorkOrderLineItem>(oldList));
        sobjectRecordChangeDetectorInstance.identifySynchChanges();
        sobjectRecordChangeDetectorInstance.synchIntegrationStatus();
        sobjectRecordChangeDetectorInstance.clearLastSynchDirection();
    }
}