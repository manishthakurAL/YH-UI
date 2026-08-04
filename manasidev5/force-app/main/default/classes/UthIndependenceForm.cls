@isTest
public with sharing class UthIndependenceForm {
    public static List<IndependenceForm__c> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(IndependenceForm__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM IndependenceForm__c '
		);
    }
}