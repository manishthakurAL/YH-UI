@isTest
public with sharing class UthApplicant {

    public static List<Applicant__c> getAll(){
        return Database.query('SELECT '+
            String.join(new List<String>(Applicant__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
            ' FROM Applicant__c ' + 
            ' ORDER BY Id'
        );
    }

    public static Applicant__c buildApplicant(Id contactId, Id applicationId){
        Applicant__c aApplicant = new Applicant__c(
            Contact__c = contactId,
            Application__c = applicationId,
            EnforcementAction__c = ApplicationDecorator.NO,
            IdentityVerificationProof__c = ApplicationDecorator.NO,
            PreviousYHTenancy__c =ApplicationDecorator.NO,
            Previoushomeowner__c = ApplicationDecorator.NO,
            ApplicantHasAPartner__c = ApplicationDecorator.NO,
            OneMonthBankStatementProvided__c = ApplicationDecorator.NO,
            ApplicantType__c = MemberDecorator.TYPE_SOLO
        );
        return aApplicant;
    }
}