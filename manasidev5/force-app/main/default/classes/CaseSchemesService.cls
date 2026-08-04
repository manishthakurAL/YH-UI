public with sharing class CaseSchemesService {
    public static void processCaseForSchemes(Set<Id> caseIds) {
        Set<Id> tenancyId = new Set<Id>();

        if (!caseIds.isEmpty()) {
            tenancyId = getHousingForOldPeopleTenancyIds(caseIds);
        }

        if(!tenancyId.isEmpty()){
            CaseService.createSchemeCases(tenancyId);
        }
    }

    public static Set<Id> getHousingForOldPeopleTenancyIds(Set<Id> ids){
        Set<Id> tenancyId = new Set<Id>();
        for(Case cse : [SELECT 
                Id, Tenancy__c
                FROM Case
                WHERE Id IN: ids
                    AND Tenancy__r.Property__r.YH_HousingPurpose__c =: PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
                    AND Tenancy__r.Active__c = true]){
            tenancyId.add(cse.Tenancy__c);
        }
        return tenancyId;
    }

    public static Case getCaseRecord(YH_Tenancy__c tenancy, Member__c member, String caseType, String subject){
        Case caseRecord = new Case();
        caseRecord.Tenancy__c = tenancy.Id;
        caseRecord.Property__c = tenancy.Property__c;
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_SCHEMES;
        caseRecord.RecordType__c = CaseDecorator.TYPE_SCHEMES;
        caseRecord.CaseType__c = caseType;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Subject = subject;
        caseRecord.ContactId = member.Contact__c;
        caseRecord.AccountId = member.Contact__r.Account.Id;
        return caseRecord;
    }
}