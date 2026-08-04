public with sharing class TA_Case_BI_CalculateTenancyFirstContSLA implements TriggerAction.BeforeInsert,TriggerAction.BeforeUpdate {

    public void beforeInsert(List<Case> newList){
        new TenancyFirstContactSLACalculationService().calculateSLADates(newList, null);
    }

    public void beforeUpdate(List<Case> newList, List<Case> oldList){
        new TenancyFirstContactSLACalculationService().calculateSLADates(newList, new Map<Id,Case>(oldList) );
    }
}