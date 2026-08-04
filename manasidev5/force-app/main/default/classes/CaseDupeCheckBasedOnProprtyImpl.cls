public with sharing class CaseDupeCheckBasedOnProprtyImpl implements ICaseDuplicateChecker{
    
    public Map<Id, List<Case>> getDuplicate(List<Case> caseRecords, Id recordTypeId, String caseType){
        Map<Id, List<Case>> duplicateCaseListByPropertyId = new Map<Id, List<Case>>();
        Set<Id> propertyIds = new Set<Id>();
        for(Case caseRecord : caseRecords){
            if (caseRecord.Property__c != null) {
                duplicateCaseListByPropertyId.put(caseRecord.Id, new List<Case>());
                propertyIds.add(caseRecord.Property__c);
            }
        }

        if(!duplicateCaseListByPropertyId.isEmpty()){
            for(Case caseDupeRec : [SELECT Id, ContactId, Property__c, CaseNumber, CaseNumberUrl__c, CaseType__c, Status, OriginalReceivedDateTime__c,
                                    OwnerId
                                    FROM Case
                                    WHERE IsClosed = false
                                        AND RecordTypeId =: recordTypeId
                                        AND CaseType__c =: caseType
                                        AND Property__c IN: propertyIds]){
                
                duplicateCaseListByPropertyId.get(caseRecords.get(0).Id).add(caseDupeRec);
            }
        }
        return duplicateCaseListByPropertyId;
    }
}