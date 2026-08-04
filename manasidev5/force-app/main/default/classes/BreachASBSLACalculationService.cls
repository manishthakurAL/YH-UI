public with sharing class BreachASBSLACalculationService {
    private DateTime startDateTime;
    private List<Case> casesList;
    private Map<Id, Case> oldCasesMap;
    private List<Id> caseIdsForFCAMilestone{
        get{
            if(this.caseIdsForFCAMilestone == null){
                this.caseIdsForFCAMilestone = new List<Id>();
                for (Case caseRecord : this.casesList) {
                    if(this.oldCasesMap != null && caseRecord.Priority != oldCasesMap.get(caseRecord.Id).Priority){
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
            if(this.FCAMilestoneByCaseIdMap == null && !this.caseIdsForFCAMilestone.isEmpty()){
                this.FCAMilestoneByCaseIdMap = new Map<Id, CaseMilestone>();
                for(CaseMilestone cm : [SELECT Id, CaseId, StartDate 
                        FROM CaseMilestone
                        WHERE caseId IN: caseIdsForFCAMilestone AND 
                              MilestoneType.Name =: CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT AND 
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

    public BreachASBSLACalculationService(){
        this.startDateTime = System.now();
    }
    
    @TestVisible
    private BreachASBSLACalculationService(DateTime startDateTime){
        this.startDateTime = startDateTime;
    }

    public void calculateSLADates(List<Case> casesList1, Map<Id, Case> oldCasesMap1) {
        this.casesList = casesList1;
        this.oldCasesMap = oldCasesMap1;
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        
        for (Case caseRecord : this.casesList) {
            if (caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_BREACH_ASB) {
                Boolean isCaseReOpened = (this.oldCasesMap != null && 
                        (caseRecord.ReOpenedDate__c != this.oldCasesMap.get(caseRecord.Id).ReOpenedDate__c)? true : false);
                Set<String> runMilestonesForList = (!String.isBlank(caseRecord.RunMilestonesFor__c) && !isCaseReOpened)? new Set<String>(caseRecord.RunMilestonesFor__c.split(';')) : new Set<String>();
                if (caseRecord.Status ==  CaseDecorator.STATUS_NEW &&  
                        (this.oldCasesMap == null || (caseRecord.Priority != this.oldCasesMap.get(caseRecord.Id).Priority) || 
                        isCaseReOpened ))  {    
                    if(this.oldCasesMap != null && this.FCAMilestoneByCaseIdMap != null && this.FCAMilestoneByCaseIdMap.containsKey(caseRecord.Id)){
                        caseRecord.SLAStartDate__c = this.FCAMilestoneByCaseIdMap.get(caseRecord.Id).StartDate;

                        this.removeCaseMilestoneIds(caseRecord, this.FCAMilestoneByCaseIdMap.get(caseRecord.Id).Id);
                    }  else{
                        caseRecord.SLAStartDate__c = (caseRecord.SLAStartDate__c==null || isCaseReOpened)?businessHourService.getNextBusinessDay(this.startDateTime, null): caseRecord.SLAStartDate__c;
                    }                      
                    
                    this.calculateStartAndEndDate(caseRecord, businessHourService, (this.oldCasesMap == null || isCaseReOpened));
                    runMilestonesForList.add(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT);
                    runMilestonesForList.add(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION);
                    if(isCaseReOpened){
                        caseRecord.CompletedMilestones__c = null;        
                    }
                } else if(this.oldCasesMap != null && 
                        (caseRecord.CompletedMilestones__c != this.oldCasesMap.get(caseRecord.Id).CompletedMilestones__c) &&
                        (caseRecord.CompletedMilestones__c == CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT ||
                         caseRecord.CompletedMilestones__c == CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT))  {
                    caseRecord.SLAStartDate__c = businessHourService.getNextBusinessDay(this.startDateTime, null);
                    runMilestonesForList.remove(CaseMilestoneDecorator.CASE_MILESTONE_FIRST_CONTACT_ATTEMPT);
                    runMilestonesForList.add(CaseMilestoneDecorator.CASE_MILESTONE_CUSTOMER_CONTACT);
                } else if(this.oldCasesMap != null && 
                        (caseRecord.CompletedMilestones__c != this.oldCasesMap.get(caseRecord.Id).CompletedMilestones__c) &&
                        (caseRecord.CompletedMilestones__c == CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION ))  {
                    runMilestonesForList.remove(CaseMilestoneDecorator.CASE_MILESTONE_RESOLUTION);
                } 
                
                if (!runMilestonesForList.isEmpty()) {
                    caseRecord.RunMilestonesFor__c = String.join(new List<String>(runMilestonesForList),';');
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

    private String parseStringRemoveId(String stringToParse, String msIdToRemove){
        List<String> idList = new List<String>();
        for(String item : stringToParse.split(';')){
            if(!item.equals(msIdToRemove)){
                idList.add(item);
            }
        }
        return String.join(idList, ';');
    }

    @testvisible
    private void calculateStartAndEndDate(Case caseRecord, BusinessHourService businessHourService, Boolean isInsert){
        
        if (isInsert) {
            caseRecord.ResolutionTargetDateTime__c = businessHourService.addBusinessDays( this.startDateTime, CaseDecorator.TENANCY_CASE_60_RESOLUTION_DAYS);
        }
        Integer noOfDays = (caseRecord.Priority == CaseDecorator.PRIORITY_URGENT) ? CaseDecorator.TENANCY_COACHING_CASE_URGENT_PRIORITY_DAYS : CaseDecorator.TENANCY_COACHING_CASE_ROUTINE_PRIORITY_DAYS;
        
        caseRecord.SLAEndDate__c = businessHourService.addBusinessDays( this.startDateTime, noOfDays);

    }
}