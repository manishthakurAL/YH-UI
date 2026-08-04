public inherited sharing class ValidateProcessObjectPermissions {
    public static void validate( List<sobject> sobjectList, SobjectType sobjType) {
        PermissionEvaluator.ActionType type = trigger.isInsert ? PermissionEvaluator.ActionType.Create: PermissionEvaluator.ActionType.Edit;
        Map<Id, Case> caseRecordMaps = new Map<Id, Case>();
        Map<Id, List<sobject>> sobjectListByCaseId = new Map<Id, List<sobject>>();

        Set<Id>caseIds = new Set<Id>();
        for (Sobject aRecord : sobjectList) {
           caseIds.add((Id)aRecord.get('Case__c'));
           List<Sobject> records = sobjectListByCaseId.get((Id)aRecord.get('Case__c'));
           if(records == null){
            records = new List<Sobject>();
           }
           records.add(aRecord);
           sobjectListByCaseId.put((Id)aRecord.get('Case__c'), records);
        }


        if(!caseIds.isEmpty()){
            caseRecordMaps = new Map<Id, Case>([SELECT Id, RecordTypeId, RecordType.Name, Status FROM Case WHERE Id IN:caseIds]);
        }

        if(!caseRecordMaps.isEmpty()){
            String errorMessage;
            for (Id caseId : sobjectListByCaseId.keySet()) {
                for(Sobject arecord : sobjectListByCaseId.get(caseId)){
                    PermissionEvaluator validator = new PermissionEvaluator(sobjType, type.name());
                    if(!validator.hasPermission(caseRecordMaps.get(caseId))){
                        List<Object> parameters = new List<Object> { caseRecordMaps.get(caseId).RecordType.Name };
                        if (trigger.isInsert) {
                            errorMessage = String.format(Label.ProcessObjectPermissionValidationError,parameters);
                        } else{
                            errorMessage = String.format(Label.ProcessObjectPermissionValidationErrorEdit,parameters);
                        }
                        arecord.addError(errorMessage);
                    }  
                }   
            }
        }        
    }
}