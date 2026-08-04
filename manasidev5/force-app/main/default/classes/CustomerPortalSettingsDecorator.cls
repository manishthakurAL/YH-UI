public with sharing class CustomerPortalSettingsDecorator {
    public CustomerPortalSettings__c customerPortalSettings;

    public CustomerPortalSettingsDecorator(){
        this.customerPortalSettings = CustomerPortalSettings__c.getInstance();
    }

    public CustomerPortalSettingsDecorator(Id userOrProfileId){
        this.customerPortalSettings = CustomerPortalSettings__c.getInstance(userOrProfileId);
    }

    public Integer otpTimeToLiveInSeconds{ 
        get{
            if(this.otpTimeToLiveInSeconds == null){
                this.otpTimeToLiveInSeconds = this.customerPortalSettings.OTPTimeToLiveInSeconds__c != null ? 
                    Integer.valueOf(this.customerPortalSettings.OTPTimeToLiveInSeconds__c) :
                    600;
            }
            return this.otpTimeToLiveInSeconds;
        }
        private set; 
    }

    public Integer otpLength{ 
        get{
            if(this.otpLength == null){
                this.otpLength = this.customerPortalSettings.OTPLength__c != null ? 
                    Integer.valueOf(this.customerPortalSettings.OTPLength__c) :
                    8;
            }
            return this.otpLength;
        }
        private set; 
    }

    public Integer maxOTPAttempts{ 
        get{
            if(this.maxOTPAttempts == null){
                this.maxOTPAttempts = this.customerPortalSettings.MaxOTPAttempts__c != null ? 
                    Integer.valueOf(this.customerPortalSettings.MaxOTPAttempts__c) :
                    3;
            }
            return this.maxOTPAttempts;
        }
        private set; 
    }

    public Integer resendCoolingPeriodInSeconds{ 
        get{
            if(this.resendCoolingPeriodInSeconds == null){
                this.resendCoolingPeriodInSeconds = this.customerPortalSettings.ResendCoolingPeriodInSeconds__c != null ? 
                    Integer.valueOf(this.customerPortalSettings.ResendCoolingPeriodInSeconds__c) :
                    20;
            }
            return this.resendCoolingPeriodInSeconds;
        }
        private set;
    }

    public Integer coolOffPeriodInMinutes{ 
        get{
            if(this.coolOffPeriodInMinutes == null){
                this.coolOffPeriodInMinutes = this.customerPortalSettings.CoolOffPeriodInMinutes__c != null ? 
                    Integer.valueOf(this.customerPortalSettings.CoolOffPeriodInMinutes__c) :
                    30;
            }
            return this.coolOffPeriodInMinutes;
        }
        private set; 
    }

    public Integer resendOTPLimit{ 
        get{
            if(this.resendOTPLimit == null){
                this.resendOTPLimit = this.customerPortalSettings.ResendOTPLimit__c != null ? 
                    Integer.valueOf(this.customerPortalSettings.ResendOTPLimit__c) :
                    1000;
            }
            return this.resendOTPLimit;
        }
        private set; 
    }

    public Integer byPassMFAThresholdInDays{ 
        get{
            if(this.byPassMFAThresholdInDays == null){
                this.byPassMFAThresholdInDays = this.customerPortalSettings.ByPassMFAThresholdInDays__c != null ? 
                    Integer.valueOf(this.customerPortalSettings.ByPassMFAThresholdInDays__c) :
                    14;
            }
            return this.byPassMFAThresholdInDays;
        }
        private set; 
    }

    public Integer sessionDiscardThresholdInMinutes{ 
        get{
            if(this.sessionDiscardThresholdInMinutes == null){
                this.sessionDiscardThresholdInMinutes = this.customerPortalSettings.SessionDiscardThresholdInMinutes__c != null ? 
                    Integer.valueOf(this.customerPortalSettings.SessionDiscardThresholdInMinutes__c) :
                    60;
            }
            return this.sessionDiscardThresholdInMinutes;
        }
        private set; 
    }

    public String passwordResetEmailTemplate{ 
        get{
            if(this.passwordResetEmailTemplate == null){
                this.passwordResetEmailTemplate = this.customerPortalSettings.PasswordResetEmailTemplate__c != null ? 
                    this.customerPortalSettings.PasswordResetEmailTemplate__c :
                    'CommunityChangePasswordEmailTemplate';
            }
            return this.passwordResetEmailTemplate;
        }
        private set; 
    }

    public String yhLogoSiteURL{ 
        get{
            this.yhLogoSiteURL = this.customerPortalSettings.yhLogoSiteURL__c;
            return this.yhLogoSiteURL;
        }
        private set; 
    }
}