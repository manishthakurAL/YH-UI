public with sharing class CongaLetterTemplateServiceFactory {

    public static CongaLetterTemplateBaseService createService(String recordId) {
        String type = SObjectUtils.getSObjectTypeFromId(recordId);
        switch on type {
            when 'YH_Mutual_Exchange__c' {
                return new MEXCongaLetterTemplateService(recordId);
            }
            when 'YH_Application__c' {
                return new ApplicationCongaLetterTemplateService(recordId);
            }
            when 'Case' {
                return new CaseCongaLetterTemplateService(recordId);
            }
            when else {                
                throw new IllegalArgumentException('Conga Letter is not supported for the SObject Type ' + type);
            }
        }
    }
}