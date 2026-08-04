public with sharing class AutoCaseRoleCreationByCaseTypeDecorator {
    public static final String CASE_TYPE_GENERIC = 'Generic Case Type';

    public static Map<String, Map<String, AutoCaseRoleCreationByCaseType__mdt>> autoCaseRoleCreationByCaseTypeMap{
        get{
            if(autoCaseRoleCreationByCaseTypeMap == null){
                autoCaseRoleCreationByCaseTypeMap = new Map<String, Map<String, AutoCaseRoleCreationByCaseType__mdt>>();
                for(AutoCaseRoleCreationByCaseType__mdt caseRoleCaseType : [SELECT Id, AutoCaseRoleCreationByCaseRT__c, AutoCaseRoleCreationByCaseRT__r.CaseRecordType__c, CaseType__c 
                        FROM AutoCaseRoleCreationByCaseType__mdt]){
                    if(!autoCaseRoleCreationByCaseTypeMap.containsKey(caseRoleCaseType.AutoCaseRoleCreationByCaseRT__r.CaseRecordType__c)){
                        autoCaseRoleCreationByCaseTypeMap.put(caseRoleCaseType.AutoCaseRoleCreationByCaseRT__r.CaseRecordType__c, new Map<String, AutoCaseRoleCreationByCaseType__mdt>{
                            caseRoleCaseType.CaseType__c => caseRoleCaseType
                        });
                    } else{
                        autoCaseRoleCreationByCaseTypeMap.get(caseRoleCaseType.AutoCaseRoleCreationByCaseRT__r.CaseRecordType__c).put(caseRoleCaseType.CaseType__c, caseRoleCaseType);
                    }
                }
            }
            return autoCaseRoleCreationByCaseTypeMap;
        }
        private set;
    }
}