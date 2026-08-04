public with sharing class TA_WorkStep_AU_FileNameTweaking implements TriggerAction.AfterUpdate{

    public void afterUpdate(List<WorkStep> newList, List<WorkStep> oldList){
        
        Map<Id, WorkStep> oldMap = new Map<Id, WorkStep>(oldList);
        List<WorkStep> workSteps = new List<WorkStep>();
        for(WorkStep wsRec : newList){
            if(!String.isBlank(wsRec.UploadedFileNames__c) && wsRec.UploadedFileNames__c != oldMap.get(wsRec.Id).UploadedFileNames__c){
                workSteps.add(wsRec);
            }
        }
        
        if(!workSteps.isEmpty()){
            System.enqueueJob(new WorkStepFileNameTweakingService.WorkStepFileNameTweakingQueueable(workSteps), 1);
        }
    }
}