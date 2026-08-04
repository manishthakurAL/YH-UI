public with sharing class TA_Case_BU_CalculateBreachASBSLA implements TriggerAction.BeforeUpdate{
    
    public void beforeUpdate(List<Case> newList, List<Case> oldList){
        (new BreachASBSLACalculationService()).calculateSLADates(newList, new Map<Id, Case>(oldList));
    }
}