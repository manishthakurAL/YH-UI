public with sharing class SafeguardingSLACalculationService {
    
    public static void calculateSLADates(List<Case> casesList, Map<Id, Case> oldCasesMap) {
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        for (Case caseRecord : casesList) {
            if (caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_SAFEGUARDING && (
                (oldCasesMap == null) || 
                (caseRecord.Status != oldCasesMap.get(caseRecord.Id).Status && caseRecord.status == CaseDecorator.STATUS_IN_PROGRESS)
            )) {
                caseRecord.SLAStartDate__c = businessHourService.getNextBusinessDay(System.now(),null);
            }
        }
    }
}