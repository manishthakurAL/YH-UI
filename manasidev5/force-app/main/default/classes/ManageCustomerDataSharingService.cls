public with sharing class ManageCustomerDataSharingService {
    public enum TRIGGER_CONTEXT {
        INSERT_RECORD, 
        UPDATE_RECORD
    }
    public enum CHANGE_TYPE {
        RECORD_OWNERSHIP_CHANGED, 
        RECORD_ACTVIATED, 
        RECORD_DEACTIVATED, 
        RECORD_RECALCULATE_SHARING, 
        RECORD_REMOVE_SHARING
    }

    private List<Id> recordIds;
    private CHANGE_TYPE changeType;
    private TRIGGER_CONTEXT triggerContext;

    public ManageCustomerDataSharingService(List<Id> recordIds, CHANGE_TYPE changeType, TRIGGER_CONTEXT triggerContext) {
        this.recordIds = recordIds;
        
        if(changeType == null){
            throw new ManageCustomerDataSharingServiceException('Change type cannot be null');
        }
        if(triggerContext == null){
            throw new ManageCustomerDataSharingServiceException('Trigger context  cannot be null');
        }
        this.changeType = changeType;
        this.triggerContext = triggerContext;
    }

    public void shareRecords() {
        if (!this.recordIds.isEmpty()) {
            String ids = String.join(this.recordIds, ',');
            PortalRecordSharingEvent__e event = new PortalRecordSharingEvent__e(
                RecordIds__c = ids,
                ChangeType__c = this.changeType.name(),
                TriggerContext__c = this.triggerContext.name()
            );
            EventBus.publish(event);
        }
    }

    public class ManageCustomerDataSharingServiceException extends Exception {}
}