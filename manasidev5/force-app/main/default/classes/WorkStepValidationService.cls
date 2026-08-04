public with sharing class WorkStepValidationService {
    private Id  operativeId;
    public WorkStepValidationService(Id userId){
        this.operativeId = userId;
    }


    public String checkIfDailyActionsAreCompleted(){
        String message;
        if( !String.isBlank(this.operativeId) ){
            List<AssignedResource> assignedResources = [SELECT Id, ServiceResourceId FROM AssignedResource 
                    WHERE ServiceResource.RelatedRecordId =:this.operativeId AND DAY_ONLY(convertTimezone(ServiceAppointment.SchedStartTime)) = TODAY AND
                        ServiceResource.BypassOperativeWorkStepValidations__c = FALSE ];
            
            If( !assignedResources.isEmpty() ){
                List<ServiceResourceStep__c> serviceResourceSteps = [SELECT Id, ServiceResourceStepCompleted__c,
                AbsOrIssueReportingCheckDT__c, VanCheckCompleted__c, CanYouProceedWithFirstSA__c,
                ReadyToWork__c, VanCheckDT__c, IsVanCheckCompleted__c, AbsorIssueReportingCheckCompleted__c,
                IsOperativeReadytoWork__c
                FROM ServiceResourceStep__c WHERE ServiceResource__r.RelatedRecordId =:operativeId AND  
                ServiceResource__r.IsActive = TRUE AND DueDate__c = TODAY];
                if(!serviceResourceSteps.isEmpty()){
                    ServiceResourceStep__c serviceResourceStepRecord = serviceResourceSteps[0];
                    message = fetchValidationMessage(serviceResourceStepRecord);
                }else{
                    message = Label.NoDailyActionRecordFound;
                }
            }
        }
       return message;
    }

    private String fetchValidationMessage(ServiceResourceStep__c srsRecord){
        String message;
        if(!srsRecord.IsVanCheckCompleted__c && !srsRecord.IsOperativeReadytoWork__c){
            message = Label.AbsenceReporting;
        }
        else if( !srsRecord.ServiceResourceStepCompleted__c ){
            message = Label.OutstandingDailyTasks;
        }
        return message;
    }
}