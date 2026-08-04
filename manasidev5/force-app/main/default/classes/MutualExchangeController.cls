public with sharing class MutualExchangeController {
    private static final String COUNTRY_CODE_GB = 'GB';
    
    @AuraEnabled(cacheable=true)
    public static SObject[] getPropertyMembers(String propertyId) {
        return [SELECT Contact__c,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.MobilePhone, Type__c,Tenancy__r.YH_AgreementType__c 
                  FROM Member__c
                 WHERE Tenancy__r.Property__c =: propertyId 
                       AND ( Type__c =: MemberDecorator.TYPE_SOLO OR Type__c =: MemberDecorator.TYPE_JOINT ) 
                       AND IsActive__c = true];
    }

    @AuraEnabled
    public static void saveMutualExchanges(String caseId, String data){
        try {
            List<MEXWrapper> mexList = (List<MEXWrapper>) JSON.deserialize(data, List<MEXWrapper>.class);
            List<YH_Mutual_Exchange__c> newMEXList = new List<YH_Mutual_Exchange__c>();
            List<MutualExchangeApplicant__c> newApplicantList = new List<MutualExchangeApplicant__c>();
            for(MEXWrapper mex : mexList){
                YH_Mutual_Exchange__c newMEX = new YH_Mutual_Exchange__c(
                    Case__c = caseId,
                    PropertyType__c = mex.property.propertyType,
                    InternalProperty__c = mex.property.propertyId,
                    ExternalAddress2__Street__s = (mex.property.propertyType == PropertyDecorator.PROPERTY_TYPE_EXTERNAL) ? mex.property.propertyStreet : '',
                    ExternalAddress2__City__s = (mex.property.propertyType == PropertyDecorator.PROPERTY_TYPE_EXTERNAL) ? mex.property.propertyCity : '',
                    ExternalAddress2__PostalCode__s = (mex.property.propertyType == PropertyDecorator.PROPERTY_TYPE_EXTERNAL) ? mex.property.propertyPostalCode : '',
                    ExternalAddress2__CountryCode__s = COUNTRY_CODE_GB,
                    ExternalLandlord__c = mex.property.propertyLandlord             
                );
                newMEXList.add(newMEX);
                for (ApplicantWrapper app : mex.applicants) {
                    MutualExchangeApplicant__c newApp = new MutualExchangeApplicant__c(
                        RelatedContact__c = app.applicantId,
                        TenantType__c = app.tenantType,
                        RelatedMutualExchange__r = newMEX
                        
                    );
                    newApplicantList.add(newApp);
                }
            }
            insert newMEXList;
            for (MutualExchangeApplicant__c app : newApplicantList) {
                app.RelatedMutualExchange__c = app.RelatedMutualExchange__r.Id;
            }
            insert newApplicantList;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class MEXWrapper {
        @AuraEnabled public PropertyWrapper property{get;set;}
        @AuraEnabled public List<ApplicantWrapper> applicants{get;set;}

        public MEXWrapper(PropertyWrapper property, List<ApplicantWrapper> applicants) {
            this.property = property;
            this.applicants = applicants;
        }
    }

    public class PropertyWrapper {
        @AuraEnabled public String propertyId{get;set;}
        @AuraEnabled public String propertyType{get;set;}
        @AuraEnabled public String propertyStreet{get;set;}
        @AuraEnabled public String propertyCity{get;set;}
        @AuraEnabled public String propertyPostalCode{get;set;}
        @AuraEnabled public String propertyCountry{get;set;} 
        @AuraEnabled public String propertyLandlord{get;set;}

        public PropertyWrapper() {}

        public PropertyWrapper(String jsonParams) {
            PropertyWrapper params = (PropertyWrapper) JSON.deserialize(jsonParams, PropertyWrapper.class);
            this.propertyId = params.propertyId;
            this.propertyType = params.propertyType;
            this.propertyStreet = params.propertyStreet;
            this.propertyCity = params.propertyCity;
            this.propertyPostalCode = params.propertyPostalCode;
            this.propertyCountry = params.propertyCountry;
            this.propertyLandlord = params.propertyLandlord;
        }
    }

    public class ApplicantWrapper {
        @AuraEnabled public String applicantId{get;set;}
        @AuraEnabled public String tenantType{get;set;}

        public ApplicantWrapper() {}

        public ApplicantWrapper(String jsonParams) {
            ApplicantWrapper params = (ApplicantWrapper) JSON.deserialize(jsonParams, ApplicantWrapper.class);
            this.applicantId = params.applicantId;
            this.tenantType = params.tenantType;
        }
    }
}