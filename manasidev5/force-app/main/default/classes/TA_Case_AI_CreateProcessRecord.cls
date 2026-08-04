public inherited sharing class TA_Case_AI_CreateProcessRecord implements TriggerAction.AfterInsert{
    
    public void afterInsert(List<Case> newList){
        CaseProcessRecordManager.createProcessRecord(newList);
    }
}