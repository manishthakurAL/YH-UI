public with sharing class TA_Case_BI_CalculateTenancyResolutionSLA implements TriggerAction.BeforeInsert{

    public void beforeInsert(List<Case> newList){
        (new TenancyResolutionSLACalculationService()).calculateSLADates(newList, null);
    } 
}