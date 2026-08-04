public with sharing class CaseCongaLetterTemplateService  extends CongaLetterTemplateBaseService {

    public CaseCongaLetterTemplateService(String recordId) {
        super(recordId);
    }
    
    public override CongaLetterTemplate[] getCongaTemplates(SObject record){
        Case caseRecord = (Case) record;
        CongaLetterTemplate[] templates = new List<CongaLetterTemplate>();
        CaseCongaSetting__mdt[] settings = [
            SELECT  Id, LetterType__c ,Category__c, LiveEditable__c, EnableInPersonSigning__c, 
                    CongaDocumentGenerationSetting__c, CongaDocumentGenerationSetting__r.TemplateId__c, 
                    EnableESign__c, DefaultTemplate__c
            FROM    CaseCongaSetting__mdt 
            WHERE   RecordTypeAPIName__c =: caseRecord.RecordType.DeveloperName  
                    AND  (CaseType__c =:  caseRecord.CaseType__c OR CaseType__c = null)
                    AND  (CaseStatus__c =: caseRecord.Status OR CaseStatus__c = null)
                    AND(   
                        (
                            (HousingPurpose__c = :caseRecord.Property__r.YH_HousingPurpose__c OR HousingPurpose__c = NULL)
                            AND  (RentType__c = :caseRecord.Property__r.YH_RentType__c OR RentType__c = NULL)
                            AND  (ProductType__c = :caseRecord.Property__r.YH_ProductType__c OR ProductType__c = NULL)
                        )
                        OR
                        (
                            (HousingPurpose__c = :caseRecord.Tenancy__r.Property__r.YH_HousingPurpose__c OR HousingPurpose__c = NULL)
                            AND  (RentType__c = :caseRecord.Tenancy__r.Property__r.YH_RentType__c OR RentType__c = NULL)
                            AND  (ProductType__c = :caseRecord.Tenancy__r.Property__r.YH_ProductType__c OR ProductType__c = NULL)
                        )
                    
                    )
            ORDER BY Category__c ASC NULLS FIRST, TemplateSortOrder__c ASC, LetterType__c ASC
        ];
        settings.addAll(getDefaultTemplates());
        for (CaseCongaSetting__mdt setting: settings) {
            CongaLetterTemplate template = new CongaLetterTemplate(
                setting.Id, 
                setting.CongaDocumentGenerationSetting__r.TemplateId__c,
                setting.CongaDocumentGenerationSetting__c,
                setting.LetterType__c,
                setting.Category__c,
                setting.LiveEditable__c,
                setting.EnableESign__c,
                setting.EnableInPersonSigning__c,
                setting.DefaultTemplate__c
            );
            templates.add(template);
        }
        return templates;
    }

    public override void saveLetterContentOnRecord(String letterContent){
        String caseObjectName = Case.SObjectType.getDescribe().getName();
        TriggerBase.bypass(caseObjectName);
        Case caseRecord = new Case(Id =super.recordId, LetterContent__c = letterContent);
        update caseRecord;
        TriggerBase.clearBypass(caseObjectName);
    }

    protected override Set<String> queryAdditionalParentFields() {
        return (new Set<String>{
            'RecordType.DeveloperName',
            'Property__r.YH_HousingPurpose__c', 
            'Property__r.YH_RentType__c', 
            'Property__r.YH_ProductType__c',
            'Tenancy__r.Property__r.YH_HousingPurpose__c', 
            'Tenancy__r.Property__r.YH_RentType__c', 
            'Tenancy__r.Property__r.YH_ProductType__c'
        });
    }

    private List<CaseCongaSetting__mdt> getDefaultTemplates() {
        return [
            SELECT  Id, LetterType__c ,Category__c, LiveEditable__c, EnableInPersonSigning__c, 
                    CongaDocumentGenerationSetting__c, CongaDocumentGenerationSetting__r.TemplateId__c, 
                    EnableESign__c, DefaultTemplate__c
            FROM    CaseCongaSetting__mdt 
            WHERE   DefaultTemplate__c = true
        ];
    }

}