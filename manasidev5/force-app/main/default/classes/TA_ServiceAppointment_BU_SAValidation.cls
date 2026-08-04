public with sharing class TA_ServiceAppointment_BU_SAValidation implements TriggerAction.BeforeUpdate {
    public static void beforeUpdate(List<ServiceAppointment> newList, List<ServiceAppointment> oldList) {
        Id profileId = FSOrgSettings__c.getOrgDefaults().FSServiceResourceProfileID__c;
        
        if(profileId == UserInfo.getProfileId()){
            Map<Id, ServiceAppointment> oldMap = new Map<Id, ServiceAppointment>(oldList);           
            
            List<AssignedResource> assignedResources = [SELECT Id, ServiceResourceId, ServiceAppointmentId, ServiceResource.RelatedRecordId 
                FROM AssignedResource 
                WHERE ServiceAppointmentId IN :newList 
                AND DAY_ONLY(convertTimezone(ServiceAppointment.SchedStartTime)) = TODAY 
                AND ServiceResource.BypassOperativeWorkStepValidations__c = FALSE
                AND  ServiceResource.RelatedRecordId =: UserInfo.getUserId()];  
            
            Set<Id> serviceAppointmentIds = new Set<Id>();
            for(AssignedResource assignedResourceRecord : assignedResources){
                serviceAppointmentIds.add(assignedResourceRecord.ServiceAppointmentId);
            }

            
            WorkStepValidationService  wrs = new WorkStepValidationService(UserInfo.getUserId());
            String message = wrs.checkIfDailyActionsAreCompleted();
            for(ServiceAppointment aServiceAppointment: newList){
                if(!serviceAppointmentIds.isEmpty() && serviceAppointmentIds.contains(aServiceAppointment.Id)){
                    if(String.isNotEmpty(message)){
                    	aServiceAppointment.addError(message);
                    }
                }else{
                    aServiceAppointment.addError(Label.IncorrectServiceAppointmentUpdate);   
                }
            } 
        }
    }
}