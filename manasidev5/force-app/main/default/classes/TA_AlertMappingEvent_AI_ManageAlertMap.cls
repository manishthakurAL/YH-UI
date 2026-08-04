public with sharing class TA_AlertMappingEvent_AI_ManageAlertMap implements TriggerAction.AfterInsert{

    public void afterInsert(List<AlertMappingEvent__e> newList){
        for(AlertMappingEvent__e eventRec : newList){
            String objectName;
            List<Id> recordIds = eventRec.RecordIds__c.split(',');
            
            if(!recordIds.isEmpty()){
                Id recordId = (ID) recordIds[0];
                IManageAlertMappingInterface manageAlertMappingInstance = new ManageAlertMappingFactory(recordId.getSObjectType()).getInstance();
                manageAlertMappingInstance.manageAlertMapping(
                    recordIds,
                    ManageAlertMappingService.CHANGE_TYPE.valueOf(eventRec.ChangeType__c),
                    ManageAlertMappingService.TRIGGER_CONTEXT.valueOf(eventRec.TriggerContext__c)
                );
            }
        }
    }
}