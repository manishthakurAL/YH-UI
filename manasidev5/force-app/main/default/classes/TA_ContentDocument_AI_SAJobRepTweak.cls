public without sharing class TA_ContentDocument_AI_SAJobRepTweak implements TriggerAction.AfterInsert{
    
    public void afterInsert(List<ContentDocument> newList){
        list<ContentDocument> contentDocumentList = new list<ContentDocument>();
        for(ContentDocument cdRec : newList){
            if(cdRec.Title.containsIgnoreCase(ContentDocumentDecorator.FS_DMC_FS_SERVICE_JOB_REPORT)){
                contentDocumentList.add(cdRec);
            }
        }

        if(!contentDocumentList.isEmpty()){
            System.enqueueJob(new ContentDocumentSAJobReportTweakService.ContentDocumentSAJobReportTweakQueueable(contentDocumentList), 1);
        }
    }
}