public without sharing class TA_Tenancy_BIU_ManageCustSharingReson implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {
    
    public static void beforeInsert(List<YH_Tenancy__c> newList) {
        for (YH_Tenancy__c tenancy : newList) {
            if (tenancy.Active__c == false) { 
                tenancy.CustomerSharingReasons__c = null;
            }
            else if (tenancy.Active__c == true) { 
                tenancy.CustomerSharingReasons__c = TenancyDecorator.CUSTOMER_SHARING_REASON_TENANCY;
            }
        }
    } 

    public static void beforeUpdate(List<YH_Tenancy__c> newList, List<YH_Tenancy__c> oldList) {
        Map<Id,YH_Tenancy__c> oldMap = new Map<Id,YH_Tenancy__c>(oldList);
        for (YH_Tenancy__c tenancy : newList) {
            YH_Tenancy__c oldRecord = oldMap.get(tenancy.Id); 
            if (tenancy.Active__c == false  && oldRecord.Active__c == true) { 
                tenancy.CustomerSharingReasons__c = null;
            }
            else if (tenancy.Active__c == true  && oldRecord.Active__c == false) { 
                tenancy.CustomerSharingReasons__c = TenancyDecorator.CUSTOMER_SHARING_REASON_TENANCY;
            }
        }
    } 
}