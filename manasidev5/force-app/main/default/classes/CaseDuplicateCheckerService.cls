public inherited sharing class CaseDuplicateCheckerService {

    public Map<Id, List<Case>> getDuplicate(List<Case> cases){
        Map<Id, List<Case>> caseIdDuplicateCasesMap = new Map<Id, List<Case>>();
        Map<String, List<Case>> caseRTCaseTypeCaseListMap = new Map<String, List<Case>>();
        Map<String, String> caseRTCaseTypeClassImpMap = new Map<String, String>();
        for(Case caseRecord : cases){
            caseIdDuplicateCasesMap.put(caseRecord?.Id, new List<Case>());
            String caseRecordType = RecordTypeUtility.getRecordTypeDeveloperNameById(CaseDecorator.SOBJECT_TYPE_CASE, caseRecord.RecordTypeId);
            String caseType = caseRecord.CaseType__c;

            if(CaseDuplicateCheckerDecorator.caseDuplicateCheckerMap.containsKey(caseRecordType)){
                if(CaseDuplicateCheckerDetailDecorator.caseDuplicateCheckerDetailMap.containsKey(caseRecordType)){
                    if(CaseDuplicateCheckerDetailDecorator.caseDuplicateCheckerDetailMap.get(caseRecordType).containsKey(caseType)){
                        CaseDuplicateCheckerDetail__mdt caseDuplicateCheckerDetail = CaseDuplicateCheckerDetailDecorator.caseDuplicateCheckerDetailMap.get(caseRecordType).get(caseType);
                        
                        if(!caseRTCaseTypeCaseListMap.containsKey(caseRecord.RecordTypeId+'--'+caseType)){
                            caseRTCaseTypeCaseListMap.put(caseRecord.RecordTypeId+'--'+caseType, new List<Case>{caseRecord});
                        } else {
                            caseRTCaseTypeCaseListMap.get(caseRecord.RecordTypeId+'--'+caseType).add(caseRecord);
                        }

                        caseRTCaseTypeClassImpMap.put(caseRecord.RecordTypeId+'--'+caseType, caseDuplicateCheckerDetail.ApexClass__c);
                    } else {
                        caseIdDuplicateCasesMap.put(caseRecord?.Id, null);
                    }
                } else {
                    if(CaseDuplicateCheckerDecorator.caseDuplicateCheckerMap.get(caseRecordType).ApexClass__c != null){

                        if(!caseRTCaseTypeCaseListMap.containsKey(caseRecord.RecordTypeId+'--'+caseType)){
                            caseRTCaseTypeCaseListMap.put(caseRecord.RecordTypeId+'--'+caseType, new List<Case>{caseRecord});
                        } else {
                            caseRTCaseTypeCaseListMap.get(caseRecord.RecordTypeId+'--'+caseType).add(caseRecord);
                        }

                        caseRTCaseTypeClassImpMap.put(caseRecord.RecordTypeId+'--'+caseType, CaseDuplicateCheckerDecorator.caseDuplicateCheckerMap.get(caseRecordType).ApexClass__c);
                    } else {
                        caseIdDuplicateCasesMap.put(caseRecord?.Id, null);
                    }
                }
            } else {
                caseIdDuplicateCasesMap.put(caseRecord?.Id, null);
            }
        }

        if(!caseRTCaseTypeCaseListMap.isEmpty()){
            for(String key : caseRTCaseTypeCaseListMap.keySet()){
                String className = caseRTCaseTypeClassImpMap.get(key);
                Type t =  Type.forName(className);
                List<String> caseRTandType = key.split('--');
                ICaseDuplicateChecker dupeCheckerInstance = (ICaseDuplicateChecker) t.newInstance();
                caseIdDuplicateCasesMap.putAll(dupeCheckerInstance.getDuplicate(caseRTCaseTypeCaseListMap.get(key), caseRTandType[0], caseRTandType[1]));
            }
        }

        return caseIdDuplicateCasesMap;
    }
}