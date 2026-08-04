public with sharing class CaseSLACalculationService {

    private static final Set<Id> recordTypesToProcess = new Set<Id>{
        CaseDecorator.RECORD_TYPE_ID_TENANCY,
        CaseDecorator.RECORD_TYPE_ID_PLACE,
        CaseDecorator.RECORD_TYPE_ID_PERMISSION,
        CaseDecorator.RECORD_TYPE_ID_CHANGES
    };

    private DateTime startDateTime;

    public CaseSLACalculationService(){
        this.startDateTime = System.now();
    }
    
    @TestVisible
    private CaseSLACalculationService(DateTime startDateTime){
        this.startDateTime = startDateTime;
    }
    
    public void calculateSLADates(List<Case> casesList, Map<Id, Case> oldCasesMap) {
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Map<Id, Case> casesMap = new Map<Id, Case>();
        Set<Id> caseIds = new Set<Id>();
        for (Case caseRecord : casesList) { 
            if (recordTypesToProcess.contains(caseRecord.RecordTypeId)) {
                caseIds.add(caseRecord.Id);
            }
        }
        if (oldCasesMap != null && !caseIds.isEmpty()) {
            casesMap = new Map<Id, Case>([SELECT Id, (SELECT Id FROM CaseMilestones WHERE MilestoneType.Name =: CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT LIMIT 1) 
                FROM Case WHERE Id IN: caseIds]);
        }
        
        for (Case caseRecord : casesList) {
            if (recordTypesToProcess.contains(caseRecord.RecordTypeId)) {
                Set<String> runMilestonesForList = !String.isBlank(caseRecord.RunMilestonesFor__c) ? new Set<String>(caseRecord.RunMilestonesFor__c.split(';')) : new Set<String>();
                if (oldCasesMap == null && caseRecord.Status ==  CaseDecorator.STATUS_NEW)  {
                    caseRecord.SLAStartDate__c = businessHourService.getNextBusinessDay(this.startDateTime,null);
                    if(caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_MUTUAL_EXCHANGE){
                        runMilestonesForList.add(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION);
                        caseRecord.SLAEndDate__c = businessHourService.calculateTargetDate(
                            CaseDecorator.CASE_MUTUALEXCHANGE_RESOLUTION_DAYS,
                            caseRecord.SLAStartDate__c);
                        runMilestonesForList.add(CaseMilestoneDecorator.CASE_MILESTONE_MUTUALEXCHANGEDECISION);
                        BusinessHourService bshCalendarDays = new BusinessHourService(BusinessHourDecorator.SEVEN_DAYS_NO_HOLIDAY_BUSINESS_HOUR);
                        
                        caseRecord.MutualExchangeDecisionSLAEndDate__c = bshCalendarDays.calculateTargetDate(
                            CaseDecorator.CASE_MUTUALEXCHANGE_DECISION_DAYS,
                            caseRecord.SLAStartDate__c);
                    }
                    if (caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_PERMISSION_FOR_A_LoDGER_OR_SUBLET
                        || caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_PERMISSION_FOR_CARAVAN_MOTORHOME_BOAT
                        || caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_PERMISSION_FOR_MOBILITY_SCOOTER
                        || caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_PERMISSION_FOR_PET_ANIMAL
                        || caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_PERMISSION_TO_RUN_A_BUSINESS_FROM_HOME) {
                        caseRecord.SLAEndDate__c = businessHourService.calculateTargetDate(
                            CaseDecorator.PERMISSION_CASE_RESOLUTION_DAYS,
                            caseRecord.SLAStartDate__c
                        );
                        runMilestonesForList.add(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION);
                    }
                    if (caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_PERMISSION_DISABLED_PARKING) {
                        caseRecord.SLAEndDate__c = businessHourService.calculateTargetDate(
                            CaseDecorator.DISABLED_PARKING_PERMISSION_CASE_60_RESOLUTION_DAYS,
                            caseRecord.SLAStartDate__c
                        );
                        runMilestonesForList.add(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION);
                    }
                    if (caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_UNAUTHORISED_OCCUPIER) {
                        caseRecord.SLAEndDate__c = businessHourService.calculateTargetDate(
                            CaseDecorator.TENANCY_CASE_60_RESOLUTION_DAYS,
                            caseRecord.SLAStartDate__c
                        );
                        runMilestonesForList.add(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION);
                    }

                    if (caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_SURVIVOR ||
                    caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_SOLE_TO_JOINT ||
                    caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_JOINT_TO_SOLE) {	
                        caseRecord.SLAEndDate__c = businessHourService.calculateTargetDate(
                            CaseDecorator.RESOLUTION_20_DAYS,
                            caseRecord.SLAStartDate__c
                        );
                        runMilestonesForList.add(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION);	  
                    }

                    if (caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_NO_SUCCESSOR ||
                    caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_SUCCESSOR ) {	
                        caseRecord.SLAEndDate__c = businessHourService.calculateTargetDate(
                            CaseDecorator.RESOLUTION_40_DAYS,
                            caseRecord.SLAStartDate__c
                        );
                        runMilestonesForList.add(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION);	  
                    }
                    runMilestonesForList.add(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT);
                }

                if (oldCasesMap != null && caseRecord.CompletedMilestones__c != oldCasesMap.get(caseRecord.Id).CompletedMilestones__c 
                    && (caseRecord.CompletedMilestones__c == CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT 
                        || caseRecord.CompletedMilestones__c == CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT))  {
                    caseRecord.SLAStartDate__c = businessHourService.getNextBusinessDay(this.startDateTime,null);
                    runMilestonesForList.add(CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT);
                    if (caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_TENANCY) {
                        if (caseRecord.CaseType__c == CaseDecorator.CASETYPE_DECANT) {
                            caseRecord.SLAEndDate__c = businessHourService.calculateTargetDate(
                                CaseDecorator.CUSTOMER_CONTACT_5_DAYS,
                                caseRecord.SLAStartDate__c
                            );
                        } else {
                            caseRecord.SLAEndDate__c = businessHourService.calculateTargetDate(
                                CaseDecorator.CUSTOMER_CONTACT_10_DAYS,
                                caseRecord.SLAStartDate__c
                            );
                        }

                    }
                }

                if (!runMilestonesForList.isEmpty()) {
                    caseRecord.RunMilestonesFor__c = String.join(new List<String>(runMilestonesForList),';');
}
                }
            }
        }
    }