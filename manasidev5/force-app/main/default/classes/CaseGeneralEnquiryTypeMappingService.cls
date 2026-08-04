public inherited sharing class CaseGeneralEnquiryTypeMappingService {

    private List<Case> caseList;
    private final List<String> externalOrigins = new List<String>{
                                                CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL, 
                                                CaseDecorator.CASE_ORIGIN_GUEST_PORTAL
                                            };

    private List<ExternalInternalTypeMapping__mdt> mdtRecordList{
        get {
            if (this.mdtRecordList == null) {
                this.mdtRecordList = [SELECT Id, ExternalType1__c, ExternalType2__c, InternalType1__c, InternalType2__c 
                            FROM ExternalInternalTypeMapping__mdt 
                            WHERE SObject__c = :CaseDecorator.SOBJECT_TYPE_CASE AND
                            RecordType__c = :CaseDecorator.RECORD_TYPE_GENERAL_ENQUIRY AND
                            IsActive__c = true];
            }
            return this.mdtRecordList;
        }
        set;
    }

    private Map<String, ExternalInternalTypeMapping__mdt> mdtMappingByExternalType{
        get{
            if(this.mdtMappingByExternalType == null){
                this.mdtMappingByExternalType = new Map<String, ExternalInternalTypeMapping__mdt>();
                for(ExternalInternalTypeMapping__mdt mdtRec : this.mdtRecordList){
                    string key = mdtRec.ExternalType1__c + ':' + mdtRec.ExternalType2__c;
                    this.mdtMappingByExternalType.put(key, mdtRec);
                }
            }
            return this.mdtMappingByExternalType;
        }
        set;
    }

    private Map<String, ExternalInternalTypeMapping__mdt> mdtMappingByInternalType{
        get{
            if(this.mdtMappingByInternalType == null){
                this.mdtMappingByInternalType = new Map<String, ExternalInternalTypeMapping__mdt>();
                for(ExternalInternalTypeMapping__mdt mdtRec : this.mdtRecordList){
                    string key = mdtRec.InternalType1__c + ':' + mdtRec.InternalType2__c;
                    this.mdtMappingByInternalType.put(key, mdtRec);
                }
            }
            return this.mdtMappingByInternalType;
        }
        set;
    }

    public CaseGeneralEnquiryTypeMappingService(List<Case> caseList) {
        this.caseList = caseList;
    }

    public void execute(){
        for(Case cRec : this.caseList){
            if(this.externalOrigins.contains(cRec.Origin)){
                updateInternalTypeFields(cRec);
            }else {
                updateExternalTypeFields(cRec);
            }
        }
    }

    private void updateInternalTypeFields(Case cRec){
        String key = cRec.CustomerCaseType__c + ':' + cRec.CustomerEnquiryType__c;
        if(this.mdtMappingByExternalType.containsKey(key)){
            ExternalInternalTypeMapping__mdt mdtRec = this.mdtMappingByExternalType.get(key);
            cRec.CaseType__c = mdtRec.InternalType1__c;
            cRec.EnquiryType__c = mdtRec.InternalType2__c;
        }
    }

    private void updateExternalTypeFields(Case cRec){
        String key = cRec.CaseType__c + ':' + cRec.EnquiryType__c;
        if(this.mdtMappingByInternalType.containsKey(key)){
            ExternalInternalTypeMapping__mdt mdtRec = this.mdtMappingByInternalType.get(key);
            cRec.CustomerCaseType__c = mdtRec.ExternalType1__c;
            cRec.CustomerEnquiryType__c = mdtRec.ExternalType2__c;
        }
    }
}