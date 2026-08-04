public with sharing class TA_Case_BU_AddCaseOwnerValidation implements TriggerAction.BeforeUpdate {
    @TestVisible
    private static final String ERROR_MESSAGE = 'Safeguarding case can only be assigned to Customer Independence Manager or Safeguarding Officer or to any User with Safeguarding Permission Set Group'; 
    
    public static void beforeUpdate(List<Case> newList, List<Case> oldList) {
        Set<Id> ownerIds = new Set<Id>();
        Map<Id,Case> oldMap = new Map<Id,Case>(oldList);
        Map<Id, Case> newMap = new Map<Id, Case>(newList);
        Set<Id> userIdsWithValidPermission = new Set<Id>();
        Id safeguardingRTId = RecordTypeUtility.getRecordTypeIdByName(CaseDecorator.SOBJECT_TYPE_CASE, CaseDecorator.TYPE_SAFEGUARING);
        for (Case acase : newList) {
            Case oldCaseRecord = oldMap.get(acase.Id); 
            if (acase.RecordTypeId == safeguardingRTId && 
                        acase.OwnerId != oldCaseRecord.OwnerId) {
                if(String.valueOf(acase.OwnerId).startsWith('005')){
                    ownerIds.add(acase.OwnerId);
                }
            }
        }
        if( !ownerIds.isEmpty() ){
            userIdsWithValidPermission  = new PermissionEvaluator(ownerIds, PermissionSetDecorator.PS_CAN_UPDATE_SAFEGUARDING_CASE).checkIfSpecificPermissionIsAssignedToUser();
            for(Case acase: newList){
                if( !userIdsWithValidPermission.contains(acase.OwnerId) ){
                    acase.addError(ERROR_MESSAGE);
                }
            }
        }
    }
}