public interface IManageAlertMappingInterface {
    void manageAlertMapping(
        List<Id> recordIds, 
        ManageAlertMappingService.CHANGE_TYPE changeType, 
        ManageAlertMappingService.TRIGGER_CONTEXT triggerContext
    );
}