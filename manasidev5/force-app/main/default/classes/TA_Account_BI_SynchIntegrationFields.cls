public with sharing class TA_Account_BI_SynchIntegrationFields implements TriggerAction.BeforeInsert{
    
    public void beforeInsert(List<Account> newList){        
        SObjectRecordChangeDetectorManager sobjectRecordChangeDetectorInstance = new SObjectRecordChangeDetectorManager(newList, null);
        sobjectRecordChangeDetectorInstance.setCreatedInSystem();
    }
}