public with sharing class CaseSLACalculationServiceEmailResponseGE {
    
    private DateTime startDateTime;

    public CaseSLACalculationServiceEmailResponseGE(){
        this.startDateTime = System.now();
    }
    
    @TestVisible
    private CaseSLACalculationServiceEmailResponseGE(DateTime startDateTime){
        this.startDateTime = startDateTime;
    }

    private static final Set<Id> recordTypesToProcess = new Set<Id>{
        CaseDecorator.RECORD_TYPE_ID_GENERAL_ENQUIRY,
        CaseDecorator.RECORD_TYPE_ID_EMAILRESPONSE
    };
    
    public  void calculateSLADates(List<Case> casesList, Map<Id, Case> oldCasesMap) {
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Map<Id, Case> casesMap = new Map<Id, Case>();
        Set<Id> caseIds = new Set<Id>();
        for (Case caseRecord : casesList) { 
            if (recordTypesToProcess.contains(caseRecord.RecordTypeId)) {
                caseIds.add(caseRecord.Id);
            }
        }
    
        
        for (Case caseRecord : casesList) {
            if (recordTypesToProcess.contains(caseRecord.RecordTypeId)) {
                Set<String> runMilestonesForList = !String.isBlank(caseRecord.RunMilestonesFor__c) ? new Set<String>(caseRecord.RunMilestonesFor__c.split(';')) : new Set<String>();
                if (oldCasesMap == null && caseRecord.Status ==  CaseDecorator.STATUS_NEW)  {
                    caseRecord.SLAStartDate__c = businessHourService.getNextBusinessDay(this.startDateTime,null);
                    
                    if ( ( caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_GENERAL_ENQUIRY 
                            || caseRecord.RecordTypeId ==  CaseDecorator.RECORD_TYPE_ID_EMAILRESPONSE) &&
                             ( caseRecord.Origin == CaseDecorator.CASE_ORIGIN_EMAIL_CEC || caseRecord.Origin == CaseDecorator.CASE_ORIGIN_EMAIL_CUSTOMERSERVICES
                                    || caseRecord.Origin == CaseDecorator.CASE_ORIGIN_EMAIL_WEBREPAIRS
                                    || caseRecord.Origin == CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL
                                    || caseRecord.Origin == CaseDecorator.CASE_ORIGIN_OPERATIVE_REPAIRS)
                        ) {
                        runMilestonesForList.add(CaseMilestoneDecorator.CASE_MILESTONE_INITIALEMAIL);
                    }
                }
                else if (caseRecord.Status == CaseDecorator.CASE_STAGE_EMAILRESPONSERECIEVED && oldCasesMap != null
                    && caseRecord.Status != oldCasesMap.get(caseRecord.Id).Status)  {
                        caseRecord.SLAStartDate__c = businessHourService.getNextBusinessDay(this.startDateTime,null);
                        runMilestonesForList.remove(CaseMilestoneDecorator.CASE_MILESTONE_INITIALEMAIL);
                        runMilestonesForList.add(CaseMilestoneDecorator.CASE_MILESTONE_EMAILRESPONSE);
                }else if( caseRecord.Status !=  CaseDecorator.STATUS_NEW && caseRecord.Status !=  CaseDecorator.CASE_STAGE_EMAILRESPONSERECIEVED ){
                    runMilestonesForList.remove(CaseMilestoneDecorator.CASE_MILESTONE_INITIALEMAIL);
                    runMilestonesForList.remove(CaseMilestoneDecorator.CASE_MILESTONE_EMAILRESPONSE);
                    caseRecord.RunMilestonesFor__c = '';
                }

                if (!runMilestonesForList.isEmpty()) {
                    caseRecord.RunMilestonesFor__c = String.join(new List<String>(runMilestonesForList),';');
                }
            }
        }
    }
}