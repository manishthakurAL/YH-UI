@isTest
public with sharing class UthCongaTemplate {
    

    public static APXTConga4__Conga_Template__c build(String templateKey){
        APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c(
            APXTConga4__Key__c = templateKey,
            LetterContent__c = '<p>test content</p>'
        );
        return template;
    }

}