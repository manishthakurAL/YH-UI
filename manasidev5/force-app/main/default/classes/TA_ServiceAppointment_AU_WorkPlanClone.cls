public without sharing class TA_ServiceAppointment_AU_WorkPlanClone implements TriggerAction.AfterUpdate{
    
    public void afterUpdate(List<ServiceAppointment> newList, List<ServiceAppointment> oldList){
        map<Id,ServiceAppointment> saMap = new map<Id,ServiceAppointment>();
        Map<Id, ServiceAppointment> oldMap = new Map<Id, ServiceAppointment>(oldList);  
        
        for(ServiceAppointment saRec : newList){
            if(oldMap.get(saRec.Id).StatusCategory != ServiceAppointmentDecorator.STATUS_DISPATCHED && saRec.StatusCategory == ServiceAppointmentDecorator.STATUS_DISPATCHED){
                saMap.put(saRec.Id, saRec);         
            }
        }
        if(!saMap.isEmpty()){
            System.enqueueJob(new WorkPlanCloneService.WorkPlanCloneQueueable(saMap));
        }
    }
}