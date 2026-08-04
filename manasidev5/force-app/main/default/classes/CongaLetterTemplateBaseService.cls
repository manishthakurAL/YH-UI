public with sharing abstract class CongaLetterTemplateBaseService {

    public static final String GLOBAL_CATEGORY = 'Default Templates';

    protected String recordId;
    
    public abstract CongaLetterTemplate[] getCongaTemplates(SObject record);

    public abstract void saveLetterContentOnRecord(String letterContent);

    protected CongaLetterTemplateBaseService(String recordId) {
        this.recordId = recordId;
    }

    public virtual GetCongaLettersResult getCongaLetters() {
        SObject record = getRecord();
        CongaLetterTemplate[] templates = getCongaTemplates(record); // this must be implimented by each Conga Live Edit Controller
        return (new GetCongaLettersResult(templates));
    }

    public virtual String getCongaUrl(Id urlParamSettingsId, String actionType) {
        CongaDocumentGenerationSetting__mdt settings = CongaDocumentGenerationSetting__mdt.getInstance(urlParamSettingsId);
        return CongaService.get().getCongaUrl(
            this.recordId, 
            settings.DeveloperName, 
            CongaService.ActionType.valueOf(actionType)
        );
    }

    public virtual String getLetterDraftContent(String templateKey) {
        String letterContent;
        CongaLetterDraftContent__c[] tempContents = [
            SELECT LetterContent__c
            FROM CongaLetterDraftContent__c 
            WHERE ParentId__c =: this.recordId AND 
            TemplateKey__c =: templateKey
            ORDER BY CreatedDate DESC
        ];

        if (!tempContents.isEmpty()) {
            letterContent = tempContents[0].LetterContent__c;
        }
        return letterContent;
    }

    public virtual void saveLetterDraftContent(String templateKey, String letterContent) {
        CongaLetterDraftContent__c draftContent = new CongaLetterDraftContent__c(
            LetterContent__c = letterContent,
            ParentId__c = this.recordId,
            TemplateKey__c = templateKey,
            CompositeKey__c = this.recordId + templateKey
        );
        upsert draftContent CompositeKey__c;
    }

    public virtual void saveLetterContent(String templateKey, String letterContent) {
        saveLetterDraftContent(templateKey, letterContent);
        saveLetterContentOnRecord(letterContent);
    }

    protected virtual Set<String> queryAdditionalParentFields() {
        return (new Set<String>());
    }


    private SObject getRecord() {
        String sobjectType = SObjectUtils.getSObjectTypeFromId(this.recordId);
        Set<String> parentFields = queryAdditionalParentFields();
        return new QueryBuilder(sobjectType)
        .addFieldsAll()
        .addFields(parentFields)
        .addConditions()
        .add(new QueryBuilder.CompareCondition('Id').eq(this.recordId))
        .endConditions()
        .toList()
        .get(0);
    }

    public class CongaLetterTemplate {
        @AuraEnabled public String templateId;
        @AuraEnabled public String templateKey;
        @AuraEnabled public String urlParamSettingsId;
        @AuraEnabled public String letterTitle;
        @AuraEnabled public String letterCategory;
        @AuraEnabled public Boolean isGlobalTemplate;
        @AuraEnabled public Boolean isLiveEditable;
        @AuraEnabled public Boolean isESigningEnabled;
        @AuraEnabled public Boolean isInPersonSigningEnabled;

        public CongaLetterTemplate(String templateId, String templateKey, 
        String urlParamSettingsId, String letterTitle, String letterCategory, 
        Boolean isLiveEditable, Boolean isESigningEnabled, Boolean isInPersonSigningEnabled, Boolean isGlobalTemplate) {

            this.templateId = templateId;
            this.templateKey = templateKey;
            this.urlParamSettingsId = urlParamSettingsId;
            this.letterTitle = letterTitle;
            this.letterCategory = letterCategory; 
            this.isLiveEditable = isLiveEditable;
            this.isESigningEnabled = isESigningEnabled;
            this.isInPersonSigningEnabled = isInPersonSigningEnabled;
            this.isGlobalTemplate = isGlobalTemplate;
        }
    }

    public class GetCongaLettersResult {
        @AuraEnabled
        public Map<String, List<CongaLetterTemplateBaseService.CongaLetterTemplate>> result;

        public GetCongaLettersResult(List<CongaLetterTemplate> congaLetterTemplates) {
            this.result = createResult(congaLetterTemplates);
        }

        Map<String, List<CongaLetterTemplate>> createResult(List<CongaLetterTemplate> settings) {
            Map<String, List<CongaLetterTemplate>> letterTemplates = new Map<String, List<CongaLetterTemplate>>();
            if (!settings.isEmpty()) {           
                for(CongaLetterTemplate setting : settings) {
                    String category = String.isNotBlank(setting.letterCategory) ? setting.letterCategory : GLOBAL_CATEGORY;
                    if (!letterTemplates.containsKey(category)) {
                        letterTemplates.put(category, new List<CongaLetterTemplate>());
                    }
                    letterTemplates.get(category).add(setting);
                }
            } 
            return letterTemplates;
        }
    }

}