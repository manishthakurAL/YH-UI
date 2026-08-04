@isTest
public class FSAutoCreateSABatchTest 
{
    
    @TestSetup
    static void setupTestData() {
        datetime currentDateTime = datetime.now();
        datetime createdDateTime = currentDateTime.addHours(-2);
        WorkOrder wo1 = UthWorkOrder.create('ORCH01');
        Test.setCreatedDate(wo1.Id, createdDateTime);
        WorkOrder wo2 = UthWorkOrder.create('ORCH02');
        Test.setCreatedDate(wo2.Id, createdDateTime);
        UthServiceAppointment.create(wo2.Id);
        WorkOrder wo3 = UthWorkOrder.create('ORCH03');
        WorkOrder wo4 = UthWorkOrder.build('ORCH04');
        wo4.Status = WorkOrderDecorator.STATUS_CANCELED;
        insert wo4;
        WorkOrder wo5 = UthWorkOrder.build('ORCH05');
        wo5.Status = WorkOrderDecorator.STATUS_COMPLETED;
        insert wo5;
        WorkOrder wo6 = UthWorkOrder.build('ORCH05');
        wo6.Status = WorkOrderDecorator.STATUS_NOTCOMPLETED;
        insert wo6;
    }
    
    
    @isTest
    public static void dailyJobTestRun(){
        UthFSOrgSettings.create();
        FSAutoCreateSABatch batchJob = new FSAutoCreateSABatch();
        Test.startTest();
        String jobId = Database.executeBatch(batchJob);
        Test.stopTest();
        
        for(WorkOrder w : UthWorkOrder.getAllWOsWithSAs()){
            switch on w.OrchardJobNumber__c  {
                when 'ORCH01'
                {
                    System.assertEquals(1, w.ServiceAppointments.size(), 'ServiceAppointment not created');
                }
                when 'ORCH02'
                {
                    System.assertEquals(1, w.ServiceAppointments.size(), 'ServiceAppointment should not be created');
                }
                when 'ORCH03'
                {
                    System.assertEquals(0, w.ServiceAppointments.size(), 'ServiceAppointment should not be created');
                }
                when 'ORCH04'
                {
                    Assert.areEqual(0, w.ServiceAppointments.size(), 'ServiceAppointment should not be created as status of job is cancelled');
                }
                when 'ORCH05'
                {
                    Assert.areEqual(0, w.ServiceAppointments.size(), 'ServiceAppointment should not be created as status of job is completed');
                }
                when 'ORCH06'
                {
                    Assert.areEqual(0, w.ServiceAppointments.size(), 'ServiceAppointment should not be created as status of job is not complete');
                }
            }
        }
    }
}