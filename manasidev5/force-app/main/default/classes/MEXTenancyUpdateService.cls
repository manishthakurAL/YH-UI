public with sharing class MEXTenancyUpdateService{

    private Map<Id, Case> caseMap;
    private Map<Id, YH_Tenancy__c> tenancyToUpdate;
    private Map<Id, YH_Tenancy__c> tenancyToInsert;
    private List<YH_Tenancy__c> tenancyToUpsert;
    private List<Member__c> membersToUpdate;
    private List<Member__c> membersToInsert;
    private Map<Id, YH_Mutual_Exchange__c> mexMap;
    private Map<Id,Id> mexToCaseMap;    
    private Map<Id,Id> mexToIncomingMexMap;
    private Map<Id,Id> mexToMovingToMexMap;
    private Map<Id,Address> propertyAddressByPropertId ;

    private Map<Id,Id> propertyToMexMap{
        get{
            if(this.propertyToMexMap == null){
                this.propertyToMexMap = new Map<Id,Id>();
                if(this.caseMap != null && !this.caseMap.isEmpty()){
                    for(YH_Mutual_Exchange__c mex : [SELECT Id,Case__c,ExchangeSwapNumber__c,InternalProperty__c,InternalProperty__r.Address__c,ExchangeSwapNumber__r.MutualExchangeType__c,ExternalAddress2__c,PropertyType__c
                                FROM YH_Mutual_Exchange__c 
                                WHERE Case__c =: this.caseMap.keyset() ]){
                        if(mex.PropertyType__c == MutualExchangeDecorator.PROPERTY_TYPE_INTERNAL){
                            this.mexToCaseMap.put(mex.Id, mex.Case__c);  
                            this.mexToIncomingMexMap.put(mex.Id, mex.ExchangeSwapNumber__c);
                            this.propertyToMexMap.put(mex.InternalProperty__c, mex.Id);
                            this.propertyAddressByPropertId.put(mex.InternalProperty__c,mex.InternalProperty__r.Address__c);
                        }
                        this.mexMap.put(mex.Id, mex); 
                        this.mexToMovingToMexMap.put(mex.ExchangeSwapNumber__c,mex.Id);                      
                    }
                }
            }
            return this.propertyToMexMap;
        }
        set;
    }

    private Map<Id, List<MutualExchangeApplicant__c>> internalMexToApplicantMap{
        get{
            if(this.internalMexToApplicantMap == null){
                this.internalMexToApplicantMap = new Map<Id, List<MutualExchangeApplicant__c>>();
                for(MutualExchangeApplicant__c mexApp : [SELECT Id,RelatedMutualExchange__c,RelatedContact__c,TenantType__c FROM MutualExchangeApplicant__c WHERE RelatedMutualExchange__c =: mexToIncomingMexMap.values()]){
                    if(internalMexToApplicantMap.containsKey(mexApp.RelatedMutualExchange__c)){
                        internalMexToApplicantMap.get(mexApp.RelatedMutualExchange__c).add(mexApp);
                    }else{
                        internalMexToApplicantMap.put(mexApp.RelatedMutualExchange__c, new List<MutualExchangeApplicant__c>{mexApp});
                    }
                }
            }
            return this.internalMexToApplicantMap;
        }
        set;
    }

    public MEXTenancyUpdateService(Map<Id, Case> caseMap){
        this.caseMap = caseMap;
        this.tenancyToUpdate = new Map<Id, YH_Tenancy__c>();
        this.tenancyToInsert = new Map<Id, YH_Tenancy__c>();
        this.tenancyToUpsert = new List<YH_Tenancy__c>();
        this.membersToUpdate = new List<Member__c>();
        this.membersToInsert = new List<Member__c>();
        this.mexMap = new Map<Id, YH_Mutual_Exchange__c>();
        this.mexToCaseMap = new Map<Id,Id>();    
        this.mexToIncomingMexMap = new Map<Id,Id>();
        this.propertyAddressByPropertId = new Map<Id,Address>();
        this.mexToMovingToMexMap = new Map<Id,Id>();
    }

    public void applyChanges(){
        this.addTenancyToUpdateRecords();
        this.addMembersToUpdateRecords();
        this.addTenancyAndMembersToInsertRecords();
        this.upsertTenancyAndMembers();
    }

    private void upsertTenancyAndMembers(){
        this.tenancyToUpsert.addAll(tenancyToUpdate.values());
        this.tenancyToUpsert.addAll(tenancyToInsert.values());

        if(!tenancyToUpsert.isEmpty()){
            MetadataTriggerHandler.bypass(TA_Tenancy_BU_RequireReasonEndDateChange.class.getName());
            Upsert tenancyToUpsert;
            MetadataTriggerHandler.clearBypass(TA_Tenancy_BU_RequireReasonEndDateChange.class.getName());
        }

        if(!membersToUpdate.isEmpty()){
            Update membersToUpdate;
        }

        if(!membersToInsert.isEmpty()){
            for(Member__c mem : membersToInsert){
                mem.Tenancy__c = mem.Tenancy__r.Id;
            }
            MetadataTriggerHandler.bypass(TA_Tenancy_BU_AddErrorWhenInactive.class.getName()); 
            Insert membersToInsert;
            MetadataTriggerHandler.clearBypass(TA_Tenancy_BU_AddErrorWhenInactive.class.getName());
        }        
    }

    private void addTenancyToUpdateRecords(){
        if(!this.propertyToMexMap.isEmpty()){
            for(YH_Tenancy__c ty : [SELECT Id,TenancyEndDate__c,PrimaryReasonForLeaving__c,Property__c,YH_AgreementType__c FROM YH_Tenancy__c 
                    WHERE Property__c =: this.propertyToMexMap.keyset() AND Active__c = TRUE]){
                Id mexId = this.propertyToMexMap.get(ty.Property__c);
                Id caseId = this.mexToCaseMap.get(mexId);
                ty.TenancyEndDate__c = this.caseMap.get(caseId).DeedofAssignmentDate__c + MutualExchangeDecorator.DEED_OF_ASSIGNMENT_DIFFERENCE_DATE;
                ty.PrimaryReasonForLeaving__c = TenancyDecorator.PRIMARY_REASON_FOR_LEAVING_MUTUAL_EXCHANGE;
                this.tenancyToUpdate.put(mexId, ty);
            }
        }
    }
    
    private void addMembersToUpdateRecords(){
        MemberService memberService = new MemberService();
        if(!this.propertyToMexMap.isEmpty()){
            for(Member__c mem : [SELECT Id,OccupancyEndDate__c,Tenancy__r.Property__c FROM Member__c 
                    WHERE Tenancy__r.Property__c =: this.propertyToMexMap.keyset() 
                    AND (OccupancyEndDate__c = NULL OR OccupancyEndDate__c >= TODAY)]){
                Id mexId = this.propertyToMexMap.get(mem.Tenancy__r.Property__c);
                Id caseId = this.mexToCaseMap.get(mexId);
                if(mem.OccupancyEndDate__c == NULL || this.caseMap.get(caseId).DeedofAssignmentDate__c + MutualExchangeDecorator.DEED_OF_ASSIGNMENT_DIFFERENCE_DATE < mem.OccupancyEndDate__c){
                    mem.OccupancyEndDate__c = this.caseMap.get(caseId).DeedofAssignmentDate__c + MutualExchangeDecorator.DEED_OF_ASSIGNMENT_DIFFERENCE_DATE;
                    if(this.mexMap.get(mexId) != NULL && this.mexMap.get(this.mexToMovingToMexMap.get(mexId))?.PropertyType__c == MutualExchangeDecorator.PROPERTY_TYPE_EXTERNAL){
                        mem = memberService.setSynchAddressOnDeactivation(mem,MutualExchangeDecorator.TYPE_MUTUAL_EXCHANGE,this.mexMap.get(this.mexToMovingToMexMap.get(mexId))?.ExternalAddress2__c);
                    }
                    this.membersToUpdate.add(mem);
                }
            }
        }
    }

    private void addTenancyAndMembersToInsertRecords(){
        for(Id prop : this.propertyToMexMap.keyset()){
            Id mexId = this.propertyToMexMap.get(prop);
            Id caseId = this.mexToCaseMap.get(mexId);
            MemberService memberService = new MemberService();
            String tenancyType;
            if(this.mexMap.get(mexId).ExchangeSwapNumber__r.MutualExchangeType__c != NULL){
                String exchangeType = this.mexMap.get(mexId).ExchangeSwapNumber__r.MutualExchangeType__c;
                tenancyType = exchangeType.substringAfter(MutualExchangeDecorator.SUBSTRING_AFTER_TO);
            }
            YH_Tenancy__c tNew = new YH_Tenancy__c();
            tnew.StartDate__c = this.caseMap.get(caseId).DeedofAssignmentDate__c;
            tnew.Property__c = prop;
            tnew.YH_AgreementType__c = this.tenancyToUpdate.get(mexId).YH_AgreementType__c;
            tnew.YH_ApplicationMethod__c = TenancyDecorator.APPLICATION_METHOD_ASSIGNMENT;
            tnew.YH_TenancyReason__c = TenancyDecorator.TENANCY_REASON_FOR_MUTUAL_EXCHANGE;
            tnew.YH_TenancyType__c = tenancyType;
            tenancyToInsert.put(mexToIncomingMexMap.get(mexId), tNew);

            if(internalMexToApplicantMap.containskey(mexToIncomingMexMap.get(mexId))){
                for(MutualExchangeApplicant__c app : internalMexToApplicantMap.get(mexToIncomingMexMap.get(mexId))){
                    Member__c mem =  memberService.createMember(
                                        null,
                                        app.RelatedContact__c,
                                        app.TenantType__c,
                                        this.caseMap.get(caseId).DeedofAssignmentDate__c,
                                        MutualExchangeDecorator.TYPE_MUTUAL_EXCHANGE,
                                        this.propertyAddressByPropertId.get(prop)
                                    );
                    mem.Tenancy__r = tnew;
                    this.membersToInsert.add(mem);
                }
            }
        }
    }
}