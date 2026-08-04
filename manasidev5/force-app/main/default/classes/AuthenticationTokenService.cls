public with sharing class AuthenticationTokenService {
    private AuthenticationToken__c authToken;

    public AuthenticationTokenService(AuthenticationToken__c authToken){
        this.authToken = authToken;
    }
    public AuthenticationToken__c createAuthToken(String salt, String otpHash, Datetime expiresAt, String contactPoint, String methodType){
        this.authToken.Salt__c = salt;
        this.authToken.User__c = UserInfo.getUserId();
        this.authToken.Method__c = methodType;
        this.authToken.ContactPoint__c = contactPoint;
        this.authToken.OTPHash__c = otpHash;
        this.authToken.ExpiresAt__c = expiresAt;
        this.authToken.Status__c = OtpService.STATUS.PENDING.name();
        this.authToken.NumberOfAttempts__c = this.authToken.NumberOfAttempts__c == null ? 0 : this.authToken.NumberOfAttempts__c;
        this.authToken.NumberOfTimesOTPSent__c = this.authToken.NumberOfTimesOTPSent__c == null ? 1 : this.authToken.NumberOfTimesOTPSent__c + 1;
        upsert this.authToken;
        return this.authToken;
    }

    public AuthenticationToken__c authTokenVerified(){
        this.incrementNumberOfAttempt();
        this.authToken.Status__c = OtpService.STATUS.VERIFIED.name();
        this.authToken.VerifiedOn__c = Datetime.now();
        upsert this.authToken;
        return this.authToken;
    }

    public AuthenticationToken__c authTokenLocked(){
        this.incrementNumberOfAttempt();
        this.authToken.LockedAt__c = DateTime.Now();
        this.authToken.Status__c = OtpService.STATUS.LOCKED.name();
        upsert this.authToken;
        return this.authToken;
    }

    public AuthenticationToken__c authTokenLockedDueToResendLimit(){
        this.authToken.LockedAt__c = DateTime.Now();
        this.authToken.Status__c = OtpService.STATUS.LOCKED.name();
        upsert this.authToken;
        return this.authToken;
    }

    private AuthenticationToken__c incrementNumberOfAttempt(){
        this.authToken.NumberOfAttempts__c++;
        return this.authToken;
    }

    public AuthenticationToken__c incrementToken(){
        this.incrementNumberOfAttempt();
        upsert this.authToken;
        return this.authToken;
    }

    public AuthenticationToken__c incrementNumberOfTimesOTPSent(){
        this.authToken.NumberOfTimesOTPSent__c++;
        return this.authToken;
    }
}