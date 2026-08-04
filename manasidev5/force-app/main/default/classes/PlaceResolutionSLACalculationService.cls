public class PlaceResolutionSLACalculationService {

    private DateTime startDateTime;

    public PlaceResolutionSLACalculationService(){
        this.startDateTime = System.now();
    }
    
    @TestVisible
    private PlaceResolutionSLACalculationService(DateTime startDateTime){
        this.startDateTime = startDateTime;
    }
    
    public void calculateSLADates(List<Case> casesList, Map<Id, Case> oldCasesMap) {
        for (Case caseRecord : casesList) {
            if (caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_PLACE 
                    && (caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_ABANDONED_VEHICLES 
                        || caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_LAND_DISPUTES)
                    && caseRecord.Status == CaseDecorator.STATUS_NEW) {
                
                this.calculateStartAndEndDate(caseRecord);
            }
        }
    }

    @testvisible
    private void calculateStartAndEndDate(Case caseRecord){
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        caseRecord.SLAStartDate__c = businessHourService.getNextBusinessDay(this.startDateTime, null);
        Integer noOfSLADays = 0;
        if(caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_ABANDONED_VEHICLES){
            noOfSLADays = CaseDecorator.PLACE_ABANDONED_VEHICLES_CASE_SLA_DAYS;
        }else if(caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_LAND_DISPUTES){
            noOfSLADays = CaseDecorator.PLACE_LAND_DISPUTES_CASE_SLA_DAYS;
        }
        caseRecord.SLAEndDate__c = businessHourService.calculateTargetDate(noOfSLADays, caseRecord.SLAStartDate__c);
    }
}