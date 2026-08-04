public inherited sharing class CaseUserPermissionValidator {
    
    public static void validate( List<Case> caseList) {
        PermissionEvaluator.ActionType type = trigger.isInsert ? PermissionEvaluator.ActionType.Create: PermissionEvaluator.ActionType.Edit;

        for (Case record : caseList) {
            PermissionEvaluator validator = new PermissionEvaluator(Case.sObjectType, type.name());
            if(!validator.hasPermission(record)){
                if (trigger.isInsert) {
                    record.addError(Label.CasePermissionValidationError);
                } else {
                    trigger.newMap.get(record.Id).addError(Label.CasePermissionValidationError);
                }
            } 
        }
    }
}