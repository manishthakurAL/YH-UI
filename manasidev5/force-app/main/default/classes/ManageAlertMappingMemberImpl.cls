public inherited sharing class ManageAlertMappingMemberImpl implements IManageAlertMappingInterface{
    private List<Id> recordIds; 
    private Map<Id, List<Member__c>> membersByPersonId;
    private Map<Id, List<Member__c>> membersByPropertyId;
    private Map<Id, List<Member__c>> membersByTenancyId;
    private Set<Id> allIDs;

    private Map<Id, Member__c> memberMap{
        get{
            if(this.memberMap == null){
                this.memberMap = new Map<Id, Member__c>();
                for(Member__c memRec : [SELECT Id, Name, Contact__c, Tenancy__c, Tenancy__r.Property__c
                        FROM Member__c 
                        WHERE Id IN : this.recordIds]) {
                    memberMappings(memRec);                                            
                }
            }
            return this.memberMap;
        }
        set;
    }

    private List<AlertMap__c> alertMapRecordsToInsert{
        get{
            if(this.alertMapRecordsToInsert == null){
                this.alertMapRecordsToInsert = new List<AlertMap__c>();
                if(!this.memberMap.isEmpty() && !this.allIDs.isEmpty()){
                    AlertMapService alertMapService = instantiateService();
                    for(Alert__c alertRec : [SELECT Id, Type__c, Contact__c, Property__c, Tenancy__c, Notes__c
                                FROM Alert__c
                                WHERE IsActiveValue__c = true AND 
                                (Contact__c IN : this.allIDs OR
                                Property__c IN : this.allIDs OR
                                Tenancy__c IN : this.allIDs)]){
                        this.alertMapRecordsToInsert.addAll(alertMapService.buildAlertMapRec(alertRec));
                    }
                }
            }
            return this.alertMapRecordsToInsert;
        }
        set;
    }

    public void manageAlertMapping(List<Id> recordIds, ManageAlertMappingService.CHANGE_TYPE changeType, ManageAlertMappingService.TRIGGER_CONTEXT triggerContext){
        this.recordIds = recordIds;
        if(this.recordIds != null && !this.recordIds.isEmpty()){
            initializeAll();
            switch on changeType{
                when RECORD_ACTVIATED {
                    handleCreatememberMapRecords();
                }
            }
        }
    }

    private void handleCreatememberMapRecords(){
        if(!this.alertMapRecordsToInsert.isEmpty()){
            Database.SaveResult[] srList = Database.insert(this.alertMapRecordsToInsert, false);
        }
    }

    private void memberMappings(Member__c memRec){        
        this.memberMap.put(memRec.Id, memRec);  

        if(memRec.Contact__c != null){
            this.allIDs.add(memRec.Contact__c);
            if(!this.membersByPersonId.containsKey(memRec.Contact__c)){
                this.membersByPersonId.put(memRec.Contact__c, new List<Member__c>{memRec});
            }else{
                this.membersByPersonId.get(memRec.Contact__c).add(memRec);
            }
        }

        if(memRec.Tenancy__r.Property__c != null){
            this.allIDs.add(memRec.Tenancy__r.Property__c);
            if(!this.membersByPropertyId.containsKey(memRec.Tenancy__r.Property__c)){
                this.membersByPropertyId.put(memRec.Tenancy__r.Property__c, new List<Member__c>{memRec});
            }else{
                this.membersByPropertyId.get(memRec.Tenancy__r.Property__c).add(memRec);
            }
        }

        if(memRec.Tenancy__c != null){
            this.allIDs.add(memRec.Tenancy__c);
            if(!this.membersByTenancyId.containsKey(memRec.Tenancy__c)){
                this.membersByTenancyId.put(memRec.Tenancy__c, new List<Member__c>{memRec});
            }else{
                this.membersByTenancyId.get(memRec.Tenancy__c).add(memRec);
            }  
        }
    }

    private AlertMapService instantiateService(){
        return new AlertMapService(
            this.membersByPersonId, 
            this.membersByPropertyId, 
            this.membersByTenancyId
        );
    }

    private void initializeAll(){
        this.allIDs = new Set<Id>();
        this.membersByPersonId = new Map<Id, List<Member__c>>();
        this.membersByPropertyId = new Map<Id, List<Member__c>>();
        this.membersByTenancyId = new Map<Id, List<Member__c>>();
    }
}