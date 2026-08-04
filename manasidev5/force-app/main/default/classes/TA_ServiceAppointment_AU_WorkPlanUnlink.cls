public without sharing class TA_ServiceAppointment_AU_WorkPlanUnlink  implements TriggerAction.AfterUpdate{
    
    public void afterUpdate(List<ServiceAppointment> newList, List<ServiceAppointment> oldList){
        map<Id,ServiceAppointment> saMap = new map<Id,ServiceAppointment>();
        Map<Id, ServiceAppointment> oldMap = new Map<Id, ServiceAppointment>(oldList);
        for(ServiceAppointment s : newList){
            if(oldMap.get(s.Id).StatusCategory == ServiceAppointmentDecorator.STATUS_DISPATCHED && s.StatusCategory == ServiceAppointmentDecorator.STATUS_NONE){
                saMap.put(s.Id, s);
            }
        }

        if(!saMap.isEmpty()){
            System.enqueueJob(new WorkPlanUnlinkService.WorkPlanUnlinkQueueable(saMap));
        }
    }
}