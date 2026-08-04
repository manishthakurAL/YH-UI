public inherited sharing class TaskUserPermissionValidator {

    public static void validate( List<Task> taskList) {
        PermissionEvaluator.ActionType type = trigger.isInsert ? PermissionEvaluator.ActionType.Create: PermissionEvaluator.ActionType.Edit;
        Map<Id, Case> caseRecordMaps = new Map<Id, Case>();
        Map<Id, Task> caseIdtaskMap = new Map<Id, Task>();

        for (Task record : taskList) {
            if(record.WhatId != null && String.valueOf(record.WhatId).startsWith('500') && record.TaskSubtype != TaskDecorator.SUBSTATUS_EMAIL){
                caseIdtaskMap.put(record.WhatId, record);
            }
        }

        if(!caseIdtaskMap.keySet().isEmpty()){
            caseRecordMaps = new Map<Id, Case>([SELECT Id, RecordTypeId, Status FROM Case WHERE Id IN:caseIdtaskMap.keySet()]);
        }

        if(!caseRecordMaps.isEmpty()){
            for (Task record : taskList) {
                if(caseRecordMaps.containsKey(record.WhatId)){
                    PermissionEvaluator validator = new PermissionEvaluator(Task.SObjectType, type.name());
                    if(!validator.hasPermission(caseRecordMaps.get(record.WhatId))){
                        String errorMessage = Label.TaskPermissionValidationError;
                        if (trigger.isInsert) {
                            record.addError(errorMessage);
                        } else {
                            trigger.newMap.get(caseIdtaskMap.get(record.WhatId).Id).addError(errorMessage);
                        }
                    }
                }  
            }
        }        
    }
}