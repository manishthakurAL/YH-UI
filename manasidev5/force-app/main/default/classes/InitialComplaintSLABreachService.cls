public with sharing class InitialComplaintSLABreachService {

    public static void calculateInitialComplaintSLABreachStartDate(List<Case> casesList, Map<Id, Case> oldCasesMap) {
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        for (Case caseRecord : casesList) {
            if (caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_COMPLAINTS && caseRecord.OriginalReceivedDateTime__c != null
                && (oldCasesMap == null || (oldCasesMap != null && caseRecord.OriginalReceivedDateTime__c != oldCasesMap.get(caseRecord.Id).OriginalReceivedDateTime__c))) {
                DateTime startDateTime = businessHourService.getNextBusinessDay(caseRecord.OriginalReceivedDateTime__c,CaseDecorator.COMPLAINTS_CASE_INITIAL_STAGE_SLA_BASELINE_HOUR);
                caseRecord.InitialComplaintSLABreachStartDate__c = businessHourService.add(
                    startDateTime,
                    BusinessHourDecorator.FOUR_HOUR_IN_MILLISECONDS
                );
            }
            
        }
    }
}