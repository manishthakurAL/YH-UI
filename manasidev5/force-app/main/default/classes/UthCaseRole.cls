@isTest
public with sharing class UthCaseRole {
    public static CaseRole__c build(Id caseId, Id contactId, String role){
        CaseRole__c caseRoleRecord = new CaseRole__c(
            Case__c = caseId,
            Contact__c = contactId,
            Role__c = role
        );
        return caseRoleRecord;
    }

    public static List<CaseRole__c> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(CaseRole__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM CaseRole__c ' + 
			' ORDER BY Id'
		);
    }
}