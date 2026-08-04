public with sharing class MfaSettingDecorator {
    public MFASettings__c mfaSettings;

    public MfaSettingDecorator(){
        this.mfaSettings = MFASettings__c.getInstance();
    }

    public MfaSettingDecorator(Id userOrProfileId){
        this.mfaSettings = MFASettings__c.getInstance(userOrProfileId);
    }

    public String cookieName{ 
        get{
            if(this.cookieName == null){
                this.cookieName = this?.mfaSettings?.CookieName__c != null ? 
                    this.mfaSettings.CookieName__c :
                    'yh_mfa_trust';
            }
            return this.cookieName;
        }
        private set; 
    }

    public String hmacSecret{ 
        get{
            if(this.hmacSecret == null){
                this.hmacSecret = this?.mfaSettings?.HMACSecret__c;
            }
            return this.hmacSecret;
        }
        private set; 
    }

    public Integer trustDays{ 
        get{
            if(this.trustDays == null){
                this.trustDays = this?.mfaSettings?.TrustDays__c != null ? 
                    Integer.valueOf(this.mfaSettings.TrustDays__c) :
                    60;
            }
            return this.trustDays;
        }
        private set; 
    }
}