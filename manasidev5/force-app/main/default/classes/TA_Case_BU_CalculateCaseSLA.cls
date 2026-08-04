public with sharing class TA_Case_BU_CalculateCaseSLA implements TriggerAction.BeforeUpdate{
    
    public void beforeUpdate(List<Case> newList, List<Case> oldList){
        (new CaseSLACalculationService()).calculateSLADates(newList, new Map<Id, Case>(oldList));
    } 
}