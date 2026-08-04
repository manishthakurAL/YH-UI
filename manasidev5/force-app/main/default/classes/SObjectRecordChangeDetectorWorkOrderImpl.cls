public with sharing class SObjectRecordChangeDetectorWorkOrderImpl extends SObjectRecordChangeDetector {
    private List<String> woStatusChangesToSynch = new List<String>{WorkOrderDecorator.STATUS_COMPLETED, 
                    WorkOrderDecorator.STATUS_NOTCOMPLETED, WorkOrderDecorator.STATUS_CANCELED, WorkOrderDecorator.STATUS_CLOSED};
    
    
     private Set<String> orchardToSFDataPoints {
        get{
            if(this.orchardToSFDataPoints == null){
                this.orchardToSFDataPoints = new Set<String>{
                    'Access__c', 'JobPhoneNumber__c', 'Subject', 'JobLocation__c', 'MainTrade__c', 'PriorityFromOrchard__c',
                    'ExpenseTypeCodeFromOrchard__c', 'ExpenseTypeFromOrchard__c', 'PriorityCodeFromOrchard__c',
                    'ContractorCodeFromOrchard__c', 'Contractor__c', 'OverallTargetDateFromOrchard__c',
                    'PropertyNumber__c', 'ReportedBy__c', 'ReportedDate__c',
                    'JobUDC__c'};
            }
            return this.orchardToSFDataPoints;
        }
        set;
    }
    public override void identifyChanges(Sobject newRecord, Sobject oldRecord){
            SObjectChangeDetectionSettingService sObjChngeDetectionSvc = new SObjectChangeDetectionSettingService(
                                                                                String.valueOf(newRecord.getSObjectType()));
            if(sObjChngeDetectionSvc.sObjectFieldChangeDetectionSettings != null){
                for(SObjectFieldChangeDetectionSetting__mdt fieldChngDetSetting: 
                                            sObjChngeDetectionSvc.sObjectFieldChangeDetectionSettings){
                    Boolean hasChanges = false;
                    String woNewtatus;
                    String woOldStatus;
                    String newSynchDirection;
                    if(oldRecord == null || 
                            newRecord.get(fieldChngDetSetting.FieldAPIName__c) != oldRecord.get(fieldChngDetSetting.FieldAPIName__c)){
                        if(fieldChngDetSetting.FieldAPIName__c == SObjectRecordChangeDetectorDecorator.WORK_ORDER_STATUS_FIELD){
                            woNewtatus = (String)newRecord.get(fieldChngDetSetting.FieldAPIName__c);
                            woOldStatus = (String)(oldRecord?.get(fieldChngDetSetting.FieldAPIName__c));
                            newSynchDirection = (String) newRecord.get(SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION);
                            if( newSynchDirection == null ){
                                if( oldRecord == null || woStatusChangesToSynch.contains(woNewtatus)){
                                    hasChanges = true;
                                }  
                            }
                            else if(newSynchDirection == SobjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_EXTERNAL_TO_SF 
                                    && oldRecord != null 
                                    && woNewtatus == WorkOrderDecorator.STATUS_NEW
                                    && woOldStatus == WorkOrderDecorator.STATUS_COMPLETED
                                    && oldRecord.get(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD) ==
                                                SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY){
                                    carryFurtherChecksForStatusChange(oldRecord, newRecord);
                            } 
                        }else if(newSynchDirection == null){
                            hasChanges = true;
                        }
                    }
                    if(hasChanges){
                        newRecord.put(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD, SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY);
                        newRecord.put(SObjectRecordChangeDetectorDecorator.LAST_SF_INT_STATUS_TS_IN_MS_FIELD, (Decimal)System.currentTimeMillis());
                        break;
                    }  
                }      
            }
    }
    

    private void carryFurtherChecksForStatusChange(Sobject oldRecord, Sobject newRecord){
        if(newRecord.get(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD) == SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED){
            Boolean hasOtherChanges = false;
            for(String aField : orchardToSFDataPoints){
                if(oldRecord.get(aField) != newRecord.get(aField)){
                    hasOtherChanges = true;
                    break;
                }
            }
            if( !hasOtherChanges){
                newRecord.put(SObjectRecordChangeDetectorDecorator.WORK_ORDER_STATUS_FIELD, WorkOrderDecorator.STATUS_COMPLETED);
                newRecord.put(SObjectRecordChangeDetectorDecorator.LAST_SF_INT_STATUS_TS_IN_MS_FIELD, (Decimal)System.currentTimeMillis());
            }
        }
    }
    public override void setCreatedInSystemOnInsert(Sobject newRecord){
        this.setCreatedInSystem(newRecord);
    }

    public override void syncIntegrationStatus(Sobject newRecord, Sobject oldRecord){
        this.syncIntegrationStatusOnUpdate(newRecord, oldRecord);
    }

    public override void clearLastSynchDirectionOnRecord(Sobject newRecord){
        this.clearLastSynchDirection(newRecord);
    }
}