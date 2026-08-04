public with sharing class CaseSharingByCaseTypeImpl implements ICaseExternalSharingByCaseType {

    public void manageCaseSharingReason(List<Case> newList, Map<Id, Case> oldMap){
        if(newList != null){
            for(Case caseRecord: newList){
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