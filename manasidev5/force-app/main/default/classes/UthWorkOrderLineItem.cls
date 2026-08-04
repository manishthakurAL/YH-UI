@isTest
public with sharing class UthWorkOrderLineItem {
    public static WorkOrderLineItem build(Id workOrderId, Id pricebookentryId, String integrationStatus){
         return new WorkOrderLineItem( WorkOrderId = workOrderId,
                        PricebookEntryId = pricebookentryId,
                        IntegrationStatus__c = integrationStatus
         );
    }

    public static List<WorkOrderLineItem> getAll() {
         return Database.query('SELECT '+
            String.join(new List<String>(WorkOrderLineItem.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
                        //add more feilds from related object as and wehn required
            ' FROM WorkOrderLineItem '
        );
    }
}