@isTest
public with sharing class UthWorkOrder {
    
    public static WorkOrder build(string OrchardJobNumber){
        WorkOrder wo = new WorkOrder();
        wo.OrchardJobNumber__c = OrchardJobNumber;
        wo.PropertyNumber__c = 'PN01';
        return wo;
    }
    
    public static WorkOrder create(string OrchardJobNumber){
        WorkOrder wo = build(OrchardJobNumber);
        Insert wo;
        return wo;
    }
    
    public static WorkOrder create(string OrchardJobNumber, Id pbId, Date reportedDate){
        WorkOrder wo = build(OrchardJobNumber);
        wo.Pricebook2Id = pbId;
        wo.ReportedDate__c = reportedDate;
        Insert wo;
        return wo;
    }

     public static WorkOrder build(string OrchardJobNumber, Id pbId, Date reportedDate, String status){
        WorkOrder wo = build(OrchardJobNumber);
        wo.Pricebook2Id = pbId;
        wo.ReportedDate__c = reportedDate;
        wo.Status = status;
        return wo;
    }

    public static WorkOrder create(string OrchardJobNumber, Id pbId, Date reportedDate, String status){
        WorkOrder wo = build(OrchardJobNumber);
        wo.Pricebook2Id = pbId;
        wo.ReportedDate__c = reportedDate;
        wo.Status = status;
        Insert wo;
        return wo;
    }

    
    public static list<WorkOrder> getAllWOsWithSAs(){
        return Database.query('SELECT '+
                String.join(new List<String>(WorkOrder.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ',(SELECT '
                + String.join(new List<String>(ServiceAppointment.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM ServiceAppointments)'
                + ' FROM WorkOrder');
    }

}