public with sharing class TA_Case_BI_CalculateComplaintCaseSLA implements TriggerAction.BeforeInsert{
    public void beforeInsert(List<Case> newList){
        ComplaintCaseSLACalculationService.calculateSLAStartDate(newList, null);
    }
}