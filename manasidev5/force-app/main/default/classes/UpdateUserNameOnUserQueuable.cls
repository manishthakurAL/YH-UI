public with sharing class UpdateUserNameOnUserQueuable implements Queueable {
    
    private String originalTransactionId;
    private Set<Id> userIds;
    private Id orgwideEmailAddressId{
        get{
            if(this.orgwideEmailAddressId == null){
                this.orgwideEmailAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: OrgWideEmailAddressDecorator.NO_REPLY LIMIT 1].Id;
            }
            return this.orgwideEmailAddressId;
        }
        private set;
    }

    public UpdateUserNameOnUserQueuable(Set<Id> userIds) {
       this.userIds = userIds;
      
    }

    public void execute(QueueableContext context) {
        this.originalTransactionId = Logger.getTransactionId();
        Logger.info('Update Username Queueable Called');
        if(this.userIds != null){
            Map<Id, User> users = new Map<Id, User>([SELECT Id, Email, ContactId, FirstName, Username, IsActive FROM User  WHERE Id IN :this.userIds
                                            AND Profile.Name =: UserDecorator.PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN]);
            if( !users.isEmpty() ){
                for(User aUser : users.values()){
                    aUser.Username = aUser.Email;
                    Logger.info('Processed an user record', aUser);
                }
            List<Database.SaveResult> saveResults  = Database.update(users.values(), false);
            List<Id> successfulUpdateIds = new List<Id>();
            for (Database.SaveResult sr : saveResults) {
                    if (sr.isSuccess()) {
                    Logger.info('Successful update of username', sr.getId());
                    successfulUpdateIds.add(sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            Logger.error(' Error occured', sr.getId() + ': ' + err.getMessage());
                        }
                    }
                }
                try {
                    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                    if( !successfulUpdateIds.isEmpty() ){
                        for(Id userId : successfulUpdateIds){
                            if(users.get(userId).isActive){
                                emails.add(sendUserNameConfirmationEmail(users.get(userId)));
                            }
                        }
                        Messaging.SendEmailResult[] SendEmailResult = Messaging.sendEmail(emails);
                    }
                }catch(Exception e){
                    Logger.error(' Error occured while sending email', e.getMessage());
                }
            }
            }
        Logger.saveLog();
    }   

     private Messaging.SingleEmailMessage sendUserNameConfirmationEmail(User aUser) {
        
        CustomerPortalSettingsDecorator cps = new CustomerPortalSettingsDecorator();
          
        String body = String.format(
                Label.UpdateUsernameEmailBody,
                new List<String>{
                    cps.yhLogoSiteURL,   
                    aUser.FirstName,     
                    aUser.Username       
                }
            );  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(aUser.Id);
        mail.setOrgWideEmailAddressId(this.orgwideEmailAddressId);
        mail.setSubject(Label.CustomerUserNameChangedLabel);
        mail.setHtmlBody(body);
        mail.setSaveAsActivity(false);
        return mail;
    }
}