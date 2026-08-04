@isTest
public with sharing class UthAwaabsLaw {
    
    public static AwaabsLaw__c createTestAwaabsLaw(Id caseId, Boolean withAssessment) {
        AwaabsLaw__c aw = new AwaabsLaw__c(
            Case__c = caseId,
            AssessmentInformation__c = withAssessment ? '<h1>Assessment Info</h1>' : null
        );
        return aw;
    }

}