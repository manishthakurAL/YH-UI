public with sharing class MoneyCoachingSLACalculationService {
    
    public static void calculateSLADates(List<Case> casesList, Map<Id, Case> oldCasesMap) {
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        for (Case caseRecord : casesList) {
            if (caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_MONEY_COACHING && !String.isBlank(caseRecord.Priority)
                && caseRecord.OwnerId.getSobjectType().getDescribe().getName() == User.sObjectType.getDescribe().getName()
                && (caseRecord.Priority == CaseDecorator.PRIORITY_HIGH || caseRecord.Priority == CaseDecorator.PRIORITY_LOW)
                && (oldCasesMap == null || (oldCasesMap != null && (caseRecord.Priority != oldCasesMap.get(caseRecord.Id).Priority
                || caseRecord.OwnerId != oldCasesMap.get(caseRecord.Id).OwnerId)))) {
                caseRecord.SLAStartDate__c = businessHourService.getNextBusinessDay(System.now(),null);
                caseRecord.SLAEndDate__c = businessHourService.calculateTargetDate(
                    caseRecord.Priority == CaseDecorator.PRIORITY_HIGH ? CaseDecorator.MONEY_COACHING_CASE_HIGH_PRIORITY_DAYS : CaseDecorator.MONEY_COACHING_CASE_LOW_PRIORITY_DAYS,
                    caseRecord.SLAStartDate__c
                );
            }
        }
    }
}