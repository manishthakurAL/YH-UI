public with sharing class FeatureFlags {

    private Case caseRecord;

    public FeatureFlags(Case caseRecord) {
        this.caseRecord = caseRecord;
    }

    public Boolean isNewMCCFlowVersion(){
        return this.caseRecord.CaseFeatureSwitches__c != null ? this.caseRecord.CaseFeatureSwitches__c.Contains(CaseDecorator.CASEFEATURE_NEW_MCC_FLOW) : false;
    }

    public Boolean isCreatedviascheduledFlow(){
        return this.caseRecord.CaseFeatureSwitches__c != null ? this.caseRecord.CaseFeatureSwitches__c.Contains(CaseDecorator.CASEFEATURE_CREATED_BY_SCHEDULED_FLOW) : false;
    }
}