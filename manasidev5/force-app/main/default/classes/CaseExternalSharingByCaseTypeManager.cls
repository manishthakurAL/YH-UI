public with sharing class CaseExternalSharingByCaseTypeManager{
    private List<Case> newCases;
    private Map<Id, Case> oldCases;

    public CaseExternalSharingByCaseTypeManager(List<Case> newList, Map<Id, Case> oldMap){
        this.newCases = newList;
        this.oldCases = oldMap;
    }

    private Map<String, List<Case>> casesByImpClassName {
        get{
            if(this.casesByImpClassName == null){
                this.casesByImpClassName = new Map<String, List<Case>>();
                if(!this.newCases.isEmpty()){
                    for(Case caseRecord: this.newCases){
                        Case oldCase = this.oldCases?.get(caseRecord.Id);
                        String caseType = caseRecord.CaseType__c;
                        String caseRecordType = RecordTypeUtility.getRecordTypeDeveloperNameById(CaseDecorator.SOBJECT_TYPE_CASE, caseRecord.RecordTypeId);
                        CaseExternalSharingMetaDataService caseExtSharingMetadata = new CaseExternalSharingMetaDataService(caseRecordType);
                        if(caseExtSharingMetadata.caseExtSharingDetailByCaseTypeMap.containsKey(caseType)){
                            List<CaseExternalSharingDetail__mdt> caseSharingDetails = caseExtSharingMetadata.caseExtSharingDetailByCaseTypeMap.get(caseType);
                            for(CaseExternalSharingDetail__mdt sharingDetail : caseSharingDetails){
                                if(sharingDetail.ImplClassName__c != null){
                                    this.buildCasesByImpClassName(sharingDetail.ImplClassName__c, caseRecord);
                                } else {
                                    throw new CaseExternalSharingByCaseTypeManagerException('Class implementation not found for ' + caseType + ' object');
                                }
                            }
                        } 
                    }
                }         
            }
            return this.casesByImpClassName;
        }
        set;
    }

    private void buildCasesByImpClassName(String className, Case caseRecord){
        if(this.casesByImpClassName.containsKey(className)){
            this.casesByImpClassName.get(className).add(caseRecord);
        } else{
            this.casesByImpClassName.put(className, new List<Case>{caseRecord});
        }
    }
    
    public void manageCaseSharingReason(){
        if(!this.casesByImpClassName.isEmpty()){
            for(String className : this.casesByImpClassName.keySet()){
                ICaseExternalSharingByCaseType instance = (ICaseExternalSharingByCaseType) Type.forName(className).newInstance();
                instance.manageCaseSharingReason(
                    this.casesByImpClassName.get(className),
                    this.oldCases
                );
            }
        }
    }

    public class CaseExternalSharingByCaseTypeManagerException extends Exception {}
}