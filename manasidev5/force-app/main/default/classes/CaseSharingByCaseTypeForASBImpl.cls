public with sharing class CaseSharingByCaseTypeForASBImpl implements ICaseExternalSharingByCaseType {

    public void manageCaseSharingReason(List<Case> newList, Map<Id, Case> oldMap){
        if(newList != null && oldMap != null){
            for(Case caseRecord: newList){
                if(!String.isBlank(caseRecord.CaseReadyForSharing__c) && 
                    caseRecord.CaseReadyForSharing__c != oldMap.get(caseRecord.Id).CaseReadyForSharing__c){
                    List<String> readyForSharingList = caseRecord.CaseReadyForSharing__c.split(';');
                    List<String> oldReadyForSharingList = oldMap.get(caseRecord.Id).CaseReadyForSharing__c != null ? 
                                                            oldMap.get(caseRecord.Id).CaseReadyForSharing__c.split(';') : 
                                                            new List<String>();
                    if(readyForSharingList.contains(CaseDecorator.RECORD_TYPE_BREACH) && !oldReadyForSharingList.contains(CaseDecorator.RECORD_TYPE_BREACH)){
                        String caseRecordType = RecordTypeUtility.getRecordTypeDeveloperNameById(CaseDecorator.SOBJECT_TYPE_CASE, caseRecord.RecordTypeId);
                        String caseType = caseRecord.CaseType__c;
                        CaseExternalSharingMetaDataService caseExtSharingMetadata = new CaseExternalSharingMetaDataService(caseRecordType);
                        if(caseExtSharingMetadata.caseExtSharingDetailByCaseTypeMap.containsKey(caseType)){
                            List<CaseExternalSharingDetail__mdt> caseSharingDetails = caseExtSharingMetadata.caseExtSharingDetailByCaseTypeMap.get(caseType);
                            List<String> customerSharingReasonList = new List<String>();
                            for(CaseExternalSharingDetail__mdt sharingDetail : caseSharingDetails){
                                customerSharingReasonList.add(sharingDetail.ShareWith__c);
                            }
                            caseRecord.CustomerSharingReasons__c = String.join(customerSharingReasonList, ';');          
                        }
                    }
                }
            }
        }  
    }
}