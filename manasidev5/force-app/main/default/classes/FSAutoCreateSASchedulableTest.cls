@isTest
public class FSAutoCreateSASchedulableTest {
    
@isTest
    public static void dailyJobTestRun(){
        UthFSOrgSettings.create();
        FSAutoCreateSASchedulable schedJob = new FSAutoCreateSASchedulable();
        String sch = '0 0 0 * * ?';
        Test.startTest();
        String jobId = System.schedule('Test Scheduled Batch', sch, schedJob);
        Test.stopTest();
        
        CronTrigger ct = UthCronTrigger.getCronTriggerRecord(jobId);
        System.assertEquals('0 0 0 * * ?', ct.CronExpression, 'Cron expression should match the schedule.');
    }
}