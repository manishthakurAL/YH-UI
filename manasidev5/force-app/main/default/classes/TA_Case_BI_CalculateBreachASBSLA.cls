public with sharing class TA_Case_BI_CalculateBreachASBSLA implements TriggerAction.BeforeInsert{
    public void beforeInsert(List<Case> newList){
        (new BreachASBSLACalculationService()).calculateSLADates(newList, null);
    }
}