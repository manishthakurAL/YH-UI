public with sharing class TA_Case_BI_CalculateMoneyCoachingSLA implements TriggerAction.BeforeInsert{
    
    public void beforeInsert(List<Case> newList){
        MoneyCoachingSLACalculationService.calculateSLADates(newList, null);
    }
}