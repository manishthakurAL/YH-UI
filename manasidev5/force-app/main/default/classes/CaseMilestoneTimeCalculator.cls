global without sharing class CaseMilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {
    @testVisible
    enum MILESTONE_ACTION{UNKNOWN, MS_IS_BEING_CREATED, STARTDATE_NOT_SYNCHED, STARTDATE_SYNCHED_BUT_DURATION_NOT_CALC, 
                            STARTDATE_SYNCHED_AND_DURATION_CALC}

    static final Integer MS_DURATION_ERROR = -1;
    static final Integer MS_DURATION_STARTDATE_NOT_SYNCHED = 10;
    static final Integer MS_DURATION_STARTDATE_SYNCHED_BUT_DURATION_NOT_CALC = 20;
    static final Integer MS_DURATION_ERROR_IN_CALCULATION = 30;

    private Id msTypeId;
    public Map<Id, MilestoneType> mileStoneTypesMap {
        get {
            if(this.mileStoneTypesMap == null){
                this.mileStoneTypesMap = new Map<Id, MilestoneType>(); 
                List<MilestoneType> milestoneTypesList = [
                    SELECT Id, Name
                    FROM MilestoneType 
                ];
                for (MilestoneType milestoneType : milestoneTypesList) {
                    mileStoneTypesMap.put(milestoneType.Id, milestoneType);
                }
            }
            return this.mileStoneTypesMap;
        }
        set; 
    }

    @testVisible
    private CaseMilestone caseMilestoneRec{
        get{
            if(this.caseMilestoneRec == null && this.msTypeId != null && this.caseId != null){
                List<CaseMilestone> caseMSRecs = [SELECT Id, CaseId, LastModifiedDate, createdDate, MilestoneType.Name, ActualElapsedTimeInDays, 
                        ActualElapsedTimeInHrs, ActualElapsedTimeInMins, BusinessHoursId, ElapsedTimeInDays, ElapsedTimeInHrs, ElapsedTimeInMins, 
                        IsViolated, MilestoneTypeId, StartDate, StoppedTimeInDays, StoppedTimeInHrs, StoppedTimeInMins, TargetDate, 
                        TargetResponseInDays, TargetResponseInHrs, TargetResponseInMins, TimeRemainingInDays, TimeRemainingInHrs, 
                        TimeRemainingInMins, TimeSinceTargetInDays, TimeSinceTargetInHrs, TimeSinceTargetInMins, IsCompleted, CompletionDate 
                    FROM CaseMilestone 
                    WHERE CaseId = :this.caseId AND MilestoneTypeId = :this.msTypeId ORDER BY IsCompleted, createdDate DESC];
                if(!caseMSRecs.isEmpty()){
                    this.caseMilestoneRec = caseMSRecs[0];
                }
            }
            return this.caseMilestoneRec;
        }
        set;
    }

    private Id caseId;
    private MilestoneType milstoneType;

    @testVisible
    private Case caseRec{
        get{
            if( this.caseRec == null && this.caseId != null ){
                List<Case> casesList = [SELECT Id, ResolutionTargetDate__c, ResolutionTargetDateTime__c, OmbudsmanDeadlineDate__c, 
                        SLAStartDate__c, SLAStartDate, RecordType.DeveloperName, SLAEndDate__c, MutualExchangeDecisionSLAEndDate__c,
                        MSIdsStartDateSynched__c, MSIdsDurationCalculated__c
                    FROM Case WHERE Id =: this.caseId WITH SYSTEM_MODE LIMIT 1];
                this.caseRec = casesList[0];
            }
            return this.caseRec;
        }
        set;
    }

    private EntitlementSettingService entitlementSettingService{
        get{
            if(this.entitlementSettingService == null && this.caseRec != null && this.milstoneType != null ){
                entitlementSettingService = new EntitlementSettingService(
                    Case.sObjectType.getDescribe().getName(),
                    this.caseRec.RecordType.DeveloperName,
                    this.milstoneType.Name
                );
            }
            return this.entitlementSettingService;
        }
        set;
    }
    
    private EntitlementSetting__mdt entitlementSetting {
        get{
            if( this.entitlementSetting == null && this.entitlementSettingService != null ){
                this.entitlementSetting = this.entitlementSettingService.getEntitlementSetting();
            }    
            return this.entitlementSetting;
        }
        set;
    }

    private BusinessHourService businessHourService{
        get{
            if(this.entitlementSetting != null && this.businessHourService == null){
                String businessHourName = entitlementSetting.BusinessHours__c;
                if(String.isBlank(businessHourName)){
                    businessHourName = BusinessHourDecorator.DEFAULT_BUSINESS_HOUR;
                }
                this.businessHourService = new BusinessHourService(businessHourName);
            }
            return this.businessHourService;
        }
        set;
    }

    private FeatureSwitches__c featureSwitches{
        get{
            if (this.featureSwitches == null) {
                this.featureSwitches = FeatureSwitches__c.getInstance();
            }
            return this.featureSwitches;
        }
        set;
    }

    @testVisible
    private MILESTONE_ACTION getNextAction(){
        MILESTONE_ACTION msAction = MILESTONE_ACTION.UNKNOWN;
        if(this.featureSwitches != null && this.featureSwitches.BypassCaseMilestoneRecalcLogic__c == TRUE){
            msAction = MILESTONE_ACTION.STARTDATE_SYNCHED_AND_DURATION_CALC;
        } else if(this.caseMilestoneRec == null){
            msAction = MILESTONE_ACTION.MS_IS_BEING_CREATED;
        } else {
            Boolean startDateSynched = String.isNotBlank(this.caseRec.MSIdsStartDateSynched__c) && this.caseRec.MSIdsStartDateSynched__c.contains(this.caseMilestoneRec.Id);
            Boolean durationCalculated = String.isNotBlank(this.caseRec.MSIdsDurationCalculated__c) && this.caseRec.MSIdsDurationCalculated__c.contains(this.caseMilestoneRec.Id);
            if(startDateSynched == false && durationCalculated == false){
                msAction = MILESTONE_ACTION.STARTDATE_NOT_SYNCHED;
            } else if(startDateSynched == true && durationCalculated == false){
                msAction = MILESTONE_ACTION.STARTDATE_SYNCHED_BUT_DURATION_NOT_CALC;
            } else if(startDateSynched == true && durationCalculated == true){
                msAction = MILESTONE_ACTION.STARTDATE_SYNCHED_AND_DURATION_CALC;
            }
        }
        return msAction;
    }

    @testVisible
    private void createPlatfromEvent(){
        List<CaseMilestoneDurationCalculatedPE__e> caseMSDurationCalEvents = new List<CaseMilestoneDurationCalculatedPE__e>();
        caseMSDurationCalEvents.add(new CaseMilestoneDurationCalculatedPE__e(
                                            CaseId__c = this.caseId,
                                            CaseMilestoneId__c = this.caseMilestoneRec.Id)
        );
        List<Database.SaveResult> results = EventBus.publish(caseMSDurationCalEvents);
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' + err.getStatusCode());
                }
            }
        }
    }
    
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {
        this.msTypeId = milestoneTypeId;
        this.caseId = caseId;
        Integer totalMinutes = MS_DURATION_ERROR;

        MILESTONE_ACTION nextAction = this.getNextAction();
        if(nextAction == MILESTONE_ACTION.MS_IS_BEING_CREATED){
            totalMinutes = MS_DURATION_STARTDATE_NOT_SYNCHED;
        } else if(nextAction == MILESTONE_ACTION.STARTDATE_NOT_SYNCHED){
            totalMinutes = MS_DURATION_STARTDATE_SYNCHED_BUT_DURATION_NOT_CALC;
        } else if(nextAction == MILESTONE_ACTION.STARTDATE_SYNCHED_BUT_DURATION_NOT_CALC){
            totalMinutes = this.calculateDynamicDuration();
        } else if(nextAction == MILESTONE_ACTION.STARTDATE_SYNCHED_AND_DURATION_CALC){
            totalMinutes = this.caseMilestoneRec.TargetResponseInMins;
        }
        return totalMinutes;
    }

    private Integer calculateDynamicDuration(){
        Integer totalMinutes = MS_DURATION_ERROR_IN_CALCULATION;
        if (this.mileStoneTypesMap.containsKey(this.msTypeId)) {
            this.milstoneType = mileStoneTypesMap.get(this.msTypeId);
            if (this.entitlementSetting != null) {
                if (this.entitlementSetting.TimePeriodType__c == EntitlementSettingDecorator.TIME_PERIOD_TYPE_MINUTE) {
                    totalMinutes = Integer.valueOf(this.entitlementSetting.TimePeriod__c);
                } else {
                    String startDateTimeFieldName = String.isEmpty(this.entitlementSetting.StartDateTimeField__c) ? 'SLAStartDate__c' : this.entitlementSetting.StartDateTimeField__c;
                    DateTime startDateTime = DateTime.valueOf(caseRec.get(startDateTimeFieldName));
                    DateTime targetDateTime = null;
                    if (this.entitlementSetting.TimePeriodType__c == EntitlementSettingDecorator.TIME_PERIOD_TYPE_DAY) {
                        targetDateTime = this.businessHourService.addBusinessDays(startDateTime, Integer.valueOf(this.entitlementSetting.TimePeriod__c) );
                    } else if (this.entitlementSetting.TimePeriodType__c == EntitlementSettingDecorator.TIME_PERIOD_TYPE_FIELD) {
                        if (this.entitlementSettingService.sObjectDescribeResult.fields.getMap().get(this.entitlementSetting.FieldAPIName__c).getDescribe().getType() == Schema.DisplayType.Date) {
                            Date targetDate = Date.valueOf(caseRec.get(this.entitlementSetting.FieldAPIName__c));
                            Time targetTime = this.businessHourService.getBusinessEndTime(
                                DateTime.newInstance(
                                    targetDate,
                                    System.now().time()
                                ).format('EEEE').toLowerCase());
                            targetDateTime = DateTime.newInstance(
                                targetDate,
                                targetTime
                            );
                        } else if (this.entitlementSettingService.sObjectDescribeResult.fields.getMap().get(this.entitlementSetting.FieldAPIName__c).getDescribe().getType() == Schema.DisplayType.DateTime) {
                            targetDateTime = DateTime.valueOf(caseRec.get(this.entitlementSetting.FieldAPIName__c));
                        }
                    }
                    totalMinutes =  this.businessHourService.getMinutesBetween(startDateTime, targetDateTime);
                }
                this.createPlatfromEvent();
            }
        }
        return totalMinutes;
    }
}