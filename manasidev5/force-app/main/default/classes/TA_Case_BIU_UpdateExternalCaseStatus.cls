public with sharing class TA_Case_BIU_UpdateExternalCaseStatus implements TriggerAction.BeforeUpdate, TriggerAction.BeforeInsert{

    public void beforeUpdate(List<Case> newList, List<Case> oldList){
        updateCaseStatus(newList, new Map<Id, Case>(oldList));
    } 

    public void beforeInsert(List<Case> newList){
        updateCaseStatus(newList, null);
    }
    public void updateCaseStatus(List<Case> newList, Map<Id, Case> oldCaseMap){
        for(Case acase : newList){
            if(oldCaseMap == null || (acase.Status != oldCaseMap.get(acase.Id)?.Status)){
                acase.ExternalCaseStatus__c = caseStatusByCaseStageMap.get(acase.Status);
            }
        }   
    }
    private static  Map<String, String> caseStatusByCaseStageMap{
        get{
            if(caseStatusByCaseStageMap == null){
                caseStatusByCaseStageMap = new Map<String, String>();
                for(CaseIntStageToExtStatusMapping__mdt	 CaseIntStageToExtStatusMapping : CaseIntStageToExtStatusMapping__mdt.getAll().values()){
                    caseStatusByCaseStageMap.put(CaseIntStageToExtStatusMapping.CaseStage__c, CaseIntStageToExtStatusMapping.ExternalCaseStatus__c);
                }
            }
            return caseStatusByCaseStageMap;
        }
        set;
    }
}