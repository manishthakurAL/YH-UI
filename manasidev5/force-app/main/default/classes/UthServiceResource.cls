@isTest
public with sharing class UthServiceResource {
    public static list<ServiceResource> getAll(){
        return Database.query('SELECT '+
                String.join(new List<String>(ServiceResource.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM ServiceResource');
    }

    public static ServiceResource create(){
      ServiceResource sr = new ServiceResource();
      sr.RelatedRecordId = UserInfo.getUserId();
      sr.Name = UserInfo.getName();
      sr.IsActive = true;
      Insert sr;
      return sr;
    }
}