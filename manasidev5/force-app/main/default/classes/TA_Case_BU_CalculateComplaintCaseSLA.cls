public with sharing class TA_Case_BU_CalculateComplaintCaseSLA implements TriggerAction.BeforeUpdate {
    
    public void beforeUpdate(List<Case> newList, List<Case> oldList){
        ComplaintCaseSLACalculationService.calculateSLAStartDate(newList, new Map<Id, Case>(oldList));
    }
}