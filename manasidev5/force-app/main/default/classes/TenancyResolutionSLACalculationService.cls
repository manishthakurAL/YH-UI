public class TenancyResolutionSLACalculationService {

    private DateTime startDateTime;

    public TenancyResolutionSLACalculationService(){
        this.startDateTime = System.now();
    }
    
    @TestVisible 
    private TenancyResolutionSLACalculationService(DateTime startDateTime){
        this.startDateTime = startDateTime;
    }
    
    public void calculateSLADates(List<Case> casesList, Map<Id, Case> oldCasesMap) {
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        for (Case caseRecord : casesList) {
            if (caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_TENANCY 
                && (caseRecord.CaseType__c == CaseDecorator.TYPE_ABANDONED_GOODS || caseRecord.CaseType__c == CaseDecorator.TYPE_ABANDONED_PROPERTIES || caseRecord.CaseType__c == CaseDecorator.TYPE_RIGHT_To_RENT)
                && caseRecord.Status == CaseDecorator.STATUS_NEW) {
                    caseRecord.SLAStartDate__c = businessHourService.getNextBusinessDay(this.startDateTime,null);
                    Integer SLA_DAYS = 0;
                    if(caseRecord.CaseType__c == CaseDecorator.TYPE_ABANDONED_GOODS){
                        SLA_DAYS = CaseDecorator.TENANCY_ABANDONED_GOODS_CASE_SLA_DAYS;
                    }else if(caseRecord.CaseType__c == CaseDecorator.TYPE_ABANDONED_PROPERTIES){
                        SLA_DAYS = CaseDecorator.TENANCY_ABANDONED_PROPERTY_CASE_SLA_DAYS;
                    }else if(caseRecord.CaseType__c == CaseDecorator.TYPE_RIGHT_To_RENT){
                        SLA_DAYS = CaseDecorator.TENANCY_RIGHT_TO_RENT_CASE_SLA_DAYS;
                    }
                    caseRecord.SLAEndDate__c = businessHourService.calculateTargetDate(SLA_DAYS, caseRecord.SLAStartDate__c);
                }
        }
    }
}