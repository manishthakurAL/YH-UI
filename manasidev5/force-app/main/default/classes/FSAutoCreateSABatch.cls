public class FSAutoCreateSABatch implements database.Batchable<sObject>
{
    
    public database.QueryLocator start(Database.BatchableContext bc)
    {
       FSOrgSettings__c cs = FSOrgSettings__c.getOrgDefaults();    
        List<String> OPEN_STATUSES_CATEGORTIES = WorkOrderDecorator.OPEN_STATUSES_CATEGORTIES;   
        datetime currentDateTime = datetime.now();
        datetime eligibleStartCreatedDate = currentDateTime.addHours(Integer.valueOf(cs.SACreationJobIncludeScopeInHours__c));
        datetime eligibleEndDate = currentDateTime.addHours(Integer.valueOf(cs.SACreationJobExcludeScopeInHours__c));
        return database.getQueryLocator( [SELECT ID FROM WorkOrder 
                                            WHERE ServiceAppointmentCount = 0 
                                            AND StatusCategory IN :OPEN_STATUSES_CATEGORTIES 
                                            AND CreatedDate >= :eligibleStartCreatedDate 
                                            AND CreatedDate <= :eligibleEndDate]);
    }
    
    public void execute(Database.BatchableContext bc, List<WorkOrder> woList)
    {
        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        
        for(WorkOrder w : woList){
            ServiceAppointment sa = new ServiceAppointment();
            sa.ParentRecordId = w.Id;
            saList.add(sa); 
        }
        Database.Insert(saList);
    }
    
    public void finish(Database.BatchableContext bc){}
    
}