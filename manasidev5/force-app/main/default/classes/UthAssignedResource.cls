@isTest
public with sharing class UthAssignedResource {
    public static void create(set<Id> saIds, string resourceId){
        list<AssignedResource> ars = new list <AssignedResource>();
        for(Id saId : saIds){
            AssignedResource ar = new AssignedResource();
            ar.ServiceAppointmentId = saId;
            ar.ServiceResourceId = resourceId;
            ars.add(ar);
        }
        Insert ars;
    }
}