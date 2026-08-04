public with sharing class TA_WorkOrder_BI_SynchIntegrationFields implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<WorkOrder> newList){
        SObjectRecordChangeDetectorManager sobjectRecordChangeDetectorInstance = new SObjectRecordChangeDetectorManager(newList, null);
        sobjectRecordChangeDetectorInstance.setCreatedInSystem();
        sobjectRecordChangeDetectorInstance.identifySynchChanges();
        sobjectRecordChangeDetectorInstance.clearLastSynchDirection();
    }
}