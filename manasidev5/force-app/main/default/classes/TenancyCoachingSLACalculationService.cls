public with sharing class TenancyCoachingSLACalculationService {
    
    public static void calculateSLADates(List<Case> casesList, Map<Id, Case> oldCasesMap) {
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Map<Id, Case> casesMap = new Map<Id, Case>();
        Set<Id> tenancyCoachingCaseIds = new Set<Id>();
        for (Case caseRecord : casesList) { 
            if (caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_TENANCY_COACHING) {
                tenancyCoachingCaseIds.add(caseRecord.Id);
            }
        }
        if (oldCasesMap != null && !tenancyCoachingCaseIds.isEmpty()) {
            casesMap = new Map<Id, Case>([SELECT Id, (SELECT Id FROM CaseMilestones WHERE MilestoneType.Name =: CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT LIMIT 1) 
                FROM Case WHERE Id IN: tenancyCoachingCaseIds]);
        }
        
        for (Case caseRecord : casesList) {
            if (caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_TENANCY_COACHING) {
                Set<String> runMilestonesForList = !String.isBlank(caseRecord.RunMilestonesFor__c) ? new Set<String>(caseRecord.RunMilestonesFor__c.split(';')) : new Set<String>();
                

                if (caseRecord.Status ==  CaseDecorator.STATUS_NEW  && !String.isBlank(caseRecord.Priority) && (casesMap.isEmpty() 
                    && (caseRecord.Priority == CaseDecorator.PRIORITY_URGENT || caseRecord.Priority == CaseDecorator.PRIORITY_ROUTINE)
                    && (oldCasesMap == null || (oldCasesMap != null && (caseRecord.Priority != oldCasesMap.get(caseRecord.Id).Priority)))
                    || (!casesMap.isEmpty() && casesMap.containsKey(caseRecord.Id) && casesMap.get(caseRecord.Id).CaseMilestones.isEmpty())))  {

                    caseRecord.SLAStartDate__c = businessHourService.getNextBusinessDay(System.now(),null);
                    caseRecord.SLAEndDate__c = businessHourService.calculateTargetDate(
                        caseRecord.Priority == CaseDecorator.PRIORITY_URGENT ? CaseDecorator.TENANCY_COACHING_CASE_URGENT_PRIORITY_DAYS : CaseDecorator.TENANCY_COACHING_CASE_ROUTINE_PRIORITY_DAYS,
                        caseRecord.SLAStartDate__c
                    );
                    runMilestonesForList.add(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT);
                }

                if (caseRecord.Status == CaseDecorator.STATUS_TRIAGE && oldCasesMap != null
                        && caseRecord.Status != oldCasesMap.get(caseRecord.Id).Status)  {
                    caseRecord.SLAStartDate__c = businessHourService.getNextBusinessDay(System.now(),null);
                    DateTime defaultTargetDateTime = businessHourService.calculateTargetDate(
                        CaseDecorator.TENANCY_COACHING_CASE_RESOLUTION_DAYS,
                        caseRecord.SLAStartDate__c
                    );
                    caseRecord.ResolutionTargetDate__c = caseRecord.ResolutionTargetDate__c == null ? Date.valueOf(defaultTargetDateTime) : caseRecord.ResolutionTargetDate__c;
                    runMilestonesForList.remove(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT);
                    runMilestonesForList.add(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION);
                }

                if (oldCasesMap != null && caseRecord.CompletedMilestones__c != oldCasesMap.get(caseRecord.Id).CompletedMilestones__c 
                        && (caseRecord.CompletedMilestones__c == CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT 
                            || caseRecord.CompletedMilestones__c == CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT))  {
                    if(caseRecord.CompletedMilestones__c == CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT){
                        caseRecord.SLAStartDate__c = businessHourService.getNextBusinessDay(System.now(),null);
                    }
                    runMilestonesForList.add(CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT);
                }

                if (!runMilestonesForList.isEmpty()) {
                    caseRecord.RunMilestonesFor__c = String.join(new List<String>(runMilestonesForList),';');
                }
            }
        }
    }
}