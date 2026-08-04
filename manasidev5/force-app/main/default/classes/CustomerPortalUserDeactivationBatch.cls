public with sharing class CustomerPortalUserDeactivationBatch implements Database.Batchable<sObject>, Schedulable{
    private Id batchId;
    private Integer batchSize;
    private Integer offsetDays;
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

    public CustomerPortalUserDeactivationBatch(Integer batchSize, Integer offsetDays) {
        this.batchsize = batchSize;
        this.offsetDays = offsetDays;
    }

    public database.QueryLocator start(Database.BatchableContext bc){
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Date twoDaysPastBusinessdays = Date.ValueOf(businessHourService.addBusinessDays( Datetime.now(), -2));
        Date occupancyEndDateOffset = Date.today().addDays(-this.offsetDays);
        
        return database.getQueryLocator([SELECT Id, ContactID 
                FROM User
                WHERE ProfileID =: UserService.customerPortalProfileId AND 
                    IsActive = TRUE AND
                    ContactId IN (SELECT Contact__c
                        FROM Member__c 
                        WHERE Contact__r.CustomerType__c NOT IN: ContactDecorator.CUSTOMERTYPE_TENANT_TYPES AND
                            IsActive__c = FALSE AND 
                            (
                                OccupancyEndDate__c >=: occupancyEndDateOffset AND 
                                OccupancyEndDate__c <=: twoDaysPastBusinessdays 
                            ) AND 
                            Type__c IN: MemberDecorator.TENANT_APPLICABLE_TYPE)]
            );
    }

    public void execute(SchedulableContext ctx){
         this.batchId = Database.executeBatch(this);
    }

    public void execute(Database.BatchableContext bc, List<User> users){

        List<String> messagesList = new List<String>();
        String messages = 'Batch Id: ' + this.batchId + '\n';
        for(User user: users){
            user.IsActive = false;
        }
        Boolean isSuccess = true;
        List<Database.SaveResult> srList = Database.update(users, false);
        for (Database.SaveResult sr : srList) {
            if ( !sr.isSuccess()) {
                messages ='User Id:' + sr.getId() + '\n';
                for(Database.Error err : sr.getErrors()) {
                    messages += ' Error: ' + err.getMessage() + '\n';
                }
                messagesList.add(messages);
                isSuccess = false;
            }
        }
        if(isSuccess){
            messages += 'Customer Portal Update Batch Executed Successfully';
            messagesList.add(messages);
        }

        if(!messagesList.isEmpty()){
            OrgSetting__c setting = OrgSetting__c.getOrgDefaults();
            batchResults = this.chatterImpl.postToChatterFeedBatchResults(setting.SalesforceTechnicalChatterGroupID__c, messagesList);
        }
    }

    public void finish(Database.BatchableContext bc){}
}