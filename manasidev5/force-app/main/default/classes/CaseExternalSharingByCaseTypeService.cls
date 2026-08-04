public inherited sharing class CaseExternalSharingByCaseTypeService {
    
    private List<Case> cases; 

    public CaseExternalSharingByCaseTypeService(List<Case>cases){
        this.cases = cases;
    }

    public void populateCaseSharingReasonBasedOnCaseType(){
        if(this.cases != null){
            for(Case caseRecord: cases){
                String caseRecordType = RecordTypeUtility.getRecordTypeDeveloperNameById(CaseDecorator.SOBJECT_TYPE_CASE, caseRecord.RecordTypeId);
                String caseType = caseRecord.CaseType__c;
                CaseExternalSharingMetaDataService caseExtSharingMetadata = new CaseExternalSharingMetaDataService(caseRecordType);
                if(caseExtSharingMetadata.caseExtSharingDetailByCaseTypeMap.containsKey(caseType)){
                        List<CaseExternalSharingDetail__mdt> caseSharingDetails = caseExtSharingMetadata.caseExtSharingDetailByCaseTypeMap.get(caseType);
                        String customerSharingReason ='';
                        for(CaseExternalSharingDetail__mdt sharingDetail : caseSharingDetails){
                            customerSharingReason += sharingDetail.ShareWith__c + ';';
                        }
                        caseRecord.CustomerSharingReasons__c = customerSharingReason.removeEnd(';');        
                }else{
                        caseRecord.CustomerSharingReasons__c = '';        
                }
            }
        }   
    }
}