public with sharing class AutoCloseTerminationCaseBatch implements Database.Batchable<sObject>, Schedulable{
    private Id batchId;
    private Integer daystoadd;
    private List<Id> recordtypeIds;
    private Integer batchSize;
    private List<ConnectApi.BatchResult> batchResults;
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

    @TestVisible private Date startDate{
        get{
            if(this.startDate == null){
                this.startDate = Date.today();
            }
            return this.startDate;

        }set{
            this.startDate = value;
        }
    }

    private Datetime targetDateTime{
        get {
            if(this.targetDateTime == null){
                BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
                DateTime startDateTime = businessHourService.getNextBusinessDay(this.startDate,null);
                this.targetDateTime = businessHourService.calculateTargetDate(this.daystoadd, startDateTime);
            }
            return this.targetDateTime;
        } 
        private set;
    }

    public AutoCloseTerminationCaseBatch(List<Id> recordTypeIds, Integer daystoadd, Integer batchSize) {
        this.recordtypeIds = recordTypeIds;
        this.daystoadd = daystoadd;
        this.batchsize = batchSize;
    }

    public void execute(SchedulableContext ctx){
        this.batchId = Database.executeBatch(this);
    }

    public database.QueryLocator start(Database.BatchableContext bc)
    {
        return database.getQueryLocator( [SELECT Id, Status, ClosureReason__c, CaseOutcome__c, SubStatus__c FROM Case
        WHERE (RecordTypeId IN :recordtypeIds)  
        AND IsClosed = false
        AND Tenancy__c != null
        AND TenancyEndDate__c != null
        AND TenancyEndDate__c <= :Date.valueOf(this.targetDateTime)
        ORDER BY RecordTypeId]);
        
    }
    
    public void execute(Database.BatchableContext bc, List<Case> cases)
    {
        List<String> messagesList = new List<String>();
        String messages = 'Batch Id: ' + this.batchId + '\n';
        for(Case cse: cases){
            cse.Status = CaseDecorator.STATUS_COMPLETE_CASE;
            cse.ClosureReason__c = CaseDecorator.CASE_CLOSURE_REASON_TENANCY_ENDED;
            cse.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_TENANCY_ENDED;  
            cse.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;

        }
        Boolean isSuccess = true;
        List<Database.SaveResult> srList = Database.update(cases, false);
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
            messages += 'Auto Close Email Case Batch Executed Successfully';
            messagesList.add(messages);
        }

        if(!messagesList.isEmpty()){
            OrgSetting__c setting = OrgSetting__c.getOrgDefaults();
            batchResults = this.chatterImpl.postToChatterFeedBatchResults(setting.SalesforceTechnicalChatterGroupID__c, messagesList);
        }
    }
    
    public void finish(Database.BatchableContext bc){}
}