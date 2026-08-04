public with sharing class SObjectRecordChangeDetectorManager {
    private List<Sobject> newList;
    private Map<Id, Sobject> oldRecordMap;
    
    private String sOobjectApiName{
        get{
            if(this.sOobjectApiName == null){
                this.sOobjectApiName = String.valueOf(newList.getSObjectType());
            }
            return this.sOobjectApiName;
        }
        set;
    }

    private  SobjectRecordChangeDetector changeDetectorImplClassInstance{
        get{
            if(this.changeDetectorImplClassInstance == null){
                SObjectChangeDetectionSettingService sObjChngeDetectionSvc = 
                            new SObjectChangeDetectionSettingService(this.sOobjectApiName);
                this.changeDetectorImplClassInstance = 
                    (SobjectRecordChangeDetector)Type.forName(
                        sObjChngeDetectionSvc.sObjectChangeDetectionSettingForSObj.ChangeDetectorImplClass__c).newInstance();
            }
            return this.changeDetectorImplClassInstance;
        }
        private set;
    }
    
    public SObjectRecordChangeDetectorManager(List<Sobject> newList, Map<Id, Sobject> oldRecordMap){
        this.newList = newList;
        this.oldRecordMap = oldRecordMap;
    }

    public  void setCreatedInSystem(){
        if(this.changeDetectorImplClassInstance != null){
            for(Sobject aRecord: newList){
                this.changeDetectorImplClassInstance.setCreatedInSystemOnInsert(aRecord);
            }
        }
    }
    
    public  void identifySynchChanges(){ 
        SObjectChangeDetectionSettingService sObjChngeDetectionSvc = 
                new SObjectChangeDetectionSettingService(this.sOobjectApiName);
        if(sObjChngeDetectionSvc.sObjectChangeDetectionSettingForSObj != null){
            if((sObjChngeDetectionSvc.sObjectChangeDetectionSettingForSObj.SynchOnCreation__c && oldRecordMap == null) || 
                    (sObjChngeDetectionSvc.sObjectChangeDetectionSettingForSObj.SynchOnUpdate__c && oldRecordMap != null)){
                for(Sobject aRecord: newList){
                    this.changeDetectorImplClassInstance.identifyChanges(aRecord,oldRecordMap?.get(aRecord.Id));
                }
            }
        }
    }

    public  void synchIntegrationStatus(){
        if(this.changeDetectorImplClassInstance != null){
            for(Sobject aRecord: newList){
                this.changeDetectorImplClassInstance.syncIntegrationStatus(aRecord, oldRecordMap?.get(aRecord.Id));
            }
        }
    }

    public  void clearLastSynchDirection(){
        if(this.changeDetectorImplClassInstance != null){
            for(Sobject aRecord: newList){
                this.changeDetectorImplClassInstance.clearLastSynchDirectionOnRecord(aRecord);
            }
        }
    }
}