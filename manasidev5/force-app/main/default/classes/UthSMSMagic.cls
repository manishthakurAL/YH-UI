@isTest
public with sharing class UthSMSMagic {

    public static List<smagicinteract__smsMagic__c> getSMSRecords(){
        return [ SELECT smagicinteract__SenderId__c,smagicinteract__Contact__c,smagicinteract__PhoneNumber__c,
                   		smagicinteract__SMSText__c,RequestedBy__c,smagicinteract__Name__c
            			FROM smagicinteract__smsMagic__c];
    }
}