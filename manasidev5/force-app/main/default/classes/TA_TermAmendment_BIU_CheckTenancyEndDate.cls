public without sharing class TA_TermAmendment_BIU_CheckTenancyEndDate  implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate  {
    public static void beforeInsert(List<TerminationAmendment__c> newList) {
        validateAmendedTenancyEndDate(newList, null);
    }

    public static void beforeUpdate(List<TerminationAmendment__c> newList, List<TerminationAmendment__c> oldList) {
        Map<Id, TerminationAmendment__c> newMap = new Map<Id, TerminationAmendment__c>(newList);
        Map<Id, TerminationAmendment__c> oldMap = new Map<Id, TerminationAmendment__c>(oldList);
        validateAmendedTenancyEndDate(newList, oldMap);     
    }

    private static void validateAmendedTenancyEndDate(List<TerminationAmendment__c> newList, Map<Id, TerminationAmendment__c> oldMap){
        List<Id>caseIds = new List<Id>();
        List<TerminationAmendment__c> updatedAmendments = new List<TerminationAmendment__c>();
        for(TerminationAmendment__c amendment: newList){
            if(amendment.AmendedTenancyEndDate__c != null && 
                        (oldMap == null || amendment.AmendedTenancyEndDate__c != oldMap.get(amendment.Id).AmendedTenancyEndDate__c)
                                    && amendment.TypeOfAmendment__c == TerminationAmendmentDecorator.TYPE_CHANGE_TENANCY_END_DATE){
                            caseIds.add(amendment.Case__c);
                            updatedAmendments.add(amendment);
            }
        }
        Map<Id, Case> terminationCases =  new Map<Id,Case>([SELECT Id, CreatedDate, TerminationNoticeReceived__c, Tenancy__c
                FROM Case WHERE Id in: caseIds AND isClosed = false 
            AND RecordTypeId = :CaseDecorator.RECORD_TYPE_ID_TERMINATION]);
        List<Id> tenancyIds = new List<Id>();
        for(Case acase: terminationCases.values()){
            tenancyIds.add(acase.Tenancy__c);
        }

        Map<Id, YH_Tenancy__c> tenancyWithProperyInfo = new Map<Id, YH_Tenancy__c>([SELECT Id, Name, TenancyEndDate__c, StartDate__c, ReasonTenancyEndDateChanged__c,
            FixedTermEndDate__c,  PrimaryReasonForLeaving__c, HousingPurposeFormula__c, RentType__c, ProductType__c  FROM YH_Tenancy__c where Id in: tenancyIds
        ]);
        TenancyService service = new TenancyService();
        for (TerminationAmendment__c amendment : updatedAmendments) {
            TenancyService.Result result  = service.validateEndDate(tenancyWithProperyInfo.get(terminationCases.get(amendment.Case__c).Tenancy__c), tenancyWithProperyInfo.get(terminationCases.get(amendment.Case__c).Tenancy__c).TenancyEndDate__c,
            amendment.AmendedTenancyEndDate__c,
            amendment.ReasonTenancyEndDateChanged__c, 
                        terminationCases.get(amendment.Case__c).TerminationNoticeReceived__c,
                        amendment.OriginOfAmendmentRequest__c);
            if( result!= null && result.isSuccessful == false){
                amendment.addError(result.message); 
            }
        }
    }    
}