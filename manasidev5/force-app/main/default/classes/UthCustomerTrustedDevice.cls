@isTest
public with sharing class UthCustomerTrustedDevice {
    public static CustomerTrustedDevice__c serExpiryDateTime(CustomerTrustedDevice__c ctd, Datetime expDateTime){
        ctd.ExpiresAt__c = expDateTime;
        return ctd;
    }

    public static List<CustomerTrustedDevice__c> getAll(){
        return Database.query('SELECT '+
                String.join(new List<String>(CustomerTrustedDevice__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM CustomerTrustedDevice__c');
    }

    public static List<CustomerTrustedDevice__c> getCustomerTrustedDevicesByIserId(Id userId){
        return Database.query('SELECT '+
                String.join(new List<String>(CustomerTrustedDevice__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM CustomerTrustedDevice__c'
                + ' WHERE User__c = \'' + userId + '\'');
    }

     public static CustomerTrustedDevice__c create(Id userId){
        CustomerTrustedDevice__c ctd = new CustomerTrustedDevice__c();
        ctd.ExpiresAt__c = Datetime.now().addDays(7);
        ctd.User__c = userId;
        ctd.FirstTrustedAt__c = Datetime.now();
        insert ctd;
        return ctd;
    }
}