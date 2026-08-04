public with sharing class TA_Advocate_AIU_ManageAlert implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate{
    
    public void afterInsert(List<Advocate__c> newList){
        List<Advocate__c> advocateList = new List<Advocate__c>();   
        for(Advocate__c adRec : newList){
            if(AdvocateDecorator.AUTHORIZATIONTYPE_ALERT_LIST.contains(adRec.AuthorisationType__c)){
                advocateList.add(adRec);
            }
        }

        if(!advocateList.isEmpty()){
            ManageAlertBasedOnSobjectFactory.getInstance(newList.getSObjectType())?.setUpAlerts(advocateList, null);
        }
    }

    public void afterUpdate(List<Advocate__c> newList, List<Advocate__c> oldList){
        List<Advocate__c> advocateList = new List<Advocate__c>();
        Map<Id, Advocate__c> oldMap = new Map<Id, Advocate__c>(oldList);
        for(Advocate__c adRec : newList){
            if(AdvocateDecorator.AUTHORIZATIONTYPE_ALERT_LIST.contains(adRec.AuthorisationType__c) && 
                        (adRec.EndDate__c != oldMap.get(adRec.Id).EndDate__c ||
                        adRec.StartDate__c != oldMap.get(adRec.Id).StartDate__c)){
                advocateList.add(adRec);
            }
        }        
        
        if(!advocateList.isEmpty()){
            ManageAlertBasedOnSobjectFactory.getInstance(newList.getSObjectType())?.setUpAlerts(advocateList, null);
        }
    }
}