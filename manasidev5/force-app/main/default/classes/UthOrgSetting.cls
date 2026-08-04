@isTest
public with sharing class UthOrgSetting {
    
    public static OrgSetting__c build(){
        return new OrgSetting__c();
    }

    public static OrgSetting__c buildSettingForAutoCaseCloseBatch(){
         OrgSetting__c orgSetting = build();
         orgSetting.DaysAutoCloseTerminationCase__c = -3;
         return orgSetting;
    }
}