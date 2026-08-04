@isTest
public with sharing class UthTenancyIncident {

    public static TenancyIncident__c updateRequiredDetailsForTenancyIncidentAbandonedProperty(Id caseId){
        TenancyIncident__c tcRec = [SELECT Id, NTQExpiredDate__c FROM TenancyIncident__c WHERE Case__c =: caseId][0];
        tcRec.NTQExpiredDate__c = Date.today();
        update tcRec ;
        return tcRec;
    }

    public static List<TenancyIncident__c> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(TenancyIncident__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM TenancyIncident__c '
		);
    }
}