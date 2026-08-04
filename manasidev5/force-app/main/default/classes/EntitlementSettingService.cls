public with sharing class EntitlementSettingService {

    private String sObjectName;
    private String recordTypeAPIName;
    private String milestoneTypeName;

    public Schema.DescribeSObjectResult sObjectDescribeResult {
        get {
            if(this.sObjectDescribeResult == null && this.sObjectName != null){
                this.sObjectDescribeResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
            }
            return this.sObjectDescribeResult;
        }
        set;
    }
     
    public EntitlementSettingService(String sObjectName, String recordTypeAPIName, String milestoneTypeName) {
        this.sObjectName = sObjectName;
        this.recordTypeAPIName = recordTypeAPIName;
        this.milestoneTypeName = milestoneTypeName;
    }

    public EntitlementSetting__mdt getEntitlementSetting() {
        return [SELECT Id, StartDateTimeField__c, TimePeriod__c, TimePeriodType__c, FieldAPIName__c,BusinessHours__c FROM EntitlementSetting__mdt WHERE ObjectAPIName__c =: sObjectName 
            AND RecordTypeAPIName__c =: recordTypeAPIName AND MilestoneName__c =: milestoneTypeName LIMIT 1];
    }

}