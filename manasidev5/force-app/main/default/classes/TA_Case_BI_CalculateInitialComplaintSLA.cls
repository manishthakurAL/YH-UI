public with sharing class TA_Case_BI_CalculateInitialComplaintSLA implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<Case> newList){
        InitialComplaintSLABreachService.calculateInitialComplaintSLABreachStartDate(newList, null);
    }
}