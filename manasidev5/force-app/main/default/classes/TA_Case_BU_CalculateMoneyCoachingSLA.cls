public with sharing class TA_Case_BU_CalculateMoneyCoachingSLA implements TriggerAction.BeforeUpdate {
    
    public void beforeUpdate(List<Case> newList, List<Case> oldList){
        MoneyCoachingSLACalculationService.calculateSLADates(newList, new Map<Id, Case>(oldList));
    }
}