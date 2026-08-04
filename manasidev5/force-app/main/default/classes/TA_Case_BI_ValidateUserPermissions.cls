public with sharing class TA_Case_BI_ValidateUserPermissions implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<Case> newList){
        CaseUserPermissionValidator.validate(newList);
    }
}