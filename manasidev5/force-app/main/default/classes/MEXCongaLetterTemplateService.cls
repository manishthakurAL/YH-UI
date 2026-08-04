public with sharing class MEXCongaLetterTemplateService extends CongaLetterTemplateBaseService {

    public MEXCongaLetterTemplateService(String recordId) {
        super(recordId);
    }
    
    public override CongaLetterTemplate[] getCongaTemplates(SObject record){
        YH_Mutual_Exchange__c mexRecord = (YH_Mutual_Exchange__c) record;
        CongaLetterTemplate[] templates = new List<CongaLetterTemplate>();
        MEXCongaSetting__mdt[] settings = [
            SELECT Id, CongaDocumentGenerationSetting__c, CongaDocumentGenerationSetting__r.TemplateId__c, 
                     LetterTitle__c, Category__c, EnableLiveEditable__c,
                     EnableESign__c, EnableInPersonSigning__c, IsDefaultTemplate__c
            FROM MEXCongaSetting__mdt
            WHERE (MutualExchangeType__c = :mexRecord.MutualExchangeType__c OR MutualExchangeType__c = NULL)
            ORDER BY Category__c ASC NULLS FIRST, TemplateSortOrder__c ASC
        ];
        for (MEXCongaSetting__mdt setting: settings) {
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
        String mexObjectName = YH_Mutual_Exchange__c.SObjectType.getDescribe().getName();
        TriggerBase.bypass(mexObjectName);
        YH_Mutual_Exchange__c mexRecord = new YH_Mutual_Exchange__c(Id =super.recordId, LetterContent__c = letterContent);
        update mexRecord;
        TriggerBase.clearBypass(mexObjectName);
    }

}