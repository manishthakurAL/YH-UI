public with sharing class AutoCloseEmailCaseTypeBatch implements Database.Batchable<sObject>, Schedulable {
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

    private Id cecQueueId{
        get {
            if(this.cecQueueId == null){
                List<Group> cecQueue = [SELECT Id FROM GROUP WHERE DeveloperName = :CaseDecorator.CUSTOMER_EXPERIENCE_QUEUE];
                if( !cecQueue.isEmpty()){
                    this.cecQueueId = cecQueue[0].Id;
                }
            }
            return this.cecQueueId;
        } 
        private set;
    }

    private List<Id> cecCaseRoleIds{
        get {
            if(this.cecCaseRoleIds == null){
                List<String> roles = new List<String>{UserDecorator.ROLE_CUSTOMER_EXPERIENCE_ADVISOR, UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER };
                this.cecCaseRoleIds = new List<Id>();
                List<UserRole> cecroles = [SELECT Id FROM UserRole WHERE DeveloperName IN :roles];
                for(UserRole arole: cecroles){
                    this.cecCaseRoleIds.add(arole.Id);
                }
            }
            return this.cecCaseRoleIds;
        } 
        private set;
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

    public AutoCloseEmailCaseTypeBatch(List<Id> recordTypeIds, Integer daystoadd, Integer batchSize) {
        this.recordtypeIds = recordTypeIds;
        this.daystoadd = daystoadd;
        this.batchsize = batchSize;
    }

    public void execute(SchedulableContext ctx){
         this.batchId = Database.executeBatch(this);
    }

    public database.QueryLocator start(Database.BatchableContext bc)
    {
        return database.getQueryLocator( [SELECT Id, Status, AwaitingInformationDateTime__c FROM Case
        WHERE AwaitingInformationDateTime__c != null AND
        (RecordTypeId IN :recordtypeIds)  
        AND IsClosed = false
        AND AwaitingInformationDateTime__c <= :this.targetDateTime
        AND Status =  :CaseDecorator.STATUS_AWAITING_INFORMATION
        AND ( OwnerId = :this.cecQueueId OR Owner.UserRoleId IN :this.cecCaseRoleIds) 
        ORDER BY RecordTypeId]);
        
    }
    
    public void execute(Database.BatchableContext bc, List<Case> cases)
    {
        List<String> messagesList = new List<String>();
        String messages = 'Batch Id: ' + this.batchId + '\n';
        for(Case acase: cases){
            acase.Status = CaseDecorator.STATUS_STAGE_CLOSED;
            acase.ClosureReason__c = CaseDecorator.CASE_CLOSURE_REASON;
            acase.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_SYSTEM_AUTOMATED_CLOSURE;  
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