@IsTest
public with sharing class UthFeatureSwitches {

    public static FeatureSwitches__c getOrCreateFeatureSwitches() {
        FeatureSwitches__c featureSwitches = FeatureSwitches__c.getOrgDefaults();
        
        if (featureSwitches == null) {
            featureSwitches = new FeatureSwitches__c(SetupOwnerId = UserInfo.getOrganizationId());
        }
        
        return featureSwitches;
    }

    public static void enableCaseChangesRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCaseChangesRT__c = true;
        upsert featureSwitches;
    }

    public static void enableCaseComplaintsRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCaseComplaintsRT__c = true;
        upsert featureSwitches;
    }

    public static void EnableCaseGeneralEnquiryRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCaseGeneralEnquiryRT__c = true;
        upsert featureSwitches;
    }

    public static void enableCaseLettingRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCaseLettingRT__c = true;
        upsert featureSwitches;
    }

    public static void enableCaseMoneyCoachingRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCaseMoneyCoachingRT__c = true;
        upsert featureSwitches;
    }

    public static void enableCaseOmbudsmanFirstRequestRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCaseOmbudsmanFirstRequest__c = true;
        upsert featureSwitches;
    }

    public static void enableCasePermissionRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCasePermissionRT__c = true;
        upsert featureSwitches;
    }

    public static void enableCasePlaceRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCasePlaceRT__c = true;
        upsert featureSwitches;
    }

    public static void enableCaseSchemesRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCaseSchemesRT__c = true;
        upsert featureSwitches;
    }

    public static void enableCaseTenancyCoachingRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCaseTenancyCoachingRT__c = true;
        upsert featureSwitches;
    }

    public static void enableCaseTenancyRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCaseTenancyRT__c = true;
        upsert featureSwitches;
    }

    public static void enableCaseTerminationRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCaseTerminationRT__c = true;
        upsert featureSwitches;
    }

    public static void enableCaseBreachAntiSocialBehaviourRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCaseBreachAntiSocialBehaviourRT__c = true;
        upsert featureSwitches;
    }

    public static void enableCustomerFeedbackRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCustomerFeedbackRT__c = true;
        upsert featureSwitches;
    }

    public static void enableCustomerRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCustomerRT__c = true;
        upsert featureSwitches;
    }

    public static void enableSafeguardingRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCaseSafeguardingRT__c = true;
        upsert featureSwitches;
    }

    public static void enableEmailResponseRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCaseEmailResponseRT__c = true;
        upsert featureSwitches;
    }

    public static void enableManagedMoveRT() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCaseManagedMoveRT__c = true;
        upsert featureSwitches;
    } 

    public static void enableByPassCaseMilestoneRecalcLogic() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.BypassCaseMilestoneRecalcLogic__c = true;
        upsert featureSwitches;
    }

    public static void disableByPassCaseMilestoneRecalcLogic() {
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.BypassCaseMilestoneRecalcLogic__c = false;
        upsert featureSwitches;
    }
    
    public static void enableAllRT(){
        FeatureSwitches__c featureSwitches = getOrCreateFeatureSwitches();
        featureSwitches.EnableCaseChangesRT__c = true;
        featureSwitches.EnableCaseComplaintsRT__c = true;
        featureSwitches.EnableCaseGeneralEnquiryRT__c = true;
        featureSwitches.EnableCaseLettingRT__c = true;
        featureSwitches.EnableCaseMoneyCoachingRT__c = true;
        featureSwitches.EnableCaseOmbudsmanFirstRequest__c = true;
        featureSwitches.EnableCasePermissionRT__c = true;
        featureSwitches.EnableCasePlaceRT__c = true;
        featureSwitches.EnableCaseSchemesRT__c = true;
        featureSwitches.EnableCaseTenancyCoachingRT__c = true;
        featureSwitches.EnableCaseTenancyRT__c = true;
        featureSwitches.EnableCaseTerminationRT__c = true;
        featureSwitches.EnableCaseBreachAntiSocialBehaviourRT__c = true;
        featureSwitches.EnableCustomerFeedbackRT__c = true;
        featureSwitches.EnableCustomerRT__c = true;
        featureSwitches.EnableCaseSafeguardingRT__c = true;
        featureSwitches.EnableCaseEmailResponseRT__c = true;
        featureSwitches.EnableCaseManagedMoveRT__c = true;
        upsert featureSwitches;
    }

}