@isTest
public class UthMfaSettings {
    public static MFASettings__c build(){
        return new MFASettings__c();
    }

    public static MFASettings__c cretaeMfaSettings(){
         MFASettings__c mfaSetting = build();
         mfaSetting.CookieName__c = 'yh_mfa_trust';
         mfaSetting.TrustDays__c = 60;
         mfaSetting.HMACSecret__c = '87sgv87sg87gs87vgsgs8878sf8';
         insert mfaSetting;
         return mfaSetting;
    }
}