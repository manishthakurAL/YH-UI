public with sharing class ApplicationCongaLetterTemplateService extends CongaLetterTemplateBaseService {

    public ApplicationCongaLetterTemplateService(String recordId) {
        super(recordId);
    }
    
    public override CongaLetterTemplate[] getCongaTemplates(SObject record){
        YH_Application__c application = (YH_Application__c) record;
        CongaLetterTemplate[] templates = new List<CongaLetterTemplate>();
        ApplicationCongaSetting__mdt[] settings = [
            SELECT Id, CongaDocumentGenerationSetting__c, CongaDocumentGenerationSetting__r.TemplateId__c, 
                     LetterTitle__c, Category__c, EnableLiveEditable__c,
                     EnableESign__c, EnableInPersonSigning__c, IsDefaultTemplate__c
            FROM ApplicationCongaSetting__mdt
            WHERE ((HousingPurpose__c = :application.Property__r.YH_HousingPurpose__c OR HousingPurpose__c = NULL)
            AND (RentType__c = :application.Property__r.YH_RentType__c OR RentType__c = NULL)
            AND (ProductType__c = :application.Property__r.YH_ProductType__c OR ProductType__c = NULL)
            AND (StarterOrAssured__c = :application.StarterOrAssured__c OR StarterOrAssured__c = NULL)
            AND (NumberOfTenants__c = :application.NumberOfTenants__c OR NumberOfTenants__c = NULL)
            AND (NumberOfAgreementSignedApplications__c = :application.Case__r.NumberOfAgreementSignedApplications__c OR NumberOfAgreementSignedApplications__c = NULL )      
            )
            ORDER BY Category__c ASC NULLS FIRST, TemplateSortOrder__c ASC
        ];
        for (ApplicationCongaSetting__mdt setting: settings) {
            CongaLetterTemplate template = new CongaLetterTemplate(
                setting.Id, 
                setting.CongaDocumentGenerationSetting__r.TemplateId__c,
                setting.CongaDocumentGenerationSetting__c,
                setting.LetterTitle__c,
                setting.Category__c,
                setting.EnableLiveEditable__c,
                setting.EnableESign__c,
                setting.EnableInPersonSigning__c,
                setting.IsDefaultTemplate__c
            );
            templates.add(template);
        }
        return templates;
    }

    public override void saveLetterContentOnRecord(String letterContent){
        String applicationObjectName = YH_Application__c.SObjectType.getDescribe().getName();
        TriggerBase.bypass(applicationObjectName);
        YH_Application__c applicationRecord = new YH_Application__c(Id =super.recordId, LetterContent__c = letterContent);
        update applicationRecord;
        TriggerBase.clearBypass(applicationObjectName);
    }

    protected override Set<String> queryAdditionalParentFields() {
        return (new Set<String>{
            'Property__r.YH_HousingPurpose__c', 
            'Property__r.YH_RentType__c', 
            'Property__r.YH_ProductType__c',
            'Case__r.NumberOfAgreementSignedApplications__c'
        });
    }

}