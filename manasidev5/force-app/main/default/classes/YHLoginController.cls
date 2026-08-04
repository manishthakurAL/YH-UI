public with sharing class YHLoginController {
    private static final String PASSWORD_LOCKOUT = 'Password Lockout';
    private static final String INVALID_PASSWORD = 'Invalid Password';
    private static final String EMAIL_TEMPLATE_ACCOUNTLOCKED = 'YHCustomerPortalAccountLockout';
    public String emailAddress { get; set; }
    private String emailAddressCopy;
    public String password { get; set; }
    public String errorText { get; set; }
    public Boolean isError { get; set; }
    public Boolean isLocked { get; set; }

    @testVisible
    private User currentUser {
        get {
            if (this.emailAddress != null && this.currentUser == null) {
                WithoutSharingController withoutSharingController = new WithoutSharingController(this.emailAddress);
                this.currentUser = withoutSharingController.currentUser;
            }
            return this.currentUser;
        }
        private set;
    }

    private boolean usernameExist{
        get{
            if(this.currentUser != null){
                this.usernameExist = true;
            } else {
                this.usernameExist = false;
            }
            return this.usernameExist;
        }
        private set;
    }

    private String noReplySenderId{
        get{
            if(this.noReplySenderId == null){
                this.noReplySenderId = new WithoutSharingController().noReplySenderId;
            }
            return this.noReplySenderId;
        }
        private set;
    }

    private Id orgwideEmailAddressId{
        get{
            if(this.orgwideEmailAddressId == null){
                this.orgwideEmailAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: OrgWideEmailAddressDecorator.NO_REPLY LIMIT 1].Id;
            }
            return this.orgwideEmailAddressId;
        }
        private set;
    }

    private Id emailTemplateId{
        get{
            if(this.emailTemplateId == null){
                this.emailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: EMAIL_TEMPLATE_ACCOUNTLOCKED LIMIT 1].Id;
            }
            return this.emailTemplateId;
        }
        private set;
    }

    public PageReference doLogin() {
        PageReference pageReference;
        this.resetValues();
        try{
            if(this.emailAddress != this.emailAddressCopy){
                this.emailAddressCopy = this.emailAddress;
                this.currentUser = null;
            }
            
            if(this.usernameExist){
                pageReference = Site.login(this.emailAddress, this.password, '/s/');
            } else {
                this.setUserNotExist();
            }
        } catch(Exception e){
            this.setError();
        }
        
        if (pageReference == null && this.usernameExist) {
            if(isAccountLocked()){
                this.accountLocked();
                this.sendNotifications();
                new MfaTrustedDeviceService().revokeTrustDeviceOnAccountLockout(CustomerTrustedDeviceDecorator.ACCOUNT_LOCKED_LOGINDETAILS_REVOKE_REASON, this.currentUser.Id);
            } else {
                this.setError();
            }
        }
        return pageReference;
    }

    private void resetValues(){
        this.isError = false;
        this.isLocked = false;
        this.errorText = null;
    }

    private void setUserNotExist(){
        this.isError = true;
        this.errorText = Label.InvalidPassword;
    }

    private void accountLocked(){
        this.errorText =  Label.AccountLocked;
    }

    private void setError(){
        this.isError = true;
        this.errorText = Label.InvalidPassword;
    }

    private Boolean isAccountLocked(){
        Boolean isAccountLocked = false;
        List<UserLogin> userLogin = [SELECT IsPasswordLocked 
            FROM UserLogin 
            WHERE UserId =: this.currentUser.Id LIMIT 1];
        if(!userLogin.isEmpty()){
            this.isLocked = userLogin[0].IsPasswordLocked;
            isAccountLocked = userLogin[0].IsPasswordLocked;
        }
        return isAccountLocked;
    }

    @testVisible
    private void sendNotifications() {
        if(this.currentUser != null){
            if (this.currentUser.Contact.MobilePhone != null) {
                this.sendSMSNotification();
            } else {
                EmailService.sendEmail(this.currentUser.ContactId, this.emailTemplateId, this.orgwideEmailAddressId);
            }
        }
    }

    public void sendSMSNotification() {
        try{
			if(this.currentUser != null){
                String body = Label.AccountLockedSMSNotification;
                SMSMagicRequestEvent__e smsEvent = new SMSMagicRequestEvent__e(
                    ContactId__c = this.currentUser.Contact.Id,
                    Message__c = body,
                    RequestedById__c = this.currentUser.Id,
                    SenderId__c = this.noReplySenderId
            	);
           		EventBus.Publish(smsEvent);
            }
        }
        catch (Exception e) {
            throw new YH_LoginControllerException(e.getMessage());
        }
    }
    public without sharing class WithoutSharingController{
        @testVisible
        private User currentUser;
        private String noReplySenderId{
            get{
                if(this.noReplySenderId == null){
                    this.noReplySenderId = [SELECT Id,smagicinteract__senderId__c FROM smagicinteract__SMS_SenderId__c WHERE smagicinteract__Label__c =: SMSMagicDecorator.SENDERIDLABEL_NOREPLY LIMIT 1]?.smagicinteract__senderId__c;
                }
                return this.noReplySenderId;
            }
            private set;
        }
        public WithoutSharingController(){}

        public WithoutSharingController(String username){
            List<User> users = [SELECT Id, Email, Contact.MobilePhone, Contact.Id, Contact.Name
                    FROM User 
                    WHERE Username =: username AND
                        IsActive = true AND
                        ProfileId =: UserDecorator.PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN_ID];
            this.currentUser = users.isEmpty() ? null : users[0];
        }
    }
    public class YH_LoginControllerException extends Exception {}
}