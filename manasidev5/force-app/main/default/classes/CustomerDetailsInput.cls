public with sharing class CustomerDetailsInput {
    @AuraEnabled @InvocableVariable(label='Customer Title' required=true)
    public String title;
    @AuraEnabled @InvocableVariable(label='Customer First Name' required=true)
    public String firstName;
    @AuraEnabled @InvocableVariable(label='Customer Last Name' required=true)
    public String lastName;
    @AuraEnabled @InvocableVariable(label='Customer Middle Name' required=true)
    public String middleName;
    @AuraEnabled @InvocableVariable(label='Customer DOB' required=true)
    public Date birthdate;
    @AuraEnabled @InvocableVariable(label='Customer Gender' required=true)
    public String genderIdentity;
    @AuraEnabled @InvocableVariable(label='Customer Email' required=true)
    public String email;
    @AuraEnabled @InvocableVariable(label='Customer Mobile' required=true)
    public String mobilePhone;
    @AuraEnabled @InvocableVariable(label='Customer Pronouns' required=true)
    public String pronouns;
    @AuraEnabled @InvocableVariable(label='Customer Home Telephone Number' required=true)
    public String homePhone;
    @AuraEnabled @InvocableVariable(label='Customer Other Telephone Number' required=true)
    public String OtherPhone;
    @AuraEnabled @InvocableVariable(label='Customer Religion' required=true)
    public String yhReligionOrBelief;
    @AuraEnabled @InvocableVariable(label='Customer Main Language' required=true)
    public String yhMainLanguage;
    @AuraEnabled @InvocableVariable(label='Customer Disability' required=true)
    public String yhDisability;
    @AuraEnabled @InvocableVariable(label='Customer Forwarding Address' required=true)
    public String mailingAddress;
    @AuraEnabled @InvocableVariable(label='Customer Marital Status' required=true)
    public String yhMaritalStatus;
    @AuraEnabled @InvocableVariable(label='Customer Ethinicity' required=true)
    public String yhEthnicity;
    @AuraEnabled @InvocableVariable(label='Sexual Orientation' required=true)
    public String yhSexualOrientation;
    @AuraEnabled @InvocableVariable(label='Marketing Preference' required=true)
    public String yhMarketingPreference;
}