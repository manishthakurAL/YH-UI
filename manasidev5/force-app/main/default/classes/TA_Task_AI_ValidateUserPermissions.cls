public with sharing class TA_Task_AI_ValidateUserPermissions implements TriggerAction.AfterInsert{
    public void afterInsert(List<Task> newList){
        TaskUserPermissionValidator.validate(newList);
    }
}