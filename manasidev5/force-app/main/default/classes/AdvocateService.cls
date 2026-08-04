public with sharing class AdvocateService {

    public  Advocate__c createAdvocate(Id AccountId, Id ContactId, AuthorityAndDetail__c authRec, String authorizationType) {
        
        Date docValidFromDate;
        if(authorizationType == AdvocateDecorator.AUTHORIZATIONTYPE_POWER_OF_ATTORNEY) {
            docValidFromDate = authRec.PowerOfAttorneyStartDate__c;
        }
        else if(authorizationType == AdvocateDecorator.AUTHORIZATIONTYPE_DELEGATED_AUTHORITY){
            docValidFromDate = authRec.DelegatedAuthorityStartDate__c;
        }
        return new Advocate__c(
            AuthorisedBy__c = AccountId,
            AuthorisedTo__c = ContactId,
            AuthorisationType__c = authorizationType,
            StartDate__c = System.today(),
            DocumentsValidFrom__c = docValidFromDate,
            SecurityPasswordPhrase__c = authRec.SecurityWordPhrase__c,
            RelationshipToCustomer__c = authRec.RelationshipToCustomer__c
            );
    }
    public  Advocate__c deactivateAdvocate(Advocate__c adv) {
            adv.EndDate__c = System.today();
            return adv;
    }
}