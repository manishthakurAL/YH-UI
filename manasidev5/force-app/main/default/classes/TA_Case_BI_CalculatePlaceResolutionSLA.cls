public with sharing class TA_Case_BI_CalculatePlaceResolutionSLA implements TriggerAction.BeforeInsert{

    public void beforeInsert(List<Case> newList){
        new PlaceResolutionSLACalculationService().calculateSLADates(newList, null);
    }
}