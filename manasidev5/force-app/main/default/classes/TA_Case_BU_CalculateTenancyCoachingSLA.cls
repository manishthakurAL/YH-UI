public with sharing class TA_Case_BU_CalculateTenancyCoachingSLA implements TriggerAction.BeforeUpdate{
    
    public void beforeUpdate(List<Case> newList, List<Case> oldList){
        TenancyCoachingSLACalculationService.calculateSLADates(newList, new Map<Id, Case>(oldList));
    }
}