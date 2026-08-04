public with sharing class TA_Case_BI_CalculateSafeguardingSLA implements TriggerAction.BeforeInsert{
    
    public void beforeInsert(List<Case> newList){
        SafeguardingSLACalculationService.calculateSLADates(newList, null);
    }
}