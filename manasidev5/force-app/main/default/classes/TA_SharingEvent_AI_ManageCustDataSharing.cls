public without sharing class TA_SharingEvent_AI_ManageCustDataSharing implements TriggerAction.AfterInsert{

    public void afterInsert(List<PortalRecordSharingEvent__e> newList){
        for(PortalRecordSharingEvent__e sharingEvent : newList){
            String objectName;
            List<String> recordIds = sharingEvent.RecordIds__c.split(',');
            
            if(!recordIds.isEmpty()){
                Id recordId = (ID) recordIds[0];
                IManageCustomerDataSharing manageCustomerDataSharingInstance = new ManageCustomerMemberSharingFactory(recordId.getSObjectType()).getInstance();
                manageCustomerDataSharingInstance.manageRecordSharing(
                    recordIds,
                    ManageCustomerDataSharingService.CHANGE_TYPE.valueOf(sharingEvent.ChangeType__c),
                    ManageCustomerDataSharingService.TRIGGER_CONTEXT.valueOf(sharingEvent.TriggerContext__c)
                );
            }
        }
    }
}