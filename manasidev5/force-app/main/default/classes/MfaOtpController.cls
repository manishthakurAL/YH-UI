public with sharing class MfaOtpController {

    private static final String LOGOUT_URL = '/secur/logout.jsp';
    private static final String CHANGE_PASSWORD_VALUE = 'changepassword';
    private static final String RETURN_URL_KEY = 'retURL';

    public Boolean showEmailOverride { get; private set; }

    public Datetime lastSendAt { get; set;}
    public Boolean otpSent { get; private set; }
    public Integer ttlRemaining { get; private set; }
    public String selectedMethod { get; set; }
    public String otpEntered { get; set; }
    public Boolean verificationSucceeded { get; private set; }
    public Integer currentAttempt {get; private set;}
    public Boolean isAccountLocked {get; private set;}

    public Integer ttlInSeconds{ get; private set; }
    public Integer otpLength{ get; private set; }
    public Integer maxAttempts{ get; private set; }
    
    private Boolean isChangePasswordAttempt { 
        get {
            this.isChangePasswordAttempt = false;
            Map<String, String> params = ApexPages.currentPage().getParameters();
            String retURL = params.containsKey(RETURN_URL_KEY) ? params.get(RETURN_URL_KEY) : null;
            this.isChangePasswordAttempt = (String.isNotBlank(retURL) && retURL.containsIgnoreCase(CHANGE_PASSWORD_VALUE));
            return this.isChangePasswordAttempt;
        }
        private set; 
    }

    private AuthenticationToken__c verfiedAuthToken {
        get {
            if (this.verfiedAuthToken == null) {
                List<AuthenticationToken__c> token = [SELECT Id, VerifiedOn__c, ByPassMFA__c
                    FROM AuthenticationToken__c 
                    WHERE Status__c =: AuthenticationTokenDecorator.STATUS_VERIFIED AND 
                        VerifiedOn__c != null AND
                        User__c =: UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1];
                if(!token.isEmpty()){
                    this.verfiedAuthToken = token[0];
                }
            }
            return this.verfiedAuthToken;
        }
        private set;
    }

    private AuthenticationToken__c existingAuthToken {
        get {
            if (this.existingAuthToken == null) {
                List<AuthenticationToken__c> token = [SELECT Id, Name, ExpiresAt__c, LockedAt__c, NumberOfAttempts__c, CreatedDate, AutorizationLocked__c, NumberOfTimesOTPSent__c, VerifiedOn__c
                    FROM AuthenticationToken__c 
                    WHERE (Status__c =: AuthenticationTokenDecorator.STATUS_PENDING OR
                        Status__c =: AuthenticationTokenDecorator.STATUS_LOCKED) AND 
                        User__c =: UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1];
                if(!token.isEmpty()){
                    this.existingAuthToken = token[0];
                }
            }
            return this.existingAuthToken;
        }
        private set;
    }

    private User currentUser {
        get {
            if (this.currentUser == null) {
                this.currentUser = [SELECT Id, Email, Contact.MobilePhone
                    FROM User 
                    WHERE Id = :UserInfo.getUserId()];
            }
            return currentUser;
        }
        private set;
    }

    public String maskedMobile {
        get {
            String phone = currentUser.Contact.MobilePhone;
            if (String.isBlank(phone)) return '';
            String cleanPhone = phone.replaceAll('[^0-9]', ''); 
            return '********' + (cleanPhone.length() > 3 ? cleanPhone.substring(cleanPhone.length() - 3) : cleanPhone);
        }
    }

    public String maskedEmail {
        get {
            String email = currentUser.Email;
            if (String.isBlank(email) || !email.contains('@')) return '';
            
            String[] parts = email.split('@');
            String namePart = parts[0];
            String domainPart = parts[1];
            
            return maskSegment(namePart) + '@' + maskDomain(domainPart);
        }
    }

    private String maskSegment(String segment) {
        if (segment.length() <= 2) return segment;
        return segment.substring(0, 2) + '********';
    }

    private String maskDomain(String domain) {
        String[] domainParts = domain.split('\\.');
        List<String> maskedParts = new List<String>();
        for (String p : domainParts) {
            maskedParts.add(maskSegment(p));
        }
        return String.join(maskedParts, '.');
    }

    public void toggleEmailOverride() {
        this.showEmailOverride = true;
    }


    public Boolean isSMSAllowed{
        get {
            this.isSMSAllowed = FALSE;
            if(this.currentUser != null){
                this.isSMSAllowed = this.currentUser.Contact.MobilePhone != null ? TRUE : FALSE;
            }
            return this.isSMSAllowed;
        }
        private set;
    }

    public CustomerPortalSettingsDecorator customPortalSettings{
        get{
            if(this.customPortalSettings == null){
                this.customPortalSettings = new CustomerPortalSettingsDecorator();
            }
            return this.customPortalSettings; 
        }
        private set;
    }

    private AuthenticationToken__c currentAuthToken;
    private AuthenticationTokenService authTokenService;
    OtpService.METHOD methodType;

    public MfaOtpController() {
        this.showEmailOverride = false;
        this.otpLength = customPortalSettings.otpLength;
        this.ttlRemaining = this.ttlInSeconds = customPortalSettings.otpTimeToLiveInSeconds;
        this.maxAttempts = customPortalSettings.maxOTPAttempts;
        
        if(!this.isChangePasswordAttempt && this.isUserAccountLocked()){
            this.userAccountLockedValidation(this.existingAuthToken);
        } else{
            this.instantiateAuthToken();
            authTokenService = new AuthenticationTokenService(this.currentAuthToken);
        }
    }

    public PageReference doInit(){
        PageReference PageReference;
        if(this.verfiedAuthToken != null && this.verfiedAuthToken.ByPassMFA__c != null && !this.isChangePasswordAttempt){
            if(this.verfiedAuthToken.ByPassMFA__c == TRUE){
                PageReference = Auth.SessionManagement.finishLoginFlow();
            }
        }
        return PageReference;
    }

    private Boolean isUserAccountLocked(){
        this.isAccountLocked = false;
        if(this.existingAuthToken != null){
            if(this.existingAuthToken.AutorizationLocked__c == TRUE ){
                this.isAccountLocked = true;      
            }
        }
        return this.isAccountLocked;
    }

    private PageReference userAccountLockedValidation(AuthenticationToken__c authToken){
        Long inSeconds = (authToken.LockedAt__c.addMinutes(customPortalSettings.coolOffPeriodInMinutes).getTime() - Datetime.now().getTime()) / 1000;
        String timeLeft = formatMessage(inSeconds);
        ApexPages.addMessage(
            new ApexPages.Message(
                ApexPages.Severity.ERROR,
                Label.AccountLockedMessage.replace('{{timeLeft}}', timeLeft)
            )
        );
        return null;
    }

    private void instantiateAuthToken(){
        if(this.existingAuthToken != null && this.existingAuthToken.NumberOfAttempts__c < customPortalSettings.maxOTPAttempts){
            this.currentAuthToken = this.existingAuthToken;
            this.currentAttempt = Integer.valueOf(this.existingAuthToken.NumberOfAttempts__c) + 1;
        } else {
            this.currentAuthToken = new AuthenticationToken__c();
            this.currentAttempt = 1;
        }
        this.otpSent = false;
        this.verificationSucceeded = false;
    }

    private PageReference sessionLockedDueToResendLimit(){
        this.currentAuthToken = authTokenService.authTokenLockedDueToResendLimit();
        Long inSeconds = (this.currentAuthToken.LockedAt__c.addMinutes(customPortalSettings.coolOffPeriodInMinutes).getTime() - Datetime.now().getTime()) / 1000;
        String timeLeft = formatMessage(inSeconds);
        this.isAccountLocked = true;
        ApexPages.addMessage(
            new ApexPages.Message(
                ApexPages.Severity.ERROR, 
                Label.AccountLockedResendLimitMessage.replace('{{timeLeft}}', timeLeft)
            )
        );
        return null;
    }

    private Boolean reachedResendLimit(){
        Boolean reachedResendLimit = false;
        if(this.currentAuthToken.NumberOfTimesOTPSent__c != null && this.currentAuthToken.ExpiresAt__c != null){
            if(this.currentAuthToken.NumberOfTimesOTPSent__c >= customPortalSettings.resendOTPLimit){
                reachedResendLimit = true;
            }
        }
        return reachedResendLimit;
    }

    public PageReference resendCode(){
        if (this.lastSendAt != null) {
            Integer elapsed = Integer.valueOf(Datetime.now().getTime() - this.lastSendAt.getTime())/1000;
            Integer remainingForResend = Math.max(0, customPortalSettings.resendCoolingPeriodInSeconds - elapsed); 
            if (remainingForResend > 0) {
                Integer remainingForAttempt = Math.max(0, this.ttlInSeconds - elapsed); 
                if (remainingForAttempt > 0) {
                    this.ttlRemaining = remainingForAttempt;
                } 
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.WARNING,
                        Label.ResendTimeLeftMessage.replace('{{remaining}}', String.ValueOf(remainingForResend))
                    )
                );
            } else {
                this.sendCode();
            }
        }
        return null;
    }

    public PageReference sendCode(){
        if(this.reachedResendLimit()){
            this.sessionLockedDueToResendLimit();
        } else {
            if(this.selectedMethod != null && (this.selectedMethod == OtpService.METHOD.EMAIL.name() || this.selectedMethod == OtpService.METHOD.SMS.name())){
                String contactPoint;
                if(this.selectedMethod == OtpService.METHOD.EMAIL.name()){
                    this.methodType = OtpService.METHOD.EMAIL;
                    contactPoint = this.currentUser.Email;
                } else if(this.selectedMethod == OtpService.METHOD.SMS.name()){
                    this.methodType = OtpService.METHOD.SMS;
                    contactPoint = this.currentUser.Contact.MobilePhone;
                }

                String otp = generateOTP(contactPoint);

                try{
                    IOtpSender otpSenderInstance = new OtpSenderFactory(this.methodType).getInstance();
                    otpSenderInstance.sendOtp(otp);

                    this.otpSent = true;
                    this.lastSendAt = Datetime.now();
                    this.ttlRemaining = this.ttlInSeconds;

                    ApexPages.addMessage(
                        new ApexPages.Message(
                            ApexPages.Severity.CONFIRM, 
                            Label.OtpCodeSendSuccessMessage
                        )
                    );
                } catch (Exception e){
                    ApexPages.addMessage(
                        new ApexPages.Message(
                            ApexPages.Severity.ERROR, 
                            Label.OtpCodeSendFailedMessage
                        )
                    );
                }
            } else {
                ApexPages.addMessage(
                    new ApexPages.Message(
                        ApexPages.Severity.ERROR, 
                        Label.OtpSelectValidDeliveryMethod
                    )
                );
            }
        }
        return null;
    }

    private String generateOTP(String contactPoint){
        OtpService otpSer = new OtpService();
        String otp = otpSer.generateOtp();
        String salt = otpSer.createSalt();
        String hash = otpSer.hashOtp(otp, salt);
        Datetime expiresAt = Datetime.now().addSeconds(this.ttlInSeconds);
        this.currentAuthToken = authTokenService.createAuthToken(salt, hash, expiresAt, contactPoint, this.methodType.name());
        return otp;
    }

    public PageReference verifyCode() {
        PageReference PageReference;
        Integer elapsed = Integer.valueOf(Datetime.now().getTime() - this.lastSendAt.getTime())/1000;
        Integer remaining = Math.max(0, this.ttlInSeconds - elapsed); 
        if (remaining > 0) {
            this.ttlRemaining = remaining;
        } 
        
        if (String.isBlank(this.otpEntered)) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR, 
                    Label.EnterOtpMessage
                )
            );
        } else if (this.currentAuthToken.ExpiresAt__c < Datetime.now()) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR, 
                    Label.OtpCodeExpiredMessage
                )
            );
        } else {
            this.currentAttempt = this.currentAttempt + 1;

            OtpService otpSer = new OtpService();
            this.verificationSucceeded = otpSer.verifyOtp(
                this.otpEntered,
                this.currentAuthToken.OTPHash__c,
                this.currentAuthToken.Salt__c
            );

            if(this.verificationSucceeded){
                this.currentAuthToken = authTokenService.authTokenVerified();
                PageReference = Auth.SessionManagement.finishLoginFlow();
            } else {
                Integer remainingAttempts = customPortalSettings.maxOTPAttempts - this.currentAttempt;
                if(remainingAttempts < 0){
                    this.currentAuthToken = authTokenService.authTokenLocked();
                    this.isAccountLocked = true;
                    this.userAccountLockedValidation(this.currentAuthToken);
                } else {
                    this.currentAuthToken = authTokenService.incrementToken();
                    String remainingAttemptMergeValue = String.ValueOf(remainingAttempts + 1);
                    ApexPages.addMessage(
                        new ApexPages.Message(
                            ApexPages.Severity.ERROR, 
                            Label.OtpCodeInvalid.replace('{{remainingAttempts}}', remainingAttemptMergeValue)
                        )
                    );
                }
            }
        }
        return PageReference;
    }

    public static String formatMessage(Long timeLeftInSeconds) {
        String timeLeft;
        Integer value = Integer.valueOf(timeLeftInSeconds);
        if (value < 60) {
            Integer seconds = value;
            timeLeft = seconds + ' ' + (seconds == 1 ? 'second' : 'seconds');
        }else if (value < 3600) {
            Integer minutes = value / 60;
            timeLeft =  minutes + ' ' + (minutes == 1 ? 'minute' : 'minutes');
        }else {
            Integer hours = value / 3600;
            timeLeft = hours + ' ' + (hours == 1 ? 'hour' : 'hours');
        }
        return timeLeft;
    }

    private PageReference getCommunityLogoutPage(){
        String communityLogoutURL = Site.getBaseUrl() + LOGOUT_URL;
        PageReference page = new PageReference(communityLogoutURL);
        page.setRedirect(true);
        return page;
    }

    public PageReference backToLoginPage(){
        return getCommunityLogoutPage();
    }
}