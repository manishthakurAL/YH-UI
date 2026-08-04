@isTest
public with sharing class UthAdvocate {
    public static Advocate__c build(Id tenantId, Id inquirerId, String authorizationType){
        Advocate__c advocateRecord = new Advocate__c(
            AuthorisedBy__c = tenantId,
            AuthorisedTo__c = inquirerId,
            AuthorisationType__c = authorizationType,
            StartDate__c = System.today().addDays(-1)
        );
        return advocateRecord;
    }
    public static List<Advocate__c> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(Advocate__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM Advocate__c' + 
            ' ORDER BY Id' 
		);
    }
}