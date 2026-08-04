public with sharing class TA_SMSMagicRequestEvent_AI_SendSMS implements TriggerAction.AfterInsert{
    
    public void afterInsert(List<SMSMagicRequestEvent__e> SMSRequestList){
        List<Id> contactIdList = new List<Id>();
         Map<Id,Contact> contactByIdMap;
        List<smagicinteract__smsMagic__c> smsHistoryList = new List<smagicinteract__smsMagic__c>();
        for (SMSMagicRequestEvent__e smsRequest : SMSRequestList) {
            contactIdList.add(smsRequest.ContactId__c);
        }
        if(!contactIdList.isEmpty()){
            contactByIdMap = new Map<Id, Contact>([SELECT Id, Name, MobilePhone
                                           FROM Contact
                                           WHERE Id IN :contactIdList]);
            String objectType = Contact.SObjectType.getDescribe().getName();                               
            for (SMSMagicRequestEvent__e smsRequest : SMSRequestList) {
                    smagicinteract__smsMagic__c smsRecord = new smagicinteract__smsMagic__c(
                        smagicinteract__SenderId__c = smsRequest.SenderId__c,
                        smagicinteract__PhoneNumber__c = contactByIdMap.get(smsRequest.ContactId__c).MobilePhone,
                        smagicinteract__Name__c = contactByIdMap.get(smsRequest.ContactId__c).Name,
                        smagicinteract__ObjectType__c = objectType,
                        smagicinteract__disableSMSOnTrigger__c = SMSMagicDecorator.SMS_DELIVER,
                        smagicinteract__Contact__c = smsRequest.ContactId__c,
                        smagicinteract__SMS_Template__c = smsRequest.TemplateId__c,
                        smagicinteract__SMSText__c = smsRequest.Message__c,
                        RequestedBy__c = smsRequest.RequestedById__c
                    );
                if(smsRequest.Source__c != null){
                    smsRecord.smagicinteract__Source__c = smsRequest.Source__c;
                }
                smsHistoryList.add(smsRecord);
            }
        }
        if(!smsHistoryList.isEmpty()){
            insert smsHistoryList;
        }
    }

}