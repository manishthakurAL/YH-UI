public with sharing class CaseDuplicateCheckerDecorator {
    public static Map<String, CaseDuplicateChecker__mdt> caseDuplicateCheckerMap{
        get{
            if(caseDuplicateCheckerMap == null){
                caseDuplicateCheckerMap = new Map<String, CaseDuplicateChecker__mdt>();
                for(CaseDuplicateChecker__mdt caseRoleSetupSetting : CaseDuplicateChecker__mdt.getAll().values()){
                    caseDuplicateCheckerMap.put(caseRoleSetupSetting.CaseRecordType__c, caseRoleSetupSetting);
                }
            }
            return caseDuplicateCheckerMap;
        }
        private set;
    }
}