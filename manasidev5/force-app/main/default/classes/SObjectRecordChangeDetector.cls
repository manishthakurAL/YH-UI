public inherited sharing abstract class SObjectRecordChangeDetector{

    public abstract void identifyChanges(Sobject newRecord, Sobject oldRecord);

    public abstract void syncIntegrationStatus(Sobject newRecord, Sobject oldRecord);

    public abstract void setCreatedInSystemOnInsert(Sobject newRecord);

    public abstract void clearLastSynchDirectionOnRecord(Sobject newRecord);


    protected virtual void setCreatedInSystem(Sobject newRecord){
        
        if(newRecord.get(SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION) == null){
                newRecord.put(SObjectRecordChangeDetectorDecorator.CREATED_IN_SYSTEM, SObjectRecordChangeDetectorDecorator.CREATED_IN_SYSTEM_SALESFORCE);
        }
        else if(newRecord.get(SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION) ==
                        SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_EXTERNAL_TO_SF){
                            newRecord.put(SObjectRecordChangeDetectorDecorator.CREATED_IN_SYSTEM, SObjectRecordChangeDetectorDecorator.CREATED_IN_SYSTEM_ORCHARD);
        }
    }
    
    protected virtual void identifyFieldChanges(Sobject newRecord, Sobject oldRecord){
        if( newRecord.get(SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION) == null ){
            SObjectChangeDetectionSettingService sObjChngeDetectionSvc = new SObjectChangeDetectionSettingService(
                                                                            String.valueOf(newRecord.getSObjectType()));
            if(sObjChngeDetectionSvc.sObjectFieldChangeDetectionSettings != null){
                for(SObjectFieldChangeDetectionSetting__mdt fieldChngDetSetting: 
                                            sObjChngeDetectionSvc.sObjectFieldChangeDetectionSettings){
                    if((oldRecord == null || 
                            newRecord.get(fieldChngDetSetting.FieldAPIName__c) != oldRecord.get(fieldChngDetSetting.FieldAPIName__c))){
                        setIntegrationStatusOnRecord(newRecord, oldRecord);
                        break;
                    }        
                }
            }
        }
    }

    protected virtual void syncIntegrationStatusOnUpdate(Sobject newRecord, Sobject oldRecord){ 
        if(oldRecord != null ){
            String oldIntStatus = (String)oldRecord.get(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD);
            String newIntStatus = (String)newRecord.get(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD);
            Decimal oldMulesofySynchTsinMS = (Decimal)oldRecord.get(SobjectRecordChangeDetectorDecorator.LAST_MS_INT_STATUS_TS_IN_MS_FIELD);
            Decimal oldMulesoftStatusSynchInMS = (Decimal)oldRecord.get(SobjectRecordChangeDetectorDecorator.LAST_MS_SOFT_SYNCHED_TS_IN_MS_FIELD);
            Decimal salesforceSynchTSinMS = (Decimal)oldRecord.get(SobjectRecordChangeDetectorDecorator.LAST_SF_INT_STATUS_TS_IN_MS_FIELD);
            Decimal mulesoftSynchTSinMS = (Decimal)newRecord.get(SobjectRecordChangeDetectorDecorator.LAST_MS_INT_STATUS_TS_IN_MS_FIELD);

            if(newRecord.get(SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION) == SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_EXTERNAL_TO_SF){
                if( newIntStatus == SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED){ 
                    if( oldIntStatus  == SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_ERROR || oldIntStatus ==
                        SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY
                       ){
                                newRecord.put(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD,
                                        SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY);
                                newRecord.put(SobjectRecordChangeDetectorDecorator.LAST_SF_INT_STATUS_TS_IN_MS_FIELD, (Decimal)System.currentTimeMillis());
                    }
                }else{
                        newRecord.addError(Label.SynchErrorMessageExtToSF);
                }
            }else if(newRecord.get(SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION) == SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_SF_TO_EXTERNAL){
                if( newIntStatus == SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED){
                    if ( mulesoftSynchTSinMS < salesforceSynchTSinMS){
                                newRecord.put(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD,
                                        SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY);
                    }else if (mulesoftSynchTSinMS > salesforceSynchTSinMS){
                        newRecord.addError(Label.SynchErrorMessage);
                    }
                } else if( newIntStatus == SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_ERROR){
                    if ( mulesoftSynchTSinMS < salesforceSynchTSinMS){
                                newRecord.put(SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD,
                                        SobjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY);
                                newRecord.put(SobjectRecordChangeDetectorDecorator.LAST_SF_INT_STATUS_TS_IN_MS_FIELD, (Decimal)System.currentTimeMillis());
                    }else if (mulesoftSynchTSinMS > salesforceSynchTSinMS){
                        newRecord.addError(Label.SynchErrorMessage);
                    }
                }
            }
        }
    }

    protected virtual void clearLastSynchDirection(Sobject newRecord){ 
        newRecord.put(SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION, null);
    }

    protected virtual void setIntegrationStatusOnRecord(Sobject newRecord, Sobject oldRecord){
        string intStatus;
        if(newRecord.get(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD) == null){
            intStatus = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY;
        }else if(newRecord.get(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD) == SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_IN_PROGRESS){
            intStatus = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_IN_PROGRESS_FURUPD;
        }
        newRecord.put(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD, intStatus);
        newRecord.put(SObjectRecordChangeDetectorDecorator.LAST_SF_INT_STATUS_TS_IN_MS_FIELD, 
                                                            (Decimal)System.currentTimeMillis());
    }
}