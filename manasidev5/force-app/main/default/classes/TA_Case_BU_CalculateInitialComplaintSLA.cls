public with sharing class TA_Case_BU_CalculateInitialComplaintSLA implements TriggerAction.BeforeUpdate{
    
    public void beforeUpdate(List<Case> newList, List<Case> oldList){
        InitialComplaintSLABreachService.calculateInitialComplaintSLABreachStartDate(newList, new Map<Id, Case>(oldList));
    }
}