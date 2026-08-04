public inherited sharing class ManageAlertMappingAlertImpl implements IManageAlertMappingInterface{
    private List<Id> recordIds; 
    private List<Alert__c> personAlerts; 
    private List<Alert__c> propertyAlerts; 
    private List<Alert__c> tenancyAlerts; 
    private List<Id> personIds; 
    private List<Id> propertyIds; 
    private List<Id> tenancyIds; 

    private Map<Id, Alert__c> alertMap{
        get{
            if(this.alertMap == null){
                this.alertMap = new Map<Id, Alert__c>();
                for(Alert__c alertRec : [SELECT Id, Name, Type__c, Contact__c, Notes__c, Property__c, Tenancy__c
                                FROM Alert__c 
                                WHERE Id IN : this.recordIds]) {
                    if(alertRec.Type__c == AlertDecorator.TYPE_PERSON) {
                        this.personAlerts.add(alertRec);
                        this.personIds.add(alertRec.Contact__c);
                    }else if (alertRec.Type__c == AlertDecorator.TYPE_PROPERTY) {
                        this.propertyAlerts.add(alertRec);
                        this.propertyIds.add(alertRec.Property__c);
                    }else if (alertRec.Type__c == AlertDecorator.TYPE_TENANCY) {
                        this.tenancyAlerts.add(alertRec);
                        this.tenancyIds.add(alertRec.Tenancy__c);
                    }
                    this.alertMap.put(alertRec.Id, alertRec);                      
                }
            }
            return this.alertMap;
        }
        set;
    }

    private Map<Id, List<Member__c>> membersByPersonId{
        get{
            if(this.membersByPersonId == null){
                this.membersByPersonId = new Map<Id, List<Member__c>>();
                if(!this.personIds.isEmpty()){
                    for(Member__c memRec : [SELECT Id, Contact__c, Tenancy__c, Tenancy__r.Property__c
                                FROM Member__c 
                                WHERE Contact__c IN : this.personIds AND 
                                IsActive__c = true AND 
                                (Type__c =: MemberDecorator.TYPE_SOLO OR Type__c =: MemberDecorator.TYPE_JOINT)]){
                        if(!this.membersByPersonId.containsKey(memRec.Contact__c)){
                            this.membersByPersonId.put(memRec.Contact__c, new List<Member__c>{memRec});
                        }else{
                            this.membersByPersonId.get(memRec.Contact__c).add(memRec);
                        }
                    }
                }
            }
            return this.membersByPersonId;
        }
        set;
    }

    private Map<Id, List<Member__c>> membersByPropertyId{
        get{
            if(this.membersByPropertyId == null){
                this.membersByPropertyId = new Map<Id, List<Member__c>>();
                if(!this.propertyIds.isEmpty()){
                    for(Member__c memRec : [SELECT Id, Contact__c, Tenancy__c, Tenancy__r.Property__c
                                FROM Member__c 
                                WHERE Tenancy__r.Property__c IN : this.propertyIds AND 
                                IsActive__c = true AND 
                                (Type__c =: MemberDecorator.TYPE_SOLO OR Type__c =: MemberDecorator.TYPE_JOINT)]){
                        if(!this.membersByPropertyId.containsKey(memRec.Tenancy__r.Property__c)){
                            this.membersByPropertyId.put(memRec.Tenancy__r.Property__c, new List<Member__c>{memRec});
                        }else{
                            this.membersByPropertyId.get(memRec.Tenancy__r.Property__c).add(memRec);
                        }
                    }
                }
            }
            return this.membersByPropertyId;
        }
        set;
    }

    private Map<Id, List<Member__c>> membersByTenancyId{
        get{
            if(this.membersByTenancyId == null){
                this.membersByTenancyId = new Map<Id, List<Member__c>>();
                if(!this.tenancyIds.isEmpty()){
                    for(Member__c memRec : [SELECT Id, Contact__c, Tenancy__c, Tenancy__r.Property__c
                                FROM Member__c 
                                WHERE Tenancy__c IN : this.tenancyIds AND 
                                IsActive__c = true AND 
                                (Type__c =: MemberDecorator.TYPE_SOLO OR Type__c =: MemberDecorator.TYPE_JOINT)]){
                        if(!this.membersByTenancyId.containsKey(memRec.Tenancy__c)){
                            this.membersByTenancyId.put(memRec.Tenancy__c, new List<Member__c>{memRec});
                        }else{
                            this.membersByTenancyId.get(memRec.Tenancy__c).add(memRec);
                        }
                    }
                }
            }
            return this.membersByTenancyId;
        }
        set;
    }
    
    private List<AlertMap__c> personAlertMapList{
        get{
            if(this.personAlertMapList == null){
                this.personAlertMapList = new List<AlertMap__c>();
                if(this.alertMap != null && !this.membersByPersonId.isEmpty()){
                    AlertMapService alertMapService = instantiateService();
                    for(Alert__c alertRec : this.personAlerts){
                        this.personAlertMapList.addAll(alertMapService.buildAlertMapRec(alertRec));
                    }
                }
            }
            return this.personAlertMapList;
        }
        set;
    }
    
    private List<AlertMap__c> propertyAlertMapList{
        get{
            if(this.propertyAlertMapList == null){
                this.propertyAlertMapList = new List<AlertMap__c>();
                if(this.alertMap != null && !this.membersByPropertyId.isEmpty()){
                    AlertMapService alertMapService = instantiateService();
                    for(Alert__c alertRec : this.propertyAlerts){
                        this.propertyAlertMapList.addAll(alertMapService.buildAlertMapRec(alertRec));
                    }
                }
            }
            return this.propertyAlertMapList;
        }
        set;
    }
    
    private List<AlertMap__c> tenancyAlertMapList{
        get{
            if(this.tenancyAlertMapList == null){
                this.tenancyAlertMapList = new List<AlertMap__c>();
                if(this.alertMap != null && !this.membersByTenancyId.isEmpty()){
                    AlertMapService alertMapService = instantiateService();
                    for(Alert__c alertRec : this.tenancyAlerts){
                        this.tenancyAlertMapList.addAll(alertMapService.buildAlertMapRec(alertRec));
                    }
                }
            }
            return this.tenancyAlertMapList;
        }
        set;
    }
    
    public void manageAlertMapping(List<Id> recordIds, ManageAlertMappingService.CHANGE_TYPE changeType, ManageAlertMappingService.TRIGGER_CONTEXT triggerContext){
        this.recordIds = recordIds;
        if(this.recordIds != null && !this.recordIds.isEmpty()){
            initializeAll();
            switch on changeType{
                when RECORD_ACTVIATED {
                    handleCreateAlertMapRecords();
                }
            }
        }
    }

    private void handleCreateAlertMapRecords(){
        List<AlertMap__c> alertMapRecordsToInsert = new List<AlertMap__c>();

        if(this.personAlertMapList != null && !this.personAlertMapList.isEmpty()){
            alertMapRecordsToInsert.addAll(this.personAlertMapList);
        }

        if(this.propertyAlertMapList != null && !this.propertyAlertMapList.isEmpty()){
            alertMapRecordsToInsert.addAll(this.propertyAlertMapList);
        }

        if(this.tenancyAlertMapList != null && !this.tenancyAlertMapList.isEmpty()){
            alertMapRecordsToInsert.addAll(this.tenancyAlertMapList);
        }

        if(!alertMapRecordsToInsert.isEmpty()){
            Database.SaveResult[] srList = Database.insert(alertMapRecordsToInsert, false);
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
        this.personAlerts = new List<Alert__c>();
        this.propertyAlerts = new List<Alert__c>();
        this.tenancyAlerts = new List<Alert__c>();
        this.personIds = new List<Id>();
        this.propertyIds = new List<Id>();
        this.tenancyIds = new List<Id>();
    }
}