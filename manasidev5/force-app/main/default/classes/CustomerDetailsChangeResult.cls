public with sharing class CustomerDetailsChangeResult { 
    @AuraEnabled @InvocableVariable(label='Is Title Changed' required=true)
    public Boolean isTitleChanged;
    @AuraEnabled @InvocableVariable(label='Is First Name Changed' required=true)
    public Boolean isFNChanged;
    @AuraEnabled @InvocableVariable(label='Is Last Name Changed' required=true)
    public Boolean isLNChanged;
    @AuraEnabled @InvocableVariable(label='Is Middle Name Changed' required=true)
    public Boolean isMNChanged;
    @AuraEnabled @InvocableVariable(label='Has Name Changes' required=true)
    public Boolean hasNameChanges; 
    @AuraEnabled @InvocableVariable(label='Is DOB Changed' required=true)
    public Boolean isDOBChanged;
    @AuraEnabled @InvocableVariable(label='Is Gender Identity Changed' required=true)
    public Boolean isGenderChanged;
    @AuraEnabled @InvocableVariable(label='Is Name and Title Changed' required=true)
    public Boolean isNameAndTitleChanged;
    @AuraEnabled @InvocableVariable(label='Is Name and Gender Changed' required=true)
    public Boolean isNameAndGenderChanged;
    @AuraEnabled @InvocableVariable(label='Is Email Changed' required=true)
    public Boolean isEmailChanged;
    @AuraEnabled @InvocableVariable(label='Is Mobile Changed' required=true)
    public Boolean isMobileChanged;
    @AuraEnabled @InvocableVariable(label='Is Disability Changed' required=true)
    public Boolean isDisabilityChanged;
    @AuraEnabled @InvocableVariable(label='Is Pronouns Changed' required=true)
    public Boolean isPronounsChanged;
    @AuraEnabled @InvocableVariable(label='Is Home Phone Changed' required=true)
    public Boolean isHomePhoneChanged;
    @AuraEnabled @InvocableVariable(label='Is Other Phone Changed' required=true)
    public Boolean isOtherPhoneChanged;
    @AuraEnabled @InvocableVariable(label='Is Religion Or Belief Changed' required=true)
    public Boolean isYhReligionOrBeliefChanged;
    @AuraEnabled @InvocableVariable(label='Is Main Language Changed' required=true)
    public Boolean isYhMainLanguageChanged;
    @AuraEnabled @InvocableVariable(label='Is Marital Status Changed' required=true)
    public Boolean isYhMaritalStatusChanged;
    @AuraEnabled @InvocableVariable(label='Is Ethnicity Changed' required=true)
    public Boolean isYhEthnicityChanged;
    @AuraEnabled @InvocableVariable(label='Is Mailing Address Changed' required=true)
    public Boolean isMailingAddressChanged;    
    @AuraEnabled @InvocableVariable(label='Has Other Changes' required=true)
    public Boolean hasOtherChanges;
    @AuraEnabled @InvocableVariable(label='Other Change Details' required=true)
    public String otherChangeDetails;
    @AuraEnabled @InvocableVariable(label='Is Preferred Method of Contact Changed' required=true)
    public Boolean isYhPreferredMethodofContactChanged;
    @AuraEnabled @InvocableVariable(label='Is Sexual Orientation Changed' required=true)
    public Boolean isYhSexualOrientationChanged;
    @AuraEnabled @InvocableVariable(label='Is Living Arrangements Changed' required=true)
    public Boolean isYhLivingArrangementsChanged;
    @AuraEnabled @InvocableVariable(label='Is Accessibility Requirements Changed' required=true)
    public Boolean isYhAccessibilityRequirementsChanged;

    public CustomerDetailsChangeResult() {
        isTitleChanged = false;
        isFNChanged = false; 
        isLNChanged = false; 
        isMNChanged = false; 
        isDOBChanged = false; 
        isEmailChanged = false;
        isGenderChanged = false;
        isMobileChanged = false; 
        isDisabilityChanged = false; 
        isNameAndTitleChanged = false; 
        isNameAndGenderChanged = false; 
        hasNameChanges = false;
        hasOtherChanges = false; 
        isPronounsChanged = false;
        isHomePhoneChanged = false;
        isOtherPhoneChanged = false;
        isYhReligionOrBeliefChanged = false;
        isYhMainLanguageChanged = false;
        isYhMaritalStatusChanged = false;
        isYhEthnicityChanged = false;
        isMailingAddressChanged = false;
        isYhPreferredMethodofContactChanged = false;
        isYhSexualOrientationChanged = false;
        isYhLivingArrangementsChanged = false;
        isYhAccessibilityRequirementsChanged = false;
    }
}