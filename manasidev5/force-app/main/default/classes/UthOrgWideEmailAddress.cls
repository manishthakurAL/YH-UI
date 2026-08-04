@isTest
public with sharing class UthOrgWideEmailAddress {
    public static List<OrgWideEmailAddress> getAll(){
        return Database.query('SELECT '+
                String.join(new List<String>(OrgWideEmailAddress.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM OrgWideEmailAddress');
    }
}