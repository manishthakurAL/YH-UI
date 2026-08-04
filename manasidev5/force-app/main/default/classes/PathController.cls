public with sharing class PathController {
    
    @AuraEnabled
    public static Path fetchPathConfiguration(Id recordId, String fieldAPIName, Boolean isDependantPicklist, String masterFieldName) {
        Path path = null;
        try{
            String sObjectName = recordId.getSObjectType().getDescribe().getName();
            sObject record = getRecord(recordId, sObjectName, fieldAPIName, isDependantPicklist, masterFieldName);
            String fieldValue = record.get(fieldAPIName) != null ? String.valueOf(record.get(fieldAPIName)) : '';
            String masterFieldValue = !String.isBlank(masterFieldName) && record.get(masterFieldName) != null ? String.valueOf(record.get(masterFieldName)) : '';
            path = new Path(
                sObjectName,
                record,
                getPathSetting(sObjectName, fieldValue, masterFieldValue)
            );
        }catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }   
        return path;
    }
    
    private static sObject getRecord(Id recordId, String sObjectName, String fieldAPIName, Boolean isDependantPicklist, String masterFieldName) {
        String soqlQuery = 'SELECT Id, '+fieldAPIName+(isDependantPicklist ? ','+masterFieldName : '');
        soqlQuery += (!Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfos().isEmpty() ? ',RecordTypeId' : '');
        soqlQuery += ' FROM '+sObjectName;
        soqlQuery += ' WHERE Id =: recordId LIMIT 1';
        List<sObject> recordsList = Database.query(String.escapeSingleQuotes(soqlQuery));
        return !recordsList.isEmpty() ? recordsList[0] : null;
    }

    @AuraEnabled
    public static PathSetting__mdt getPathSetting(String sObjectName, String fieldValue, String masterFieldValue) {
        PathSetting__mdt pathSetting = null;
        if (String.isNotBlank(fieldValue)) {
            List<PathSetting__mdt> pathSettingsList = [SELECT Id, Configuration__c FROM PathSetting__mdt WHERE ObjectAPIName__c =: sObjectName AND FieldValue__c =: fieldValue AND MasterFieldValue__c =: masterFieldValue LIMIT 1];
            if (!pathSettingsList.isEmpty()) {
                pathSetting = pathSettingsList[0];
            }
        }
        return pathSetting;
    }

    public class Path{
        @AuraEnabled
        public sObject record;
        @AuraEnabled
        public String sObjectName;
        @AuraEnabled
        public PathSetting__mdt pathSetting;
        @AuraEnabled
        public Map<String, String> fieldLabels;
        @AuraEnabled
        public OrgSetting__c orgSetting;

        public Path(String sObjectName, sObject record, PathSetting__mdt pathSetting) {
            this.sObjectName = sObjectName;
            this.fieldLabels = getFieldLabels(sObjectName);
            this.record = record;
            this.pathSetting = pathSetting;
            this.orgSetting = OrgSetting__c.getOrgDefaults();
        }

        private Map<String, String> getFieldLabels(String sObjectName) {
            Map<String, String> fieldLabelsMap = new Map<String, String>();
            for (Schema.sObjectField sObjectField : Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().values()) {
                fieldLabelsMap.put(sObjectField.getDescribe().getName().toLowerCase(),sObjectField.getDescribe().getLabel());
            }
            return fieldLabelsMap;
        }
    }
}