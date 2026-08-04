@isTest
public with sharing class UthAuthenticationToken {
    public static List<AuthenticationToken__c> getAll(){
        return Database.query('SELECT '+
                String.join(new List<String>(AuthenticationToken__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM AuthenticationToken__c ');
    }
}