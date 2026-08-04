public with sharing class ManageAlertMappingService {
    public enum TRIGGER_CONTEXT {
        INSERT_RECORD, 
        UPDATE_RECORD
    }

    public enum CHANGE_TYPE {
        RECORD_ACTVIATED, 
        RECORD_DEACTIVATED
    }

    private List<Id> recordIds;
    private CHANGE_TYPE changeType;
    private TRIGGER_CONTEXT triggerContext;

    public ManageAlertMappingService(List<Id> recordIds, CHANGE_TYPE changeType, TRIGGER_CONTEXT triggerContext) {
        this.recordIds = recordIds;
        
        if(changeType == null){
            throw new ManageAlertMappingServiceException('Change type cannot be null');
        }
        if(triggerContext == null){
            throw new ManageAlertMappingServiceException('Trigger context cannot be null');
        }
        this.changeType = changeType;
        this.triggerContext = triggerContext;
    }

    public void createAlertMappingRecords() {
        if (!this.recordIds.isEmpty()) {
            String ids = String.join(this.recordIds, ',');
            AlertMappingEvent__e event = new AlertMappingEvent__e(
                RecordIds__c = ids,
                ChangeType__c = this.changeType.name(),
                TriggerContext__c = this.triggerContext.name()
            );
            EventBus.publish(event);
        }
    }

    
    public class ManageAlertMappingServiceException extends Exception {}
}