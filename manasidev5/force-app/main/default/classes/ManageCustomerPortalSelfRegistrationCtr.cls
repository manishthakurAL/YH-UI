public with sharing class ManageCustomerPortalSelfRegistrationCtr {

    public String firstName { get; set; }
    public String lastName { get; set; }
    public String email { get; set; }

    public Date dateOfBirth { get; set; }
    public String postCode { get; set; }

    public String firstNameValidationMessage { get; set; }
    public String lastNameValidationMessage { get; set; }
    public String emailValidationMessage { get; set; }
    public String dateOfBirthValidationMessage { get; set; }
    public String postCodeValidationMessage { get; set; }
    public String failureMessage { get; set; }
    public String sucessMessage { get; set; }
    public Boolean isUserCreationSuccessful { get; set; }

    private static final String CUSTOMER_PORTAL_NAME = 'YHCustomerPortal';
    private static final String USER_EXIST_EXCEPTION = 'user already exists';
    
    private String birthdateText{
        get{
            if(this.dateOfBirth != null){
                this.birthdateText = (String.valueOf(dateOfBirth.day())).leftPad(2, '0') +  
                                    (String.valueOf(dateOfBirth.month())).leftPad(2, '0') + 
                                    String.valueOf(dateOfBirth.year());
            }
            return this.birthdateText;
        }
        set;
    }

    private String communityLoginURL{
        get{
            if(this.communityLoginURL == null){
                // Replace the method if we are using custom url Site.getBaseCustomUrl()
                this.communityLoginURL = Site.getBaseUrl() + '/yhlogin';
            }
            return this.communityLoginURL;
        }
        private set;
    }

    private String communityForgotPasswordURL{
        get{
            if(this.communityForgotPasswordURL == null){
                this.communityForgotPasswordURL = Site.getBaseUrl() + '/s/login/ForgotPassword';
            }
            return this.communityForgotPasswordURL;
        }
        private set;
    }

    public ManageCustomerPortalSelfRegistrationCtr() {
    }

    @testvisible
    private ManageCustomerPortalSelfRegistrationCtr(String firstName, String lastName, String email,
                                                Date dateOfBirth, String postCode){
        this.firstName = firstName; 
        this.lastName = lastName;
        this.email = email;
        this.dateOfBirth = dateOfBirth;
        this.postCode = postCode;
    }

    private void clearAll(){
        this.firstNameValidationMessage = null;
        this.lastNameValidationMessage = null;
        this.emailValidationMessage = null;
        this.dateOfBirthValidationMessage = null;
        this.postCodeValidationMessage = null;
        this.failureMessage = null;
        this.sucessMessage = null;
    }

    
    
    public PageReference registerUser() {
        this.clearMessages();
        Account matchedAccount = getMatchedAccountBasedonEmailAndDOB();
        if(matchedAccount != null){
            String givenPostCode = this.postCode.deleteWhitespace();
            List<Member__c> matchedMembers = new TenancyService().getActiveTenanciesByPostCode(matchedAccount.Id, givenPostCode);
            if(!matchedMembers.isEmpty()){
                ManageCustomerPortalSelfRegistrationCtrWS registration = new ManageCustomerPortalSelfRegistrationCtrWS(this.firstName, this.lastName, this.email,
                                            this.dateOfBirth, this.postCode, matchedAccount.Id);
                User u = registration.populatePortalUser();
                Id userId;
                try {
                    userId = Site.createExternalUser(u, matchedAccount.Id, null, true);
                    if(userId != null){
                        new ManageCustomerPortalSelfRegistrationCtrWS(userId, matchedAccount.Id).assignCustomerPortalPSG();
                    }
                    this.sucessMessage = Label.UserCreatedSuccessfully;
                    this.isUserCreationSuccessful = true;
                } catch (Site.ExternalUserCreateException siteException) {
                    if(siteException.getMessage().containsIgnoreCase(USER_EXIST_EXCEPTION)){
                        try{
                            User user = registration.getExistingUser();
                            if(!user.IsActive){
                                userId = registration.activateExistingUser(user).Id;
                                new ManageCustomerPortalSelfRegistrationCtrWS(userId).passwordReset();
                                this.sucessMessage = Label.UserAlreadyExistActivated;
                            } else {
                                userId = user.Id;
                                this.sucessMessage = Label.UserAlreadyExist
                                                            .replace('{loginURL}', this.communityLoginURL)
                                                            .replace('{forgotPasswordURL}', this.communityForgotPasswordURL);
                            }
                            new ManageCustomerPortalSelfRegistrationCtrWS(userId, matchedAccount.Id).assignCustomerPortalPSG();
                            this.isUserCreationSuccessful = true;
                        } catch (Exception unexpectedException) {
                            this.failureMessage = Label.GenericContactUsMessage;
                            this.isUserCreationSuccessful = false;
                        }
                    }
                } catch (Exception e){
                    this.failureMessage = Label.GenericContactUsMessage;
                    this.isUserCreationSuccessful = false;
                }
            } else{
                this.failureMessage = Label.GenericContactUsMessage;
                this.isUserCreationSuccessful = false;
            }
        } else{
            this.failureMessage = Label.GenericContactUsMessage;
            this.isUserCreationSuccessful = false;
        }
        if (String.isNotBlank(this.failureMessage)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, this.failureMessage));
        } else if (this.isUserCreationSuccessful) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, this.sucessMessage));
        }
        return null;
    }

    private void clearMessages(){
        this.failureMessage = null;
        this.sucessMessage = null;
        this.isUserCreationSuccessful = false;
    }

    @testVisible
    private Account getMatchedAccountBasedonEmailAndDOB(){
        Account matchedAccountBasedOnEmail;
        List<Account> matchedAccountsBasedOnEmail =  new ManageCustomerPortalSelfRegistrationCtrWS(this.firstName, this.lastName, this.email,
                                                this.dateOfBirth, this.postCode).getMatchBasedOnEmail();
        if(matchedAccountsBasedOnEmail != null && !matchedAccountsBasedOnEmail.isEmpty()){
            List<Account> matchedAccsBasedOnDOB = new ManageCustomerPortalSelfRegistrationCtrWS(this.firstName, this.lastName, this.email,
                                                this.dateOfBirth, this.postCode).matchBasedOnDOB();
            Boolean matchSuccessful = false;
            
            Map<Id, Account> MacthedAccIdWithDOBByAccountID = new Map<Id, Account>();
            for(Account matchedAccBasedOnEmail : matchedAccountsBasedOnEmail){
                for(Account matchedAccBasedOnDOB : matchedAccsBasedOnDOB){
                    if(matchedAccBasedOnEmail.Id == matchedAccBasedOnDOB.Id){
                        MacthedAccIdWithDOBByAccountID.put(matchedAccBasedOnEmail.Id, matchedAccBasedOnEmail);
                    }
                }
            }
            if(!MacthedAccIdWithDOBByAccountID.isEmpty() && MacthedAccIdWithDOBByAccountID.size() == 1){
                matchedAccountBasedOnEmail = MacthedAccIdWithDOBByAccountID.values()[0];
                matchSuccessful = true;
            }
            
            if(!matchSuccessful){
                return null;
            }
        }
        return matchedAccountBasedOnEmail;
    }

    public PageReference backToLoginPage(){
        PageReference page = new PageReference(this.communityLoginURL);
        page.setRedirect(true);
        return page;
    }

    public without sharing class ManageCustomerPortalSelfRegistrationCtrWS{
        private String firstName;
        private String lastName;
        private String email;
        private Date dateOfBirth;
        private String postCode;
        private Id userId;
        private Id matchedAcountId;

        public ManageCustomerPortalSelfRegistrationCtrWS(Id userId){
            this.userId = userId;
        }

        public ManageCustomerPortalSelfRegistrationCtrWS(Id userId, Id matchedAcountId){
            this.userId = userId;
            this.matchedAcountId = matchedAcountId;
        }

        public ManageCustomerPortalSelfRegistrationCtrWS(String firstName, String lastName, String email,
                                                Date dateOfBirth, String postCode){
            this.firstName = firstName; 
            this.lastName = lastName;
            this.email = email;
            this.dateOfBirth = dateOfBirth;
            this.postCode = postCode;
        }

        public ManageCustomerPortalSelfRegistrationCtrWS(String firstName, String lastName, String email,
                                                Date dateOfBirth, String postCode, Id matchedAcountId){
            this.firstName = firstName; 
            this.lastName = lastName;
            this.email = email;
            this.dateOfBirth = dateOfBirth;
            this.postCode = postCode;
            this.matchedAcountId = matchedAcountId;
        }

        private String birthdateText{
            get{
                if(this.dateOfBirth != null){
                    this.birthdateText = (String.valueOf(this.dateOfBirth.day())).leftPad(2, '0') +  
                                        (String.valueOf(this.dateOfBirth.month())).leftPad(2, '0') + 
                                        String.valueOf(this.dateOfBirth.year());
                }
                return this.birthdateText;
            }
            set;
        }

        private Id personContactId{
            get{
                if(this.personContactId == null && this.matchedAcountId != null){
                    this.personContactId = [SELECT PersonContactId FROM Account WHERE Id =: this.matchedAcountId AND IsPersonAccount = true LIMIT 1].PersonContactId ;
                }
                return this.personContactId;
            }
            set;
        }

        public List<Account> getMatchBasedOnEmail(){
            List<Account> matchedAccounts;
            List<List<Sobject>> matchingAccountRecords = 
                        new FindDuplicateSObjectService().findDuplicates(new List<Account>{new Account(
                                                                        FirstName = this.firstName,
                                                                        LastName = this.lastName,
                                                                        RecordTypeId = AccountDecorator.RECORD_TYPE_ID_PERSONACCOUNT,
                                                                        PersonEmail = this.email)
                        });
            
            if(matchingAccountRecords.size() == 1){
                for(List<Sobject> matchingAccountRecordsList : matchingAccountRecords){
                    if(!matchingAccountRecordsList.isEmpty()){ 
                        matchedAccounts = new List<Account>();
                        matchedAccounts.addAll((List<Account>)matchingAccountRecordsList);
                    }
                }
            }
            return matchedAccounts;
        }

        public List<Account> matchBasedOnDOB(){
            List<Account> matchedAccounts = new List<Account>();
            List<List<Sobject>> matchingAccountRecords = 
                        new FindDuplicateSObjectService().findDuplicates(new List<Account>{new Account(
                                                                        FirstName = this.firstName,
                                                                        LastName = this.lastName,
                                                                        RecordTypeId = AccountDecorator.RECORD_TYPE_ID_PERSONACCOUNT,
                                                                        BirthdateText__pc = this.birthdateText)
                        });
            for(List<Sobject> matchingAccountRecordsList : matchingAccountRecords){
                if(!matchingAccountRecordsList.isEmpty()){ 
                    matchedAccounts.addAll((List<Account>)matchingAccountRecordsList);
                }
            }
            return matchedAccounts;
        }

        public User populatePortalUser(){
            User u = new User();
            u.Username = this.email;
            u.Email = this.email;
            u.FirstName = this.firstName;
            u.LastName = this.lastName;
            u.CommunityNickname  = ManageCustomerPortalSelfRegistrationCtr.CUSTOMER_PORTAL_NAME + Datetime.now().getTime();
            u.ProfileId = UserDecorator.PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN_ID;
            String timeString = String.valueOf(Datetime.now().getTime());
            u.Alias = timeString.substring(timeString.length() - 8);
            return u;
        }

        public void assignCustomerPortalPSG(){
            if(this.userId != null){
                Boolean alreadyAssigned = [ SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = : this.userId AND PermissionSetGroupId = : PermissionSetDecorator.YH_CUSTOMERPORTAL_PSG_ID LIMIT 1].size() > 0;
                if(!alreadyAssigned){
                    insert new PermissionSetAssignment( AssigneeId = this.userId, PermissionSetGroupId = PermissionSetDecorator.YH_CUSTOMERPORTAL_PSG_ID );
                }
            }
        }

        public User getExistingUser(){
            return [SELECT Id, IsActive FROM USER 
                WHERE Email =: this.email AND 
                    ProfileId =: UserDecorator.PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN_ID AND 
                    ContactId =: this.personContactId];
        }

        public User activateExistingUser(User u){
            u.IsActive = true;
            Database.DMLOptions dmlOpt = new Database.DMLOptions();
            dmlOpt.EmailHeader.triggerUserEmail = false;
            database.update(u, dmlOpt);
            return u;
        }

        public void passwordReset(){
            System.resetPasswordWithEmailTemplate(this.userId, true, new CustomerPortalSettingsDecorator().PasswordResetEmailTemplate);
        }
    }
}