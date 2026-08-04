public with sharing class ShareCasesOnUserActivationQueueable implements Queueable {
    private List<Id> recordSharingCaseIds;

    public ShareCasesOnUserActivationQueueable(List<Id> recordSharingCaseIds) {
       this.recordSharingCaseIds = recordSharingCaseIds;  
    }

    public void execute(QueueableContext context) {
        if(this.recordSharingCaseIds != null && !this.recordSharingCaseIds.isEmpty()){
            new ManageCustomerDataSharingService(
                this.recordSharingCaseIds, 
                ManageCustomerDataSharingService.CHANGE_TYPE.RECORD_RECALCULATE_SHARING,
                ManageCustomerDataSharingService.TRIGGER_CONTEXT.UPDATE_RECORD).shareRecords();
        }
    }
}