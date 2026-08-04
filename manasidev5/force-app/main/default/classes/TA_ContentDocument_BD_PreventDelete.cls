public with sharing class TA_ContentDocument_BD_PreventDelete implements TriggerAction.BeforeDelete {
    @TestVisible
    private static final String ERROR_MESSAGE = 'You are not allowed to delete the Document'; 
    
    public static void beforeDelete(List<ContentDocument> oldList) {
        Set<Id> loggedInUser = new Set<Id>{UserInfo.getUserId()};
        Set<Id> userIdsWithValidPermission  = new PermissionEvaluator(loggedInUser, PermissionSetDecorator.PS_CAN_DELETE_CONTENT_DOCUMENT).checkIfSpecificPermissionIsAssignedToUser();
        if(userIdsWithValidPermission.isEmpty()){
            for(ContentDocument aDocument: oldList){
                aDocument.addError(ERROR_MESSAGE);
            }
        }
    }
}