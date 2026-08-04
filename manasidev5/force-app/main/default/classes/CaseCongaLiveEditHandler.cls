public with sharing class CaseCongaLiveEditHandler implements ICongaLiveEditHandler{


    public List<CaseCongaSetting__mdt> getCongaSettings(Id recordId) {
        List<CaseCongaSetting__mdt> recordsList;
        List<Case> casesList = [
            SELECT  Id, Type, CaseType__c, Status, RecordTypeId, RecordType.DeveloperName,
                    Tenancy__r.Property__r.YH_HousingPurpose__c,Tenancy__r.Property__r.YH_RentType__c,Tenancy__r.Property__r.YH_ProductType__c,
                    Property__r.YH_HousingPurpose__c,Property__r.YH_RentType__c,Property__r.YH_ProductType__c,
                    OwnerId 
            FROM    Case 
            WHERE   Id =: recordId 
            LIMIT   1];

        if (String.valueOf(casesList[0].OwnerId).startsWithIgnoreCase('00G')) {
            throw new CaseCongaLiveEditHandlerException('To use the compose letter feature, the case must be assigned to a user.');
        }
        recordsList = [
            SELECT  Id, LetterType__c ,Category__c, LiveEditable__c, EnableInPersonSigning__c,
                    CongaDocumentGenerationSetting__r.TemplateId__c, EnableESign__c
            FROM    CaseCongaSetting__mdt 
            WHERE   RecordTypeAPIName__c =: casesList[0].RecordType.DeveloperName  
                    AND  (CaseType__c =:  casesList[0].CaseType__c OR CaseType__c = null)
                    AND  (CaseStatus__c =: casesList[0].Status OR CaseStatus__c = null)
                    AND(   
                        (
                            (HousingPurpose__c = :casesList[0].Property__r.YH_HousingPurpose__c OR HousingPurpose__c = NULL)
                            AND  (RentType__c = :casesList[0].Property__r.YH_RentType__c OR RentType__c = NULL)
                            AND  (ProductType__c = :casesList[0].Property__r.YH_ProductType__c OR ProductType__c = NULL)
                        )
                        OR
                        (
                            (HousingPurpose__c = :casesList[0].Tenancy__r.Property__r.YH_HousingPurpose__c OR HousingPurpose__c = NULL)
                            AND  (RentType__c = :casesList[0].Tenancy__r.Property__r.YH_RentType__c OR RentType__c = NULL)
                            AND  (ProductType__c = :casesList[0].Tenancy__r.Property__r.YH_ProductType__c OR ProductType__c = NULL)
                        )
                    
                    )
            ORDER BY Category__c desc, TemplateSortOrder__c asc, LetterType__c asc];
        return recordsList;
    } 

    public List<CaseCongaSetting__mdt> getDefaultTemplates() {
        return [SELECT  Id, LetterType__c ,Category__c, LiveEditable__c, EnableInPersonSigning__c,
                        CongaDocumentGenerationSetting__r.TemplateId__c, EnableESign__c
                FROM    CaseCongaSetting__mdt 
                WHERE   DefaultTemplate__c = true AND LiveEditable__c = true
                ORDER BY LetterType__c asc];
    }

    public String getCongaUrl(Id recordId, Id caseCongaSettingId, String actionType) {

        CaseCongaSetting__mdt settings = CaseCongaSetting__mdt.getInstance(caseCongaSettingId);
        return CongaService.get().getCongaUrl(
            recordId, 
            settings.CongaDocumentGenerationSetting__r.DeveloperName, 
            CongaService.ActionType.valueOf(actionType)
            );
    }

    public class CaseCongaLiveEditHandlerException extends Exception {

    }
}