public class FSAutoCreateSASchedulable implements Schedulable{

    public void execute(SchedulableContext bc)
    {
        FSOrgSettings__c cs = FSOrgSettings__c.getOrgDefaults();
        FSAutoCreateSABatch sc = new FSAutoCreateSABatch();
        Database.executeBatch(sc, Integer.valueOf(cs.SACreationJobRecordScope__c));
    }
    
}