public with sharing class TA_Account_BU_SynchIntegrationFields implements TriggerAction.BeforeUpdate {

    public void beforeUpdate(List<Account> newList, List<Account> oldList){        
        SObjectRecordChangeDetectorManager sobjectRecordChangeDetectorInstance = new SObjectRecordChangeDetectorManager(newList, new Map<Id, Account>(oldList));
        sobjectRecordChangeDetectorInstance.identifySynchChanges();
        sobjectRecordChangeDetectorInstance.synchIntegrationStatus();
        sobjectRecordChangeDetectorInstance.clearLastSynchDirection();
    }
}