public with sharing class CustomFormController {
    
    private static Map<String,Schema.DescribeSObjectResult> objectDescribebyObjectName = new
                Map<String, Schema.DescribeSObjectResult>();
    private static Map<String, Schema.SObjectType >  sObjectTypeByObjectName = new Map<String, Schema.SObjectType>();
    private static Map<String, Map<String, Schema.FieldSet>> fieldSetByObjectName = new Map<String, Map<String, Schema.FieldSet>>();
    @testVisible static List<CustomFormConfiguration__mdt> customFormConfig;
    @testVisible static List<ParentFieldsOnChildDisplayDetail__mdt> customFormParentConfig;


    @AuraEnabled(cacheable=true)
    public static List<CustomForm> getFormDetails(Id parentRecordId, String metadataName) {
        if(customFormConfig == null){
            customFormConfig =  [SELECT ChildObjectAPIName__c, FieldSetName__c, ParentObjectAPIName__c, 
                                    CustomFormParentConfig__r.DeveloperName, AccordianLabel__c,
                                    ParentRelationshipAPIName__c, ShowMemberContactBasedon__c,
                                    CaseRoles__c,Display_Order__c,Expanded__c
                                    FROM CustomFormConfiguration__mdt 
                                    WHERE CustomFormParentConfig__r.DeveloperName =:metadataName
                                	ORDER BY Display_Order__c];
        }
        String objectName = parentRecordId.getSobjectType().getDescribe().getName(); 
        List<CustomForm> formDetails = createFormDetailConfig(customFormConfig,parentRecordId,objectName);
        return formDetails;
    }

    @AuraEnabled(cacheable=true)
    public static List<CustomForm> getParentDisplayConfigDetails(Id childRecordId, String metadataName) {
        if(customFormParentConfig == null){
            customFormParentConfig =  [SELECT AccordianLabel__c, FieldSetName__c, 
                                    ParentFieldsOnChildDisplayConfig__r.DeveloperName, 
                                    ParentRelationshipAPIName__c, ParentObjectAPIName__r.QualifiedAPIName,
                                    DisplayOrder__c 
                                    FROM ParentFieldsOnChildDisplayDetail__mdt 
                                    WHERE ParentFieldsOnChildDisplayConfig__r.DeveloperName =:metadataName
                                	ORDER BY DisplayOrder__c];
        }
        String objectName = childRecordId.getSobjectType().getDescribe().getName(); 
        List<CustomForm> formDetails = createParentFormDetails(customFormParentConfig, childRecordId, objectName);
        return formDetails;
    }


    private static List<CustomForm> createFormDetailConfig( List<CustomFormConfiguration__mdt> customFormConfig, Id parentRecordId, String objectName ){
        List<CustomForm> formConfigs = new List<CustomForm>();
        for( CustomFormConfiguration__mdt aCustomFormConfig: customFormConfig ){
            CustomForm aform = new CustomForm();
            if( aCustomFormConfig.Expanded__c){
                aform.expandedSection.add(aCustomFormConfig.ChildObjectAPIName__c+'expanded');
                aform.sectionName = aCustomFormConfig.ChildObjectAPIName__c+'expanded';
            }
            else{
                aform.sectionName = aCustomFormConfig.ChildObjectAPIName__c;
            }
            aform.fields = getFields(aCustomFormConfig.ChildObjectAPIName__c, aCustomFormConfig.FieldSetName__c);
            if(String.isNotBlank(aCustomFormConfig.ShowMemberContactBasedon__c)){
                if(aCustomFormConfig.ShowMemberContactBasedon__c == 'CaseContact'){    
                    aform.recordId = getContactIdBasedOnCaseContactId(parentRecordId, objectName);
                }
                else{
                    aform.recordId = getContactIdBasedOnCaseRole(parentRecordId, aCustomFormConfig.CaseRoles__c);
                }
                if(aCustomFormConfig.ChildObjectAPIName__c == String.valueOf(Member__c.getSobjectType())){
                    String query =  'SELECT ' + aCustomFormConfig.ParentObjectAPIName__c + ' FROM ' + objectName + ' WHERE ID = :parentRecordId';
                    List<SObject> queryRecord = Database.query(query);
                    if(!queryRecord.isEmpty()){
                        aform.recordId = getMemberRecordId((Id)queryRecord[0].get(aCustomFormConfig.ParentObjectAPIName__c ), aform.recordId);
                    }
                }  
            }else{
                aform.recordId = getRecordId(parentRecordId, aCustomFormConfig.ChildObjectAPIName__c, 
                            aCustomFormConfig.ParentRelationshipAPIName__c, true);   
            }
            aform.objectAPIName = aCustomFormConfig.ChildObjectAPIName__c;
            aform.accordianLabel = aCustomFormConfig.AccordianLabel__c;
            formConfigs.add(aform);
        }
        return formConfigs;
    }

    private static List<CustomForm> createParentFormDetails( List<ParentFieldsOnChildDisplayDetail__mdt> customFormConfig, Id recordId, String objectName ){
        List<CustomForm> formConfigs = new List<CustomForm>();
        for( ParentFieldsOnChildDisplayDetail__mdt aCustomFormConfig: customFormConfig ){
            CustomForm aform = new CustomForm();
            aform.fields = getFields(aCustomFormConfig.ParentObjectAPIName__r.QualifiedAPIName, aCustomFormConfig.FieldSetName__c);
            aform.recordId = getRecordId(recordId, objectName, 
                            aCustomFormConfig.ParentRelationshipAPIName__c, false);     
            aform.objectAPIName = aCustomFormConfig.ParentObjectAPIName__r.QualifiedAPIName;
            aform.accordianLabel = aCustomFormConfig.AccordianLabel__c;
            formConfigs.add(aform);
        }
        return formConfigs;
    }


    private static Id getMemberRecordId(Id tenancyId, Id contactId){
        List<Member__c> members = [SELECT ID FROM Member__c WHERE TENANCY__C =:tenancyId AND Contact__c=:contactId];
        Id retId = !members.isEmpty() ? (Id)members[0].Id : null;
        return retId;
    }

    private static Id getContactIdBasedOnCaseRole(Id parentRecordId,String roleType){
        List<CaseRole__c> caseRoles = [SELECT Contact__c FROM CaseRole__c WHERE Case__c=:parentRecordId and Role__c=:roleType];
        Id retId = !caseRoles.isEmpty() ? (Id)caseRoles[0].Contact__c : null;
        return retId;
    }

    private static id getContactIdBasedOnCaseContactId(Id parentRecordId,String objectName){
        List<Sobject> queriedRecords = [SELECT ID, ContactId FROM Case WHERE Id=:parentRecordId];
        Id retId = !queriedRecords.isEmpty() ? (Id)queriedRecords[0].get('ContactId') : null;
        return retId;
    }
    
    private static Id getRecordId(Id recordId, String objectName, String filterByField, boolean isDisplayChildOnParent){
        String afield = isDisplayChildOnParent ? 'Id':filterByField;
        String filterField = isDisplayChildOnParent ? filterByField : 'Id';

        String formQuery = 'SELECT '+filterByField+' FROM ' + objectName + ' WHERE ' + filterField +'=:recordId';
        List<Sobject> queriedRecords = Database.query(formQuery);
        Id retId = !queriedRecords.isEmpty() ? (Id)queriedRecords[0].get(afield) : null;
        return retId;
    }

    private static List<String> getFields( String objectName, String fieldSetName) {
        Schema.SObjectType objectType;
        List<String> fields = new List<String>();
        if (String.isNotBlank(objectName)) {
            objectType = sObjectTypeByObjectName.get(objectName);
            if( objectType == null ){
                objectType = Schema.getGlobalDescribe().get(objectName);
                sObjectTypeByObjectName.put(objectName, objectType);
            }
            
            Schema.DescribeSObjectResult objectDescribe = objectDescribebyObjectName.get(objectName);
            if(objectDescribe == null){
                objectDescribe = objectType.getDescribe();
                objectDescribebyObjectName.put(objectName,objectDescribe);
            }  
            
            Map<String, Schema.FieldSet> fieldSetMap = fieldSetByObjectName.get(objectName);
            if(fieldSetMap == null){
                fieldSetMap = objectDescribe.fieldSets.getMap();
                fieldSetByObjectName.put(objectName,fieldSetMap);
            }
            Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
            List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
            for (Schema.FieldSetMember fsm : fieldSetMembers) {
                fields.add(fsm.getFieldPath());
            }
        }
        return fields;
    }
    
    public class CustomForm {
        @AuraEnabled
        public List<String> fields { get; set; }
        @AuraEnabled
        public string recordId;
        @AuraEnabled
        public String objectAPIName;
        @AuraEnabled
        public String accordianLabel;
        @AuraEnabled
        public List<String> expandedSection; 
        @AuraEnabled
        public String sectionName; 
        
        public CustomForm() {
            this.fields = new List<String>();
            this.recordId = recordId;
            this.objectAPIName = objectAPIName;
            this.accordianLabel = accordianLabel;
            this.expandedSection = new List<String>();
        }
    }
}