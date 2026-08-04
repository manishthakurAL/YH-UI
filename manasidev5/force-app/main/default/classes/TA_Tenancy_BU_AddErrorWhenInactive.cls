public with sharing class TA_Tenancy_BU_AddErrorWhenInactive implements TriggerAction.BeforeUpdate {

    @TestVisible
    private static final String ERROR_MESSAGE = 'Tenancy records cannot be updated when inactive'; 
    
    public static void beforeUpdate(List<YH_Tenancy__c> newList, List<YH_Tenancy__c> oldList) {
        Map<Id,YH_Tenancy__c> oldMap = new Map<Id,YH_Tenancy__c>(oldList);
        for (YH_Tenancy__c tenancy : newList) {
            YH_Tenancy__c oldRecord = oldMap.get(tenancy.Id); 
            if (tenancy.Active__c == false  && oldRecord.Active__c == false) {
                tenancy.Active__c.addError(ERROR_MESSAGE); 
            }
        }
    }
}