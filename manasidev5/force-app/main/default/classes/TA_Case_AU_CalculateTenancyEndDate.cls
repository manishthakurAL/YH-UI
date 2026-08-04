public without sharing class TA_Case_AU_CalculateTenancyEndDate implements TriggerAction.AfterInsert,TriggerAction.AfterUpdate { 
    
    public static void afterInsert(List<Case> newList) {
        Map<Id, Case> newMap = new Map<Id,Case>(newList);
        List<Id> tenancyIds = new List<Id>();
        List<Case> cases = new List<Case>();
        for(Case acase: newMap.values()){
            if(acase.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_TERMINATION   
                && ( acase.TerminationNoticeReceived__c != null 
                && (acase.Origin == CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL || acase.Origin == CaseDecorator.CASE_ORIGIN_GUEST_PORTAL ))
                && !acase.IsClosed && !acase.IsFullConsentForTerminationNotGive__c 
                && acase.Tenancy__c != null
            ){
                tenancyIds.add(acase.Tenancy__c);
                cases.add(acase);
            }
        }
        if(!tenancyIds.isEmpty()){
            calculateTenancyEndDate(tenancyIds, cases);
        }
    }
    
    public static void afterUpdate(List<Case> newList, List<Case> oldList) {
        Map<Id, Case> newMap = new Map<Id,Case>(newList);
        Map<Id, Case> oldMap = new Map<Id,Case>(oldList);
        List<Id> tenancyIds = new List<Id>();
        List<Case> cases = new List<Case>();
        for(Case acase: newMap.values()){
            if(acase.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_TERMINATION  && acase.tenancy__c != null
                && ( acase.TerminationNoticeReceived__c != null 
                    && (
                        acase.TerminationNoticeReceived__c != oldMap.get(acase.Id).TerminationNoticeReceived__c
                        || acase.tenancy__c != oldMap.get(acase.Id).tenancy__c
                    )
                )
                &&  !acase.IsClosed && !acase.IsFullConsentForTerminationNotGive__c 

            ){
                tenancyIds.add(acase.Tenancy__c);
                cases.add(acase);
            }
        }
        calculateTenancyEndDate(tenancyIds, cases);
    }

    private static void calculateTenancyEndDate(List<Id> tenancyIds, List<Case> cases){
         Map<Id, YH_Tenancy__c> tenancies = new Map<Id, YH_Tenancy__c>(
            [SELECT Id, Name, FixedTermEndDate__c, HousingPurposeFormula__c, ProductType__c, RentType__c, StartDate__c
                       FROM YH_Tenancy__c WHERE Id in :tenancyIds]);
        
        TenancyService service = new TenancyService();
        for(Case acase: cases){
            YH_Tenancy__c atenancy = tenancies.get(acase.Tenancy__c);
            atenancy.TenancyEndDate__c = service.calculateTenancyEndDate(tenancies.get(acase.Tenancy__c), acase.TerminationNoticeReceived__c);     
            atenancy.PrimaryReasonForLeaving__c = acase.PrimaryReasonForLeaving__c;
            atenancy.OtherDetailsPrimaryReason__c = acase.OtherDetailsPrimaryReason__c;
            atenancy.AdditionalReasonForLeaving__c = acase.AdditionalReasonForLeaving__c;
        }
        MetadataTriggerHandler.bypass(TA_Tenancy_BU_RequireReasonEndDateChange.class.getName());
        update tenancies.values();
        MetadataTriggerHandler.clearBypass(TA_Tenancy_BU_RequireReasonEndDateChange.class.getName());
    }
}