public with sharing class SObjectRecordChangeDetectorPersonAccImpl extends SObjectRecordChangeDetector{
    
    public override void identifyChanges(Sobject newRecord, Sobject oldRecord){
        if((Boolean)newRecord.get(AccountDecorator.FIELD_IS_PERSON_ACCOUNT)){
            String oldMembershipTypes = (String)oldRecord.get(AccountDecorator.FIELD_DISTINCT_TENANT_MEMBERSHIP);
            String newMembershipTypes = (String)newRecord.get(AccountDecorator.FIELD_DISTINCT_TENANT_MEMBERSHIP);
            Boolean tenantAdded = !String.isBlank(newMembershipTypes) &&
                                    (String.isBlank(oldMembershipTypes) ||
                                    !oldMembershipTypes.contains(AccountDecorator.FIELD_DISTINCT_TENANT)) &&
                                    newMembershipTypes.contains(AccountDecorator.FIELD_DISTINCT_TENANT);
            if(tenantAdded && (String)newRecord.get(AccountDecorator.FIELD_PERSON_NUMBER) == null){
                this.setIntegrationStatusOnRecord(newRecord, oldRecord);
            }else if(String.isNotBlank((String)newRecord.get(AccountDecorator.FIELD_PERSON_NUMBER)) || (newMembershipTypes != null && newMembershipTypes.contains(AccountDecorator.FIELD_DISTINCT_TENANT))){
                this.identifyFieldChanges(newRecord, oldRecord);
            }
        }
    }

    public override void setCreatedInSystemOnInsert(Sobject newRecord){
        if((Boolean)newRecord.get(AccountDecorator.FIELD_IS_PERSON_ACCOUNT)){            
            if(String.isBlank((String)newRecord.get(AccountDecorator.FIELD_PERSON_NUMBER))){
                newRecord.put(SObjectRecordChangeDetectorDecorator.CREATED_IN_SYSTEM, SObjectRecordChangeDetectorDecorator.CREATED_IN_SYSTEM_SALESFORCE);
            }else{
                newRecord.put(SObjectRecordChangeDetectorDecorator.CREATED_IN_SYSTEM, SObjectRecordChangeDetectorDecorator.CREATED_IN_SYSTEM_ORCHARD);
            }
        }
    }

    public override void syncIntegrationStatus(Sobject newRecord, Sobject oldRecord){
        this.syncIntegrationStatusOnUpdate(newRecord, oldRecord);
    }

    public override void clearLastSynchDirectionOnRecord(Sobject newRecord){
        this.clearLastSynchDirection(newRecord);
    }

}