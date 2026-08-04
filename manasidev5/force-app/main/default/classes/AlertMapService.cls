public inherited sharing class AlertMapService {
    private Map<Id, List<Member__c>> membersByPersonId;
    private Map<Id, List<Member__c>> membersByPropertyId;
    private Map<Id, List<Member__c>> membersByTenancyId;

    public AlertMapService(Map<Id, List<Member__c>> membersByPersonId, Map<Id, List<Member__c>> membersByPropertyId, Map<Id, List<Member__c>> membersByTenancyId){
        this.membersByPersonId = membersByPersonId; 
        this.membersByPropertyId = membersByPropertyId;
        this.membersByTenancyId = membersByTenancyId;
    }
    
    public List<AlertMap__c> buildAlertMapRec(Alert__c alertRec){
        List<AlertMap__c> alertMapRecList = new List<AlertMap__c>();
        for(Member__c memberRec : getMembers(alertRec)){
            alertMapRecList.add(
                new AlertMap__c(
                    Alert__c = alertRec.Id, 
                    Member__c = memberRec.Id,
                    Contact__c = memberRec.Contact__c,
                    Property__c = memberRec.Tenancy__r != null ? memberRec.Tenancy__r.Property__c : null,
                    Tenancy__c = memberRec.Tenancy__c,
                    Notes__c = alertRec.Notes__c
                )
            );
        }
        return alertMapRecList;
    }

    private List<Member__c> getMembers(Alert__c alertRec){
        List<Member__c> memRecords = new List<Member__c>();
        if(alertRec.Type__c == AlertDecorator.TYPE_PERSON){
            if(alertRec.Contact__c != null && this.membersByPersonId.containsKey(alertRec.Contact__c)){
                memRecords = this.membersByPersonId.get(alertRec.Contact__c);
            }
        }else if(alertRec.Type__c == AlertDecorator.TYPE_PROPERTY){
            if(alertRec.Property__c != null && this.membersByPropertyId.containsKey(alertRec.Property__c)){
                memRecords = this.membersByPropertyId.get(alertRec.Property__c);
            }
        }else if(alertRec.Type__c == AlertDecorator.TYPE_TENANCY){
            if(alertRec.Tenancy__c != null && this.membersByTenancyId.containsKey(alertRec.Tenancy__c)){
                memRecords = this.membersByTenancyId.get(alertRec.Tenancy__c);
            }
        }
        return memRecords;
    }
}