public with sharing class CaseExternalSharingMetaDataService {
    private String recordType;

    public CaseExternalSharingMetaDataService(String recordType){
        this.recordType = recordType;
    }

    public  Map<String, List<CaseExternalSharingDetail__mdt>> caseExtSharingDetailByCaseTypeMap{
        get{
            if(String.isNotBlank(this.recordType) && caseExternalSharingByRTMap.containsKey(this.recordType)){
                if(!caseExtSharingDetailsMapbyRTCT.containsKey(this.recordType)){
                    caseExtSharingDetailsMapbyRTCT.put(this.recordType,  new Map<String, List<CaseExternalSharingDetail__mdt>>());
                    for(CaseExternalSharingDetail__mdt externalSharingDetail : [
                                SELECT Id, DeveloperName, CaseExternalSharingByCaseType__c, CaseExternalSharingByCaseType__r.CaseType__c, 
                                CaseExternalSharingByCaseType__r.CaseExternalSharingByRT__r.CaseRecordType__c, AccessLevel__c, ShareWith__c, ImplClassName__c
                                FROM CaseExternalSharingDetail__mdt
                                WHERE CaseExternalSharingByCaseType__r.CaseExternalSharingByRT__c = :caseExternalSharingByRTMap.get(this.recordType).Id]){
                        List<CaseExternalSharingDetail__mdt> externalSharingDetails = caseExtSharingDetailsMapbyRTCT.get(this.recordType).get(externalSharingDetail.CaseExternalSharingByCaseType__r.CaseType__c);
                        if(externalSharingDetails == null){
                            externalSharingDetails = new List<CaseExternalSharingDetail__mdt>();
                        } 
                        externalSharingDetails.add(externalSharingDetail);
                        caseExtSharingDetailsMapbyRTCT.get(this.recordType).put(externalSharingDetail.CaseExternalSharingByCaseType__r.CaseType__c, externalSharingDetails );
                    }
                }
                this.caseExtSharingDetailByCaseTypeMap = caseExtSharingDetailsMapbyRTCT.get(this.recordType);
            } else{
                this.caseExtSharingDetailByCaseTypeMap = new Map<String, List<CaseExternalSharingDetail__mdt>>();
            }
            return this.caseExtSharingDetailByCaseTypeMap;
        }
        set;
    }

    private static Map<String, CaseExternalSharingByRT__mdt> caseExternalSharingByRTMap{
        get{
            if(caseExternalSharingByRTMap == null){
                caseExternalSharingByRTMap = new Map<String, CaseExternalSharingByRT__mdt>();
                for(CaseExternalSharingByRT__mdt caseExternalSharingByRTSetting : CaseExternalSharingByRT__mdt.getAll().values()){
                    caseExternalSharingByRTMap.put(caseExternalSharingByRTSetting.CaseRecordType__c, caseExternalSharingByRTSetting);
                }
            }
            return caseExternalSharingByRTMap;
        }
        
        private set;
    }

    private static Map<String, Map<String, List<CaseExternalSharingDetail__mdt>>> caseExtSharingDetailsMapbyRTCT = new Map<String, Map<String, List<CaseExternalSharingDetail__mdt>>>();

}