@IsTest
public with sharing class UthCustomerPortalSettings {
    private static final String PASSWORD_RESET_EMAIL_TEMPLATE = 'CommunityChangePasswordEmailTemplate';
    public static CustomerPortalSettings__c getOrCreateCustomerPortalSettings() {
        CustomerPortalSettings__c customerPortalSettings = CustomerPortalSettings__c.getOrgDefaults();
        if (customerPortalSettings == null) {
            customerPortalSettings = new CustomerPortalSettings__c(SetupOwnerId = UserInfo.getOrganizationId());
        }
        return customerPortalSettings;
    }

    public static void setDefaultValues() {
        CustomerPortalSettings__c customerPortalSettings = getOrCreateCustomerPortalSettings();
        customerPortalSettings.PasswordResetEmailTemplate__c = PASSWORD_RESET_EMAIL_TEMPLATE;
        customerPortalSettings.CoolOffPeriodInMinutes__c = 30;
        customerPortalSettings.MaxOTPAttempts__c = 3;
        customerPortalSettings.OTPLength__c = 8;
        customerPortalSettings.OTPTimeToLiveInSeconds__c = 600;
        customerPortalSettings.ResendCoolingPeriodInSeconds__c = 20;
        customerPortalSettings.ResendOTPLimit__c = 100;
        customerPortalSettings.ByPassMFAThresholdInDays__c = 14; 
        upsert customerPortalSettings;
    }
}