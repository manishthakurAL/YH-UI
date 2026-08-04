public with sharing class TA_Case_BI_CalculateTenancyCoachingSLA implements TriggerAction.BeforeInsert{
    
    public void beforeInsert(List<Case> newList){
        TenancyCoachingSLACalculationService.calculateSLADates(newList, null);
    }
}