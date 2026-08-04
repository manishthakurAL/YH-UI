public with sharing class TA_Task_BU_ValidateUserPermissions implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<Task> newList, List<Task> oldList){
        TaskUserPermissionValidator.validate(newList);
    }
}