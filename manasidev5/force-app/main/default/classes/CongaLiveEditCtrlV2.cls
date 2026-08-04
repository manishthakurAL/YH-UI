public with sharing class CongaLiveEditCtrlV2 {

    @AuraEnabled
    public static CongaLetterTemplateBaseService.GetCongaLettersResult getCongaLetters(Id recordId) {
        try {
            return CongaLetterTemplateServiceFactory.createService(recordId).getCongaLetters();
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage() + '\n' +  ex.getCause() + '\n' + ex.getStackTraceString());
        }   
    }

    @AuraEnabled
    public static String getCongaUrl(Id recordId, Id urlParamSettingsId, String actionType) {
        try {
            return CongaLetterTemplateServiceFactory.createService(recordId).getCongaUrl(urlParamSettingsId, actionType);
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        } 
    }

    @AuraEnabled(cacheable=true)
    public static String getLetterDraftContent(String recordId, String templateKey) {
        try {
            return CongaLetterTemplateServiceFactory.createService(recordId).getLetterDraftContent(templateKey);
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        } 
    }

    @AuraEnabled
    public static void saveLetterDraftContent(String recordId, String templateKey, String letterContent) {
        try {
            CongaLetterTemplateServiceFactory.createService(recordId).saveLetterDraftContent(templateKey, letterContent);
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        } 
    }

    @AuraEnabled
    public static void saveLetterContent(String recordId, String templateKey, String letterContent) {
        try {
            CongaLetterTemplateServiceFactory.createService(recordId).saveLetterContent(templateKey, letterContent);
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        } 
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
}