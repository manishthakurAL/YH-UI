@isTest
public with sharing class UthPermissions {
    public static List<Permissions__c> getAll(){
        return Database.query('SELECT '+
            String.join(new List<String>(Permissions__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
                        //add more feilds from related object as and wehn required
            ' FROM Permissions__c '
        );
    }
}