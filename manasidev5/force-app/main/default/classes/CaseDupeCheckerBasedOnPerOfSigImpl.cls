public without sharing class CaseDupeCheckerBasedOnPerOfSigImpl implements ICaseDuplicateChecker{
    public Map<Id, List<Case>> getDuplicate(List<Case> caseRecords, Id recordTypeId, String caseType){
        Map<Id, List<Case>> duplicateCaseListByCaseId = new Map<Id, List<Case>>();
        Map<Id, List<Id>> caseIdsByContactIdMap = new Map<Id, List<Id>>();
        
        for(Case caseRecord : caseRecords){
            if(caseRecord.ContactId != null){
                if(caseIdsByContactIdMap.containsKey(caseRecord.ContactId)){
                    caseIdsByContactIdMap.get(caseRecord.ContactId).add(caseRecord?.Id);
                } else {
                    caseIdsByContactIdMap.put(caseRecord.ContactId, new List<Id>{caseRecord?.Id});
                }
            }
            
            if(!duplicateCaseListByCaseId.containsKey(caseRecord?.Id)){
                duplicateCaseListByCaseId.put(caseRecord?.Id, new List<Case>());
            }
        }

        if(!caseIdsByContactIdMap.isEmpty()){
            for(Case caseDupeRec : [SELECT Id, ContactId, CaseNumber, CaseNumberUrl__c, CaseType__c, Status, OriginalReceivedDateTime__c,
                                    OwnerId
                                    FROM Case
                                    WHERE IsClosed = false
                                        AND RecordTypeId =: recordTypeId
                                        AND CaseType__c =: caseType
                                        AND ContactId IN: caseIdsByContactIdMap.keySet()]){
                
                for(Id caseId : caseIdsByContactIdMap.get(caseDupeRec.ContactId)){
                    if(caseId != caseDupeRec.Id){
                        duplicateCaseListByCaseId.get(caseId).add(caseDupeRec);
                    }
                }              
            }
        }

        return duplicateCaseListByCaseId;
    }

}