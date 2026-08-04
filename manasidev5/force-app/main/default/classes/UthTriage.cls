@isTest
public with sharing class UthTriage {
   
    public static Triage__c build(Id caseId, Id contactId){
        Triage__c triageRecord = new Triage__c(
            Contact__c = contactId,
            Case__c = caseId,
            Income__c = 'No income',
            Debts__c = 'No debt',
            Employment__c = 'Employed'
        );
        return triageRecord;
    }
    
    public static List<Triage__c> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(Triage__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
                        //add more feilds from related object as and wehn required
			' FROM Triage__c '
		);
    }
}