public with sharing class DraftFileCleanupBatch implements Database.Batchable<sObject>, Database.stateful, Schedulable{

    private String batchId; 
    private String originalTransactionId;

    public database.QueryLocator start(Database.BatchableContext bc)
    {
        OrgSetting__c orgSetting = OrgSetting__c.getInstance();
        Datetime cleanUpDatetime = Datetime.now().addHours((Integer)orgSetting.NoOfHoursForFileCleanup__c);
        if(String.isEmpty(this.originalTransactionId)){
            this.originalTransactionId = Logger.getTransactionId();
        }
        Logger.info('Starting DraftFileCleanupBatch');
        Logger.saveLog();

        return Database.getQueryLocator([
            SELECT ID FROM DraftContainer__c
                WHERE CREATEDDATE <= :cleanUpDatetime AND Status__c =: DraftContainerDecorator.STATUS_DRAFT]
        );
       
    }
    
    public void execute(Database.BatchableContext bc, List<DraftContainer__c> draftContainerRecords)
    {       
        Logger.setParentLogTransactionId(this.originalTransactionId);
        Set<Id> draftContainerIds = new Set<Id>();
        for(DraftContainer__c draftContainerRecord: draftContainerRecords){
            draftContainerIds.add(draftContainerRecord.Id);
        }
        try{
            if(!draftContainerIds.isEmpty()){
                new ContentDocumentLinkService().getAndDeleteContentDocumentLinkAndIds(draftContainerIds);
            }

            for(DraftContainer__c draftContainerRecord: draftContainerRecords){
                draftContainerRecord.Status__c = DraftContainerDecorator.STATUS_CLEANUP_PROCESSED;
                Logger.info('Processed an Draft container record', draftContainerRecord);

            }
            update draftContainerRecords;
        }catch(Exception e){
            Logger.error('Error in DraftFileCleanupBatch', e.getMessage());
        }finally{
                Logger.saveLog();
        }
    }
    
    public void finish(Database.BatchableContext bc){
        Logger.setParentLogTransactionId(this.originalTransactionId);
        Logger.info('Finishing running DraftFileCleanupBatch');
        Logger.saveLog();
    }

    public void execute(SchedulableContext ctx){
        if(String.isEmpty(this.originalTransactionId)){
            this.originalTransactionId = Logger.getTransactionId();
        }
        this.batchId = Database.executeBatch(this);
    }
}