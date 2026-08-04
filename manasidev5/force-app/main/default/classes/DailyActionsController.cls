public without sharing class DailyActionsController {
    @AuraEnabled
    public static ServiceResourceStep__c getDailyActionRecord() {
            List<ServiceResourceStep__c> serviceResourceStepRecords = [
            SELECT Id, AbsOrIssueReportingCheckDT__c, CanYouProceedWithFirstSA__c, DueDate__c, OutcomeOfTLCall__c, ReadyToWork__c,
            ReasonVanCheckCannotBeCompleted__c, ServiceResource__c, VanCheckCompleted__c, VanCheckDT__c
            FROM ServiceResourceStep__c
            WHERE ServiceResource__r.RelatedRecordId = :UserInfo.getUserId() AND ServiceResource__r.IsActive = true
            AND DueDate__c = TODAY
            LIMIT 1];

            if(serviceResourceStepRecords.isEmpty()){
                throw new AuraHandledException('Please login again. If the error persists, please contact System admnistrator');
            }

            return serviceResourceStepRecords[0];
    }

    @AuraEnabled
    public static void upadteDailyActionRecord(String aServiceResourceStepJSON){
        try {
            ServiceResourceStep__c aServiceResrounceStepRecord =  (ServiceResourceStep__c)JSON.deserialize(aServiceResourceStepJSON, ServiceResourceStep__c.class ); 
            if(aServiceResrounceStepRecord.VanCheckCompleted__c != null){
                aServiceResrounceStepRecord.VanCheckDT__c = Datetime.now();
            }
            if(aServiceResrounceStepRecord.ReadyToWork__c != null){
                aServiceResrounceStepRecord.AbsOrIssueReportingCheckDT__c = Datetime.now();
            }
            update aServiceResrounceStepRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}