public with sharing class TA_Application_AU_CreateTenancy implements TriggerAction.AfterUpdate {
    public void afterUpdate(List<YH_Application__c> newList, List<YH_Application__c> oldList){
        List<YH_Application__c> agreementSingedApplications = new List<YH_Application__c>();
        Map<Id,YH_Application__c> oldMap = new Map<Id,YH_Application__c>(oldList);
        for (YH_Application__c application : newList) {
            if ( application.TenancyAgreementSigned__c == ApplicationDecorator.YES
                    && application.TenancyAgreementSigned__c != oldMap.get(application.Id).TenancyAgreementSigned__c) {
                agreementSingedApplications.add(application);
            }
        }
        if (!agreementSingedApplications.isEmpty()) {
            TenancyService.getInstance(agreementSingedApplications).createTenancy(); 
        }
    }
}