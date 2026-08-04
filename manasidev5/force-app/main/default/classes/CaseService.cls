public with sharing class CaseService {
    public static final String ERROR_MESSAGE  = 'Only admin user are allowed to set Origin as System';
    public static void createSchemeCases(Set<Id> tenancyId) {
        if(!tenancyId.isEmpty()){
            List<Case> casesToInsert = new List<Case>();
            Database.DMLOptions dmlOption = new Database.DMLOptions();
            dmlOption.assignmentRuleHeader.useDefaultRule = true;
            
            List<YH_Tenancy__c> tenancies = [SELECT Id, Property__c,
                (SELECT  Id, Type__c, Contact__r.Account.Id, Contact__c 
                    FROM Member__r
                    WHERE Type__c IN: MemberDecorator.MONITORING_FORM_APPLICABLE_TYPE)
                FROM YH_Tenancy__c
                WHERE Id IN: tenancyId];

            if(!tenancies.isEmpty()){
                for(YH_Tenancy__c tenancy : tenancies){
                    if(tenancy.Member__r != null && !tenancy.Member__r.isEmpty()){
                        for(Member__c member : tenancy.Member__r){
                            Case caseMonitoringFormRecord = CaseSchemesService.getCaseRecord(tenancy, member, CaseDecorator.TYPE_MONITORING_FORM, CaseDecorator.SUBJECT_MONITORING_FORM);
                            caseMonitoringFormRecord.setOptions(dmlOption);
                            casesToInsert.add(caseMonitoringFormRecord);
                            Case caseIndependencePlanRecord = CaseSchemesService.getCaseRecord(tenancy, member, CaseDecorator.TYPE_INDEPENDENCE_PLAN, CaseDecorator.SUBJECT_INDEPENDENCE_PLAN);
                            caseIndependencePlanRecord.setOptions(dmlOption);
                            casesToInsert.add(caseIndependencePlanRecord);
                        }
                    }
                }
            }

            if(!casesToInsert.isEmpty()){
                insert casesToInsert;
            }
        }
    }

    public void checkSystemOriginValidation(List<Case> cases){
        List<Profile> aprofiles = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
        Boolean isadmin = false;
        if( aprofiles!= null && !aprofiles.isEmpty() && aprofiles[0].Name == UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR){
            isadmin = true;
        }
        
        for(Case acase: cases){
            if(acase.Origin == CaseDecorator.ORIGIN_SYSTEM && !isadmin){
                acase.addError(CaseService.ERROR_MESSAGE);
            }
        }
    }

    public CaseShare buildCaseShareWithManualSharing(Id recordId, Id userId, String accessLevel, String rowCause){
        CaseShare share = new CaseShare();
        share.CaseId = recordId;
        share.UserOrGroupId = userId;
        share.CaseAccessLevel = accessLevel;
        share.RowCause = rowCause;
        return share;
    }

    public List<Case> getCaseAndTenancyDetails(Id recordId){
        List<Case> cases = new List<Case>();
        if(recordId != null){
            cases = [SELECT Id, Tenancy__c, Tenancy__r.PropertyAddress__c, Tenancy__r.Active__c,
                        Tenancy__r.YH_TenancyNumber__c, Tenancy__r.OrchardPropertyReferenceNumber__c
                    FROM Case
                        WHERE Id =: recordId];
        }
        return cases;
    }
}