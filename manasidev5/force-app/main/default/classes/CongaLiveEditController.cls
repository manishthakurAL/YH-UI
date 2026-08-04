public with sharing class CongaLiveEditController {

    private static final String SELECT_ALL_CASE_FLDS_SOQL = 'SELECT {0} FROM CASE WHERE Id = :recordId LIMIT 1';
    @testVisible
    private static final String UNCATEGORIZED_CATEGORY = 'Uncategorized';
    private static final String FLD_DEVELOPER_NAME = 'RecordType.DeveloperName';

    @AuraEnabled
    public static CaseCongaSetting getCongaSettings(Id recordId) {
        CaseCongaSetting caseCongaSetting = null;
        try{
            if(recordId != null){
                List<String> caseQueryFields = new List<String>(Case.sObjectType.getDescribe().fields.getMap().keySet());
                caseQueryFields.add(FLD_DEVELOPER_NAME);

                String selectQuery = String.format(SELECT_ALL_CASE_FLDS_SOQL, new List<String>{
                    String.join(caseQueryFields, ', ')
                });

                Case casesRecord = (Case) Database.query(selectQuery)[0];
                ICongaLiveEditHandler handler = CongaLiveEditHandlerFactory.getCongaLiveEditHandler(recordId);
                List<CaseCongaSetting__mdt> settings = handler.getCongaSettings(recordId);
                List<CaseCongaSetting__mdt> defaultSettings = handler.getDefaultTemplates();
                caseCongaSetting = new CaseCongaSetting(settings, defaultSettings, casesRecord);
            }
        }catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }   
        return caseCongaSetting;
    }

    @AuraEnabled
    public static String getCongaUrl(Id recordId, Id congaSettingId, String actionType) {
        String congaUrl = '';
        try{
            if(recordId != null){
                congaUrl = CongaLiveEditHandlerFactory.getCongaLiveEditHandler(recordId).getCongaUrl(recordId, congaSettingId, actionType);
            }
        }catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage() + '\n' +  ex.getCause() );
        }   
        return congaUrl;
    }

    @AuraEnabled(cacheable=true)
    public static SObject getCongaTemplateByKey(String templateKey) {
        return [
            SELECT Id, APXTConga4__Key__c, LetterContent__c
            FROM APXTConga4__Conga_Template__c
            WHERE APXTConga4__Key__c =: templateKey
            LIMIT 1
        ];
    }

    @AuraEnabled(cacheable=true)
    public static String getLetterDraftContent(String caseId, String templateKey) {
        String letterContent;
        CaseCongaTemplateDynamicContent__c[] tempContents = [
            SELECT LetterContent__c
            FROM CaseCongaTemplateDynamicContent__c 
            WHERE Case__c =: caseId AND 
            TemplateKey__c =: templateKey
            ORDER BY CreatedDate DESC
        ];

        if (!tempContents.isEmpty()) {
            letterContent = tempContents[0].LetterContent__c;
        }
        return letterContent;
    }

    @AuraEnabled
    public static void saveLetterDraftContent(String caseId, String templateKey, String letterContent) {
        try {
            CaseCongaTemplateDynamicContent__c draftContent = new CaseCongaTemplateDynamicContent__c(
                LetterContent__c = letterContent,
                Case__c = caseId,
                TemplateKey__c = templateKey,
                CaseTemplatePair__c = caseId + templateKey
            );

            upsert draftContent CaseTemplatePair__c;

        }catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage() + '\n' +  ex.getCause() );
        }   
    }

    @AuraEnabled
    public static void saveCase(String caseId, String templateKey, String letterContent) {
        try {
            TriggerBase.bypass('Case');
            saveLetterDraftContent(caseId, templateKey, letterContent);
            Case caseRecord = new Case(Id =caseId, LetterContent__c = letterContent);
            update caseRecord;
            TriggerBase.clearBypass('Case');
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage() + '\n' +  ex.getCause());
        }
    }
    
    public class CaseCongaSetting{
        @AuraEnabled
        public Map<String, List<CaseCongaSetting__mdt>> letterTemplates;
        @AuraEnabled
        public Case caseRecord;

        public CaseCongaSetting(List<CaseCongaSetting__mdt> settings,  List<CaseCongaSetting__mdt> defaultSettings, Case caseRecord) {
            this.letterTemplates = getSettingsMapper(settings, defaultSettings);
            this.caseRecord = caseRecord;
        }

        Map<String, List<CaseCongaSetting__mdt>> getSettingsMapper(List<CaseCongaSetting__mdt> settings, List<CaseCongaSetting__mdt> defaultSettings) {
            Map<String, List<CaseCongaSetting__mdt>> letterTemplates = new Map<String, List<CaseCongaSetting__mdt>>();
            if (!settings.isEmpty()) {           
                for(CaseCongaSetting__mdt setting : settings) {
                    String category = String.isNotBlank(setting.Category__c) ? setting.Category__c : UNCATEGORIZED_CATEGORY;
                    if (!letterTemplates.containsKey(category)) {
                        letterTemplates.put(category, new List<CaseCongaSetting__mdt>(defaultSettings));
                    }
                    letterTemplates.get(category).add(setting);
                }
            } else {
                letterTemplates.put(UNCATEGORIZED_CATEGORY, new List<CaseCongaSetting__mdt>(defaultSettings));
            }
            return letterTemplates;
        }
        
    }
}