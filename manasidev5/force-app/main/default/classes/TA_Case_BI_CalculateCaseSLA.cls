public with sharing class TA_Case_BI_CalculateCaseSLA implements TriggerAction.BeforeInsert{
    
    public void beforeInsert(List<Case> newList){
        (new CaseSLACalculationService()).calculateSLADates(newList, null);
    } 
}