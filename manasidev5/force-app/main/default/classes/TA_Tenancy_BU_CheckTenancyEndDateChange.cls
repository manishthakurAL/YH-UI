public with sharing class TA_Tenancy_BU_CheckTenancyEndDateChange  implements TriggerAction.BeforeUpdate { 

    public static void beforeUpdate(List<YH_Tenancy__c> newList, List<YH_Tenancy__c> oldList) {
        TenancyService service = new TenancyService();
        Map<Id,YH_Tenancy__c> newMap = new Map<Id, YH_Tenancy__c>(newList);
        List<YH_Tenancy__c> tenancyEndDateUpdatedTenancies= new List<YH_Tenancy__c>();
        Map<Id,YH_Tenancy__c> oldMap = new Map<Id,YH_Tenancy__c>(oldList);
        for (YH_Tenancy__c tenancy : newList) {
            YH_Tenancy__c oldRecord = oldMap.get(tenancy.Id); 
            if (tenancy.PrimaryReasonForLeaving__c != TenancyDecorator.PRIMARY_REASON_FOR_LEAVING_MUTUAL_EXCHANGE && 
                    tenancy.TenancyEndDate__c != null &&  ( oldRecord.TenancyEndDate__c != tenancy.TenancyEndDate__c )) {
                tenancyEndDateUpdatedTenancies.add(tenancy);
            }    
        }

        if( !tenancyEndDateUpdatedTenancies.isEmpty() ){
            List<Case> terminationCase =  [SELECT Id, CreatedDate, TerminationNoticeReceived__c,  Tenancy__c FROM Case WHERE Tenancy__c in: tenancyEndDateUpdatedTenancies AND isClosed = false 
            AND RecordTypeId = :CaseDecorator.RECORD_TYPE_ID_TERMINATION];
            Map<Id, Date> terminationCaseCreatedDatebytenancyId = new Map<Id, Date>();
            for(Case acase: terminationCase){
                terminationCaseCreatedDatebytenancyId.put(acase.Tenancy__c, acase.TerminationNoticeReceived__c);
            }
            for (YH_Tenancy__c tenancy : tenancyEndDateUpdatedTenancies) {
                TenancyService.Result result  = service.validateEndDate(tenancy,  oldMap.get(tenancy.Id).TenancyEndDate__c, newMap.get(tenancy.Id).TenancyEndDate__c, newMap.get(tenancy.Id).ReasonTenancyEndDateChanged__c, 
                                terminationCaseCreatedDatebytenancyId.get(tenancy.Id), null);
                if( result != null && result.isSuccessful == false){
                    newMap.get(tenancy.Id).addError(result.message); 
                }
            }
        }
        
    }
}