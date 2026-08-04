@isTest
public with sharing class UthMonitoringForm {
    public static List<Monitoring_Form__c> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(Monitoring_Form__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM Monitoring_Form__c '
		);
    }
}