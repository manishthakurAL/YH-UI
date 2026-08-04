public with sharing class TA_Case_BIU_CalculateSLADatesCECEmail implements TriggerAction.BeforeUpdate, TriggerAction.BeforeInsert {
    public void beforeUpdate(List<Case> newList, List<Case> oldList){
        new CaseSLACalculationServiceEmailResponseGE().calculateSLADates(newList, new Map<Id, Case>(oldList));
    } 

    public void beforeInsert(List<Case> newList){
        new CaseSLACalculationServiceEmailResponseGE().calculateSLADates(newList, null);
    }
}