public inherited sharing class PermissionEvaluator {
    public enum ActionType {Create, Edit}

    private String sObjectName {
        get{
            if (sObjectName == null && sObjectType != null) {
                sObjectName = this.sObjectType.getDescribe().getName();
            }
            return sObjectName;
        }
        private set;
    }

    private Set<Id> userIds;
    private String permissionSetName;
    private SObjectType sObjectType;

    @TestVisible
    private static final String PERMISSION_GRANTED_BY_RECORD_TYPE = 'Record Type Level';
    @TestVisible
    private static final String PERMISSION_GRANTED_BY_CASE_STAGE = 'Case Stage Level';
    
    @TestVisible
    private static List<Id> permissionSetIds = new List<Id>();

    private String acttype;

    public PermissionEvaluator(SObjectType sObjType, String acttype){
        this.sObjectType = sObjType;
        this.acttype = acttype;
    }

    public PermissionEvaluator(Set<Id> userIds,String permissionSetName){
        this.userIds = userIds;
        this.permissionSetName = permissionSetName;
    }

    public Boolean hasPermission(Case record){
        Boolean isValid = true;
        String recordTypeName = RecordTypeUtility.getRecordTypeDeveloperNameById(CaseDecorator.SOBJECT_TYPE_CASE, record.RecordTypeId);
        CasePermission__mdt permission = CasePermission__mdt.getInstance(recordTypeName);

        if (permission != null)  {  
            Boolean grantedByRecordType = false;
            
            CasePermissionDetails__mdt[]  permissionDetailsByRecordType = [
            SELECT CustomPermission__c, ApplyOnTask__c
            FROM CasePermissionDetails__mdt 
            WHERE CasePermission__c = :permission.Id 
            AND ActionType__c = :this.acttype 
            AND GrantedBy__c = :PERMISSION_GRANTED_BY_RECORD_TYPE
            AND GrantedToRecordType__c = :recordTypeName                    
            ];

            CasePermissionDetails__mdt[]  permissionDetailsByStatus = [
            SELECT CustomPermission__c, ApplyOnTask__c 
            FROM CasePermissionDetails__mdt 
            WHERE CasePermission__c = :permission.Id 
            AND ActionType__c = :this.acttype
            AND GrantedBy__c = :PERMISSION_GRANTED_BY_CASE_STAGE
            AND GrantedToStatus__c = :record.Status
            ];

            switch on string.valueof(this.sObjectType){
                when 'Task'{
                    if (!permissionDetailsByRecordType.isEmpty()) {
                        if(permissionDetailsByRecordType[0].ApplyOnTask__c){
                            isValid = FeatureManagement.checkPermission(permissionDetailsByRecordType[0].CustomPermission__c);
                        }
                    } 
                }
                when 'Case' {
                    if (!permissionDetailsByRecordType.isEmpty()) {
                        grantedByRecordType = FeatureManagement.checkPermission(permissionDetailsByRecordType[0].CustomPermission__c);
                        isValid = grantedByRecordType;
                    }  
                    
                    if (!grantedByRecordType && !permissionDetailsByStatus.isEmpty()) {
                        isValid = FeatureManagement.checkPermission(permissionDetailsByStatus[0].CustomPermission__c);
                    }    
                }
                when else {
                    if (!permissionDetailsByRecordType.isEmpty()) {
                        grantedByRecordType = FeatureManagement.checkPermission(permissionDetailsByRecordType[0].CustomPermission__c);
                        isValid = grantedByRecordType;
                    } 
                    if (!grantedByRecordType && !permissionDetailsByStatus.isEmpty()) {
                        isValid = FeatureManagement.checkPermission(permissionDetailsByStatus[0].CustomPermission__c);
                    }
                }
            }         
        }
        return isValid;
    }

    public Set<Id> checkIfSpecificPermissionIsAssignedToUser(){
        List<Id> permissionSetGroupIds = new List<Id>();
        Set<Id> assigneeIds = new Set<Id>();
        Set<Id> validPermissionAssignedIds = new Set<Id>();
        if(userIds.isEmpty()){
            return validPermissionAssignedIds;
        }
        List<PermissionSetGroupComponent> permissionSetGroupComponents = 
                [SELECT Id, PermissionSetGroupId, PermissionSetId FROM PermissionSetGroupComponent WHERE PermissionSet.Name =: permissionSetName];
        for(PermissionSetGroupComponent groupComponentPS : permissionSetGroupComponents){
            permissionSetGroupIds.add(groupComponentPS.PermissionSetGroupId);   
            permissionSetIds.add(groupComponentPS.PermissionSetId);
        }

        List<PermissionSetAssignment> psAssignments = [SELECT Id, AssigneeId FROM PermissionSetAssignment 
                        WHERE  ( PermissionSetGroupId IN :permissionSetGroupIds OR PermissionSetId IN :permissionSetIds ) 
                                AND AssigneeId IN :userIds
                                AND IsActive = true];
   
        
        for(PermissionSetAssignment anAssignment : psAssignments){
            assigneeIds.add(anAssignment.AssigneeId);
        }                   

        for(Id userId : userIds){
            if( assigneeIds.contains(userId) ){
                validPermissionAssignedIds.add(userId);
            } 
        }

        return validPermissionAssignedIds;
    }   

}