@isTest
public with sharing class UthServiceAppointment {

    public static ServiceAppointment create(string woId){
        ServiceAppointment sa = new ServiceAppointment();
        sa.ParentRecordId = woId;
        sa.SchedStartTime = Datetime.now();
        sa.Status = ServiceAppointmentDecorator.STATUS_NONE;
                sa.SchedStartTime = Datetime.now();
                sa.SchedEndTime = Datetime.now()+1;
                sa.EarliestStartTime = Datetime.now();
                sa.DueDate = Datetime.now()+7;
        Insert sa;
        return sa;
    }

    public static list<ServiceAppointment> getAll(){
        return Database.query('SELECT '+
                String.join(new List<String>(ServiceAppointment.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM ServiceAppointment');
    }

    public static ServiceAppointment create(string woId, Datetime scheduledTime){
        ServiceAppointment sa = new ServiceAppointment();
        sa.ParentRecordId = woId;
        sa.SchedStartTime =scheduledTime;
        sa.Status = ServiceAppointmentDecorator.STATUS_NONE;
                sa.SchedStartTime = scheduledTime;
                sa.SchedEndTime = scheduledTime;
                sa.EarliestStartTime = scheduledTime;
                sa.DueDate = scheduledTime;
        Insert sa;
        return sa;
    }
    public static list<ServiceAppointment> create(map<Id,Integer> saCountByWoId){
        list<ServiceAppointment> saList = new list<ServiceAppointment>();
        for(Id woId : saCountByWoId.keySet()){
            for(Integer i=0; i<saCountByWoId.get(woId); i++){
                ServiceAppointment sa = new ServiceAppointment();
                sa.ParentRecordId = woId;
                sa.Status = ServiceAppointmentDecorator.STATUS_NONE;
                sa.SchedStartTime = Datetime.now();
                sa.SchedEndTime = Datetime.now()+1;
                sa.EarliestStartTime = Datetime.now();
                sa.DueDate = Datetime.now()+7;
                saList.add(sa);
            }
        }
        Insert saList;
        return saList;
    }
}