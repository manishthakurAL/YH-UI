public with sharing class CaseRoleService {
    public CaseRole__c populateCaseRole(Id caseId, Id contactId, String role) {
        return new CaseRole__c(
            Case__c = caseId,
            Contact__c = contactId,
            Role__c = role
        );
    }
}