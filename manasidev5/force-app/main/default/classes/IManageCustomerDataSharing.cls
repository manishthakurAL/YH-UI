public interface IManageCustomerDataSharing {
    void manageRecordSharing(
        List<Id> recordIds, 
        ManageCustomerDataSharingService.CHANGE_TYPE changeType, 
        ManageCustomerDataSharingService.TRIGGER_CONTEXT triggerContext
    );
}