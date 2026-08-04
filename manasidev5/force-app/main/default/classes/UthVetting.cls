@isTest
public with sharing class UthVetting {
    public static Vetting__c buildVetting(Id applicationId, Id applicantId){
        Vetting__c avetting = new Vetting__c (Application__c = applicationId,
        Applicant__c = applicantId,
        Concerns__c = 'No concerns',
        SystemChecksCompleted__c = ApplicationDecorator.NO
        );
        return avetting;
    }
}