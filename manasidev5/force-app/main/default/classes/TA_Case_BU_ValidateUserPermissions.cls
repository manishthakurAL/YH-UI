public with sharing class TA_Case_BU_ValidateUserPermissions implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<Case> newList, List<Case> oldList){
        CaseUserPermissionValidator.validate(oldList);
    }
}