public inherited sharing class SObjectChangeDetectionSettingService {

    private String sObjectApiName;

    public SObjectChangeDetectionSettingService(String sObjectApiName){
        this.sObjectApiName = sObjectApiName;
    }

    public SObjectChangeDetectionSetting__mdt sObjectChangeDetectionSettingForSObj{
        get{
            if(this.sObjectChangeDetectionSettingForSObj == null){
                this.sObjectChangeDetectionSettingForSObj = sObjectChangeDetectionSettingByObjectName.get(this.sObjectApiName);
            }
            return this.sObjectChangeDetectionSettingForSObj;
        }
        set;
    }

    public List<SObjectFieldChangeDetectionSetting__mdt> sObjectFieldChangeDetectionSettings{
        get{
            if(this.sObjectFieldChangeDetectionSettings == null){
                this.sObjectFieldChangeDetectionSettings = 
                        sObjectFieldChangeDetectionSettingsByObjectName.get(this.sObjectApiName);
            }
            return this.sObjectFieldChangeDetectionSettings;
        }
        set;
    }

    public static Map<String, SObjectChangeDetectionSetting__mdt> sObjectChangeDetectionSettingByObjectName {
        get {
            if (sObjectChangeDetectionSettingByObjectName == null) {
                sObjectChangeDetectionSettingByObjectName = new Map<String, SObjectChangeDetectionSetting__mdt>();
                for(SObjectChangeDetectionSetting__mdt sObjectChangeDetectionSetting: [SELECT Id, 
                            SObjectType__c, ChangeDetectorImplClass__c, SynchOnCreation__c, SynchOnUpdate__c
                        FROM  SObjectChangeDetectionSetting__mdt 
                        WHERE IsActive__c = TRUE]){
                    sObjectChangeDetectionSettingByObjectName.put(sObjectChangeDetectionSetting.SObjectType__c, sObjectChangeDetectionSetting);
                }
            }
            return sObjectChangeDetectionSettingByObjectName;
        }
        private set;
    }

    public static Map<String, List<SObjectFieldChangeDetectionSetting__mdt>> sObjectFieldChangeDetectionSettingsByObjectName {
        get {
            if(sObjectFieldChangeDetectionSettingsByObjectName == null) {
                sObjectFieldChangeDetectionSettingsByObjectName = 
                            new Map<String, List<SObjectFieldChangeDetectionSetting__mdt>>();
                for(SObjectFieldChangeDetectionSetting__mdt fieldChangedetectionsetting: [SELECT 
                            SObjectChangeDetectionSetting__r.SObjectType__c, FieldAPIName__c, IsActive__c, Order__c
                        FROM SObjectFieldChangeDetectionSetting__mdt
                        WHERE IsActive__c = TRUE ORDER BY Order__c]){
                    String sOjectTypeName = fieldChangedetectionsetting.SObjectChangeDetectionSetting__r.SObjectType__c;
                    if(sObjectFieldChangeDetectionSettingsByObjectName.containsKey(sOjectTypeName)){
                        sObjectFieldChangeDetectionSettingsByObjectName.get(sOjectTypeName).add(fieldChangedetectionsetting);
                    } else{
                        sObjectFieldChangeDetectionSettingsByObjectName.put(sOjectTypeName, new List<SObjectFieldChangeDetectionSetting__mdt>{fieldChangedetectionsetting});
                    }
                }
            }
            return sObjectFieldChangeDetectionSettingsByObjectName;
        }
        private set;
    }

}