public inherited sharing class CaseDupeCheckBasedOnTenancyImpl implements ICaseDuplicateChecker {

    public Map<Id, List<Case>> getDuplicate(List<Case> caseRecords, Id recordTypeId, String caseType) {
        Map<Id, List<Case>> duplicateCaseMapByCaseId = new Map<Id, List<Case>>();
        Set<Id> tenancyIds = new Set<Id>();
        List<Case> duplicateCaseList = new List<Case>();
        if(!caseRecords.isEmpty() ){
            if(caseRecords.size() == 1){
                Case inputCase = caseRecords.isEmpty() ? null : caseRecords[0];
                
                if (inputCase != null && inputCase.Tenancy__c != null) {
                    tenancyIds.add(inputCase.Tenancy__c);
                }

                if (!tenancyIds.isEmpty()) {
                    duplicateCaseList = [
                        SELECT Id, CaseNumberUrl__c, OriginalReceivedDateTime__c, Status, CaseType__c, Tenancy__c, RecordTypeId
                        FROM Case
                        WHERE IsClosed = false
                            AND RecordTypeId = :recordTypeId
                            AND CaseType__c = :caseType
                            AND Tenancy__c IN :tenancyIds
                    ];
                }


        // Note key is null since case has not been inserted yet, this is a known issue
        duplicateCaseMapByCaseId.put(inputCase?.Id, duplicateCaseList);

            }
            else{
                for(Case caseRec : caseRecords){
                    if(caseRec.Tenancy__c != null) {
                        tenancyIds.add(caseRec.Tenancy__c);
                    }
                }
                if (!tenancyIds.isEmpty()) {
                    for(Case dupeCase: [SELECT Id, CaseNumberUrl__c, OriginalReceivedDateTime__c, Status, CaseType__c, Tenancy__c, RecordTypeId
                                        FROM Case
                                        WHERE IsClosed = false
                                        AND RecordTypeId = :recordTypeId
                                        AND CaseType__c = :caseType
                                        AND Tenancy__c IN :tenancyIds]){
                            
                                if(!duplicateCaseMapByCaseId.containsKey(dupeCase.Tenancy__c)){
                                        duplicateCaseMapByCaseId.put(dupeCase.Tenancy__c, new List<Case>());
                                }
                                duplicateCaseMapByCaseId.get(dupeCase.Tenancy__c).add(dupeCase); 
                    }
                }
            }
        }

        return duplicateCaseMapByCaseId; 
    }
}