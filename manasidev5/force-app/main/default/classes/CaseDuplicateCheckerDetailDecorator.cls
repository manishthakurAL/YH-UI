public with sharing class CaseDuplicateCheckerDetailDecorator {
    public static Map<String, Map<String, CaseDuplicateCheckerDetail__mdt>> caseDuplicateCheckerDetailMap{
        get{
            if(caseDuplicateCheckerDetailMap == null){
                caseDuplicateCheckerDetailMap = new Map<String, Map<String, CaseDuplicateCheckerDetail__mdt>>();
                for(CaseDuplicateCheckerDetail__mdt caseRoleCaseType : [SELECT Id, ApexClass__c, CaseDuplicateChecker__r.CaseRecordType__c, CaseType__c 
                        FROM CaseDuplicateCheckerDetail__mdt]){
                    if(!caseDuplicateCheckerDetailMap.containsKey(caseRoleCaseType.CaseDuplicateChecker__r.CaseRecordType__c)){
                        caseDuplicateCheckerDetailMap.put(caseRoleCaseType.CaseDuplicateChecker__r.CaseRecordType__c, new Map<String, CaseDuplicateCheckerDetail__mdt>{
                            caseRoleCaseType.CaseType__c => caseRoleCaseType
                        });
                    } else{
                        caseDuplicateCheckerDetailMap.get(caseRoleCaseType.CaseDuplicateChecker__r.CaseRecordType__c).put(caseRoleCaseType.CaseType__c, caseRoleCaseType);
                    }
                }
            }
            return caseDuplicateCheckerDetailMap;
        }
        private set;
    }
}