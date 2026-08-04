@isTest
public with sharing class UthMember {
    public static Member__c build(Id contactId, Id tenancyId, String type){
        Member__c memberRecord = new Member__c(
            Contact__c = contactId,
            Tenancy__c = tenancyId,
            Type__c = type,
            OccupancyEndDate__c  = Date.today().addMonths(12)
        );
        return memberRecord;
    }

    public static Member__c build(Id contactId, Id tenancyId, String type, Boolean isActive){
        Member__c memberRecord = new Member__c(
            Contact__c = contactId,
            IsActiveValue__c = isActive,
            Tenancy__c = tenancyId,
            Type__c = type,
            OccupancyEndDate__c  = Date.today().addMonths(12)
        );
        return memberRecord;
    }

    public static Member__c buildWithOccupancyEndDate(Id contactId, Id tenancyId, String type, Date occupancyEndDate){
        Member__c memberRecord = new Member__c(
            Contact__c = contactId,
            Tenancy__c = tenancyId,
            Type__c = type,
            OccupancyEndDate__c  = occupancyEndDate
        );
        return memberRecord;
    }

    public static Member__c buildWithNullOccupancyEndDate(Id contactId, Id tenancyId, String type){
        Member__c memberRecord = new Member__c(
            Contact__c = contactId,
            Tenancy__c = tenancyId,
            Type__c = type
        );
        return memberRecord;
    }

    public static Member__c buildWithNullOccupancyEndDate(Id contactId, Id tenancyId, String type, Date dateOfOccupancy){
        Member__c memberRecord = new Member__c(
            Contact__c = contactId,
            Tenancy__c = tenancyId,
            Type__c = type,
            DateOfOccupancy__c = dateOfOccupancy
        );
        return memberRecord;
    }

    public static List<Member__c> getAll(){
        return Database.query('SELECT '+
                String.join(new List<String>(Member__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM Member__c');
    }

    public static List<Member__c> getMembersByContactId(Id contactId){
        return Database.query('SELECT '+
                String.join(new List<String>(Member__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM Member__c'
                + ' WHERE Contact__c = \'' + contactId + '\'');
    }
}