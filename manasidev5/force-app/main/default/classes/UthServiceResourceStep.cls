@isTest
public with sharing class UthServiceResourceStep {
    public static ServiceResourceStep__c create(){
        ServiceResourceStep__c srs = new ServiceResourceStep__c();
        srs.ServiceResource__c = UthServiceResource.create().Id;
        Insert srs;
        return srs;
    }
    
     public static ServiceResourceStep__c create(Id serviceResourceId){
        ServiceResourceStep__c srs = new ServiceResourceStep__c();
        srs.ServiceResource__c = serviceResourceId;
        Insert srs;
        return srs;
    }
    
    public static List<ServiceResourceStep__c> getAll(){
            return Database.query('SELECT '+
                    String.join(new List<String>(ServiceResourceStep__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                    + ' FROM ServiceResourceStep__c');
        
    }
}