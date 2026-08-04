public with sharing class CaseSharingBatch{
	/*  Batch implemented as part of US-34683.
     *  Commented as part of US-37607
     * 	Reason for Commenting : This code is intentially commented out as future enhancements may require Breach and ASB Cases to be shared.
public with sharing class CaseSharingBatch implements Database.Batchable<sObject>, Schedulable {
    private Id batchId;
    private Integer batchSize;
    private List<ConnectApi.BatchResult> batchResults;
    private Integer offSetDays{
        get{
            if(this.offSetDays == null){
                this.offSetDays = OrgSetting__c.getOrgDefaults().CaseSharingOffsetDays__c != null 
                    ? OrgSetting__c.getOrgDefaults().CaseSharingOffsetDays__c.intValue() 
                    : -6;
            }
            return this.offSetDays;
        }
        set;
    }

    @TestVisible private ChatterInterface chatterImpl{
        get{
            if(this.chatterImpl == null){
                this.chatterImpl = new ChatterPostImpl();
            }
            return this.chatterImpl;
        }
        set{
           this.chatterImpl = value;
        }
    }

    public CaseSharingBatch(Integer batchSize) {
        this.batchsize = batchSize;
    }

    public database.QueryLocator start(Database.BatchableContext bc){
        Date targetDate = Date.today().addDays(this.offSetDays);

        return database.getQueryLocator([SELECT Id, CaseReadyForSharing__c 
                FROM Case
                WHERE RecordTypeId =: CaseDecorator.RECORD_TYPE_ID_BREACH_ASB AND 
                    CreatedDate <: targetDate AND 
                    CaseReadyForSharing__c EXCLUDES (:CaseDecorator.RECORD_TYPE_BREACH) ]
        );
    }

    public void execute(SchedulableContext ctx){
         this.batchId = Database.executeBatch(this);
    }

    public void execute(Database.BatchableContext bc, List<Case> Cases){

        List<String> messagesList = new List<String>();
        String messages = 'Batch Id: ' + this.batchId + '\n';
        for(Case caseRecord: Cases){
            if(caseRecord.CaseReadyForSharing__c != null){
                List<String> readyForSharingList = caseRecord.CaseReadyForSharing__c.split(';');
                readyForSharingList.add(CaseDecorator.RECORD_TYPE_BREACH);
                caseRecord.CaseReadyForSharing__c = String.join(readyForSharingList, ';');
            } else{
                caseRecord.CaseReadyForSharing__c = CaseDecorator.RECORD_TYPE_BREACH;
            }
                
        }
        Boolean isSuccess = true;
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        List<Database.SaveResult> srList = Database.update(Cases, false);
        MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        for (Database.SaveResult sr : srList) {
            if ( !sr.isSuccess()) {
                messages ='Case Id:' + sr.getId() + '\n';
                for(Database.Error err : sr.getErrors()) {
                    messages += ' Error: ' + err.getMessage() + '\n';
                }
                messagesList.add(messages);
                isSuccess = false;
            }
        }
        if(isSuccess){
            messages += 'Case Sharing Batch Executed Successfully';
            messagesList.add(messages);
        }

        if(!messagesList.isEmpty()){
            OrgSetting__c setting = OrgSetting__c.getOrgDefaults();
            batchResults = this.chatterImpl.postToChatterFeedBatchResults(setting.SalesforceTechnicalChatterGroupID__c, messagesList);
        }
    }

    public void finish(Database.BatchableContext bc){}
	*/
}