public with sharing class TA_Case_BU_ValidateClosedAwaabCaseEdit implements TriggerAction.BeforeUpdate {
    
    public void beforeUpdate(List<Case> newList, List<Case> oldList) {
        Map<Id, Case> oldMap = new Map<Id, Case>(oldList); 
        Set<String> allowedForAll = new Set<String>{CaseDecorator.CASE_FIELD_ORCHARD_JOBNUMBER};
        Set<String> allowedForTL = CaseDecorator.CASE_AWAABS_EDIT_TL_ALLOWED;
        Set<String> fieldsToIgnore = CaseDecorator.CASE_AWAABS_EDIT_TL_IGNORE_FOMRULA;
        Boolean hasTLPermission = FeatureManagement.checkPermission(CustomPermissionDecorator.CP_ALLOW_TO_CHANGE_CLOSED_DMCCASE);

        for (Case newCase : newList) {
            Case oldCase = oldMap.get(newCase.Id); 
            if (newCase.recordTypeId == CaseDecorator.RECORD_TYPE_ID_AWAABSLAW &&
                    newCase.isClosed && newCase.isClosed == oldCase.isClosed) {
                
                Map<String, Object> fieldMap = newCase.getPopulatedFieldsAsMap();
                for (String fieldName : fieldMap.keySet()){

                    if(fieldsToIgnore.contains(fieldName)){
                        continue;
                    } 

                    if(newCase.get(fieldName) != oldCase.get(fieldName)) {
                        if(hasTLPermission) {
                            if(!allowedForTL.contains(fieldName)){
                                newCase.addError(CaseDecorator.CASE_AWAABS_LAW_EDIT_ERROR_AFTER_CLOSURE_TL);
                            }
                        }else{
                            if(!allowedForAll.contains(fieldName)){
                                newCase.addError(CaseDecorator.CASE_AWAABS_LAW_EDIT_ERROR_AFTER_CLOSURE);
                            }
                        }
                    }
                }
            }
        }
    }
}