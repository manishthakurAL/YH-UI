public class TenancyFirstContactSLACalculationService {

    private List<Case> casesList;
    private Map<Id, Case> oldCasesMap;
    private DateTime startDateTime;

    public TenancyFirstContactSLACalculationService(){
        this.startDateTime = System.now();
    }
    
    @TestVisible
    private TenancyFirstContactSLACalculationService(DateTime startDateTime){
        this.startDateTime = startDateTime;
    }
    
    public void calculateSLADates(List<Case> casesList1, Map<Id, Case> oldCasesMap1) {
        this.casesList = casesList1;
        this.oldCasesMap = oldCasesMap1;
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        for (Case caseRecord : this.casesList) {
            if(caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_TENANCY && caseRecord.Status == CaseDecorator.STATUS_NEW){
                if( this.oldCasesMap == null || 
                        (   this.oldCasesMap != null && 
                            this.oldCasesMap.containskey(caseRecord.Id) && 
                            caseRecord.DecantType__c != this.oldCasesMap.get(caseRecord.Id).DecantType__c)
                        ){
                    caseRecord.SLAStartDate__c = businessHourService.getNextBusinessDay(this.startDateTime,null);
                    Integer SLA_DAYS = 0;
                    if( this.oldCasesMap == null && caseRecord.DecantType__c != CaseDecorator.TENANCY_DECANT_CASE_TYPE_TEMPORARY ){
                        SLA_DAYS = CaseDecorator.TENANCY_FIRSTCONTACT_CASE_SLA_DAYS;
                    }
                    
                    if( this.oldCasesMap != null 
                            && String.isNotEmpty(caseRecord.DecantType__c) 
                            && caseRecord.CaseType__c == CaseDecorator.CASETYPE_DECANT 
                            && caseRecord.DecantType__c != this.oldCasesMap.get(caseRecord.Id).DecantType__c
                            && caseRecord.DecantType__c == CaseDecorator.TENANCY_DECANT_CASE_TYPE_TEMPORARY){
                        caseRecord.SLAStartDate__c = businessHourService.getNextBusinessDay(this.startDateTime,null);
                        SLA_DAYS = CaseDecorator.TENANCY_FIRSTCONTACT_TEMPORARY_DECANT_CASE_SLA_DAYS;
                        if(this.FCAMilestoneByCaseIdMap != null && this.FCAMilestoneByCaseIdMap.containsKey(caseRecord.Id)){
                            this.removeCaseMilestoneIds(caseRecord, this.FCAMilestoneByCaseIdMap.get(caseRecord.Id).Id);
                        }
                    }
                    caseRecord.ResolutionTargetDate__c = businessHourService.calculateTargetDate(SLA_DAYS, caseRecord.SLAStartDate__c).date();
                }
            }
        }
    }

    private void removeCaseMilestoneIds(Case caseRecord, String msIdToRemove){
        if(String.isNotBlank(caseRecord.MSIdsStartDateSynched__c)){
            caseRecord.MSIdsStartDateSynched__c = this.parseStringRemoveId(caseRecord.MSIdsStartDateSynched__c, msIdToRemove);
        }
        if(String.isNotBlank(caseRecord.MSIdsDurationCalculated__c)){
            caseRecord.MSIdsDurationCalculated__c = this.parseStringRemoveId(caseRecord.MSIdsDurationCalculated__c, msIdToRemove);
        }
    }

    private List<Id> caseIdsForFCAMilestone{
        get{
            if(this.caseIdsForFCAMilestone == null || this.caseIdsForFCAMilestone.isEmpty()){
                this.caseIdsForFCAMilestone = new List<Id>();
                for (Case caseRecord : this.casesList) {
                    if(this.oldCasesMap != null 
                            && String.isNotEmpty(caseRecord.DecantType__c) 
                            && caseRecord.CaseType__c == CaseDecorator.CASETYPE_DECANT 
                            && caseRecord.DecantType__c == CaseDecorator.TENANCY_DECANT_CASE_TYPE_TEMPORARY){
                        this.caseIdsForFCAMilestone.add(caseRecord.Id);
                    }
                }
            }
            return this.caseIdsForFCAMilestone;
        }
        set;
    }

    private Map<Id, CaseMilestone> FCAMilestoneByCaseIdMap{
        get{
            this.FCAMilestoneByCaseIdMap = new Map<Id, CaseMilestone>();
            if(!this.caseIdsForFCAMilestone.isEmpty()){
                for(CaseMilestone cm : [SELECT Id, CaseId, StartDate 
                        FROM CaseMilestone
                        WHERE caseId IN: caseIdsForFCAMilestone AND 
                              MilestoneType.Name =: CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT AND 
                              IsCompleted = FALSE ORDER BY CreatedDate DESC]){
                    if(!FCAMilestoneByCaseIdMap.containsKey(cm.CaseId)){
                        FCAMilestoneByCaseIdMap.put(cm.CaseId, cm);
                    }
                }
            }
            return this.FCAMilestoneByCaseIdMap;
        }
        set;
    }

    private String parseStringRemoveId(String stringToParse, String msIdToRemove){
        List<String> idList = new List<String>();
        for(String item : stringToParse.split(';')){
            if(!item.equals(msIdToRemove)){
                idList.add(item);
            }
        }
        return String.join(idList, ';');
    }
}