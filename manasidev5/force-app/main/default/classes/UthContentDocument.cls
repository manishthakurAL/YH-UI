@isTest
public with sharing class UthContentDocument {
    public static ContentDocument[] getAll() {
        return Database.query('SELECT '+
			String.join(new List<String>(ContentDocument.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM ContentDocument ' + 
			' ORDER BY Id'
		);
    }
}