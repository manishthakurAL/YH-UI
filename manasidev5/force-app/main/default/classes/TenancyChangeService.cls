public with sharing class TenancyChangeService {

    public static final List<String> MANAGE_MEMBERS_FOR_CHANGE_CASETYPES = new List<String>{
        CaseDecorator.CASE_TYPE_JOINT_TO_SOLE,
        CaseDecorator.CASE_TYPE_SOLE_TO_JOINT,
        CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_NO_SUCCESSOR,
        CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_SUCCESSOR,
        CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_SURVIVOR
    };

    public static final List<String> MANAGE_CASEOUTCOME_STARTERTENANCIES = new List<String>{
        CaseDecorator.CASETYPE_STARTERTENANCY12MONTHREVIEW,
        CaseDecorator.CASETYPE_STARTERTENANCY18MONTHREVIEW
    };

    public static final Map<String, String> TENANCYFIELD_BY_CASETYPE_DEFER{
        get {
            if(TENANCYFIELD_BY_CASETYPE_DEFER == null) {
                TENANCYFIELD_BY_CASETYPE_DEFER = new Map<String, String>{
                    CaseDecorator.CASETYPE_STARTERTENANCY12MONTHREVIEW => YH_Tenancy__c.DeferReviewDate9month__c.getDescribe().getName(),
                    CaseDecorator.CASETYPE_STARTERTENANCY18MONTHREVIEW => YH_Tenancy__c.DeferReviewDate15month__c.getDescribe().getName()
                   
                };
            }
            return TENANCYFIELD_BY_CASETYPE_DEFER;
        }
        set;
    }

    public static final Map<String, String> TENANCYFIELD_EXTENSION{
        get {
            if(TENANCYFIELD_EXTENSION == null) {
                TENANCYFIELD_EXTENSION = new Map<String, String>{
                    CaseDecorator.CASETYPE_STARTERTENANCY12MONTHREVIEW => YH_Tenancy__c.ConversionDate__c.getDescribe().getName()
                };
            }
            return TENANCYFIELD_EXTENSION;
        }
        set;
    }

    private Map<Id,List<CaseRole__c>> caseRolesByTenancyChangeIdMap{
        get{
            if(this.caseRolesByTenancyChangeIdMap == null){
                this.caseRolesByTenancyChangeIdMap = new Map<Id,List<CaseRole__c>>();
                if(this.tenancyChangeByCaseIdMap != null && !this.tenancyChangeByCaseIdMap.isEmpty()){
                    for(CaseRole__c caseRoleRec : [SELECT Id, Case__c, Role__c, Contact__c 
                                FROM CaseRole__c 
                                WHERE Case__c IN:tenancyChangeByCaseIdMap.keySet()]){
                        if (!caseRolesByTenancyChangeIdMap.containsKey(tenancyChangeByCaseIdMap.get(caseRoleRec.Case__c).Id)) {
                            caseRolesByTenancyChangeIdMap.put(tenancyChangeByCaseIdMap.get(caseRoleRec.Case__c)?.Id,new List<CaseRole__c>());
                        }
                        caseRolesByTenancyChangeIdMap.get(tenancyChangeByCaseIdMap.get(caseRoleRec.Case__c).Id).add(caseRoleRec);
                        memberContactIds.add(caseRoleRec.Contact__c);
                    }
                }
            }
            return caseRolesByTenancyChangeIdMap;
        }
        set;
    }

    private Map<Id,Case> caseByCaseIdMap{
        get{
            if(this.caseByCaseIdMap == null){
                this.caseByCaseIdMap = new Map<Id,Case>();
                if(this.tenancyChangeByCaseIdMap != null && !this.tenancyChangeByCaseIdMap.isEmpty()){
                    for(Case cseRec : [SELECT Id, Tenancy__c, Tenancy__r.ConversionDate__c, DateOfDeath__c,Tenancy__r.Property__r.Address__c
                                FROM Case 
                                WHERE Id IN:tenancyChangeByCaseIdMap.keySet()]){
                        caseByCaseIdMap.put(cseRec.Id, cseRec);
                    }
                }
            }
            return caseByCaseIdMap;
        }
        set;
    }

    private Map<String, Member__c> memberMap{
        get{
            if(this.memberMap == null){
                this.memberMap = new Map<String, Member__c>();
                if(!this.memberContactIds.isEmpty()){
                    for(Member__c member : [SELECT Id, DateOfOccupancy__c, OccupancyEndDate__c, Contact__c, Tenancy__c
                                                FROM Member__c 
                                                WHERE Contact__c IN:memberContactIds AND IsActive__c = true]) {
                        memberMap.put(member.Contact__c + '-' + member.Tenancy__c, member);
                    }
                }
            }
            return memberMap;
        }
        set;
    } 

    private Map<Id,TenancyChange__c> tenancyChangeByCaseIdMap;
    private List<Id> memberContactIds;

    public TenancyChangeService(Map<Id,TenancyChange__c> tenancyChangeByCaseIdMap) {
        this.tenancyChangeByCaseIdMap = tenancyChangeByCaseIdMap;
        this.memberContactIds =  new List<Id>();
    }

    public void populateDatesOnTenancyBasedOnCaseOutcome(){
        String fieldName;
        List<YH_Tenancy__c> tenancies = new List<YH_Tenancy__c>();
        for(TenancyChange__c tenancyChangeRecord : this.tenancyChangeByCaseIdMap.values()){
            if( tenancyChangeRecord.CaseOutcome__c == CaseDecorator.CASE_OUTCOME_DEFER ){
                fieldName = TENANCYFIELD_BY_CASETYPE_DEFER.get(tenancyChangeRecord.ParentCaseType__c);
                YH_Tenancy__c aTenancy = new YH_Tenancy__c(Id = caseByCaseIdMap.get(tenancyChangeRecord.Case__c).Tenancy__c
                            ,IsStarterTenancyAutoCreated__c = false);
                aTenancy.put(fieldName, tenancyChangeRecord.DeferReviewDate__c);
                tenancies.add(aTenancy);
            }  
            else if( tenancyChangeRecord.CaseOutcome__c == CaseDecorator.CASE_OUTCOME_EXTEND ){
                fieldName = TENANCYFIELD_EXTENSION.get(tenancyChangeRecord.ParentCaseType__c);
                Date tenancyEndDate = caseByCaseIdMap.get(tenancyChangeRecord.Case__c).Tenancy__r.ConversionDate__c;
                if(tenancyEndDate != null){
                    Date conversionDate = tenancyEndDate.addMonths(6);
                    YH_Tenancy__c aTenancy = new YH_Tenancy__c(Id = caseByCaseIdMap.get(tenancyChangeRecord.Case__c).Tenancy__c
                                ,IsStarterTenancyAutoCreated__c = false, IsStarterTenancyExtended__c = true);
                    aTenancy.put(fieldName, conversionDate);
                    tenancies.add(aTenancy);
                }
            }  
            else if( tenancyChangeRecord.CaseOutcome__c == CaseDecorator.CASE_OUTCOME_CONVERT ){
                YH_Tenancy__c aTenancy = new YH_Tenancy__c(Id = caseByCaseIdMap.get(tenancyChangeRecord.Case__c).Tenancy__c
                            ,StarterTenancyMarkedForConversion__c = true);
                tenancies.add(aTenancy);  
            } 
             
        }
        if(!tenancies.isEmpty()){
            update tenancies;
        }        
    }

    public Map<Id, String> applyChanges(){
        List<Member__c> membersToInsertList = new List<Member__c>();
        List<Member__c> membersToUpdatetList = new List<Member__c>();
        List<Contact> contactsToUpdate = new List<Contact>();
        List<YH_Tenancy__c> tenancyToUpdate = new List<YH_Tenancy__c>();
        Map<Id, String> tenancyChangeErrorById = new Map<Id, String>();
        MemberService memberService = new MemberService();
        ContactService contactService = new ContactService();

        for(TenancyChange__c tenancyChangeRecord : this.tenancyChangeByCaseIdMap.values()){
            Boolean isTenantCaseRolePresent = false;
            List<Id> tenantContactIds = new List<Id>();
            List<Id> outgoingContactIds = new List<Id>();
            List<Id> deathOfTenantContactIds = new List<Id>();
            List<Id> successorContactIds = new List<Id>();
            for(CaseRole__c cr : caseRolesByTenancyChangeIdMap.get(tenancyChangeRecord.Id)){
                if(tenancyChangeRecord.ParentCaseType__c ==  CaseDecorator.CASE_TYPE_SOLE_TO_JOINT){
                    if(cr.Role__c == CaseRoleDecorator.APPLICANT_ROLE){
                        isTenantCaseRolePresent = true;
                        tenantContactIds.add(cr.Contact__c);
                    }
                } else if(tenancyChangeRecord.ParentCaseType__c ==  CaseDecorator.CASE_TYPE_JOINT_TO_SOLE){
                    if(cr.Role__c == CaseRoleDecorator.TENANT_ROLE){
                        isTenantCaseRolePresent = true;
                        tenantContactIds.add(cr.Contact__c);
                    }
                    if(cr.Role__c ==  CaseRoleDecorator.OUTGOING_CUSTOMER_ROLE){
                        outgoingContactIds.add(cr.Contact__c);
                    }
                } else if(tenancyChangeRecord.ParentCaseType__c ==  CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_NO_SUCCESSOR
                            || tenancyChangeRecord.ParentCaseType__c ==  CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_SUCCESSOR
                            || tenancyChangeRecord.ParentCaseType__c ==  CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_SURVIVOR){
                    if(cr.Role__c ==  CaseRoleDecorator.CUSTOMER_DECEASED_ROLE){
                        deathOfTenantContactIds.add(cr.Contact__c);
                    }
                    if(tenancyChangeRecord.ParentCaseType__c ==  CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_SUCCESSOR){
                        if(cr.Role__c == CaseRoleDecorator.APPLICANT_ROLE){
                            successorContactIds.add(cr.Contact__c);
                        }
                    }
                }
            }

            if(tenancyChangeRecord.ParentCaseType__c ==  CaseDecorator.CASE_TYPE_SOLE_TO_JOINT){
                if(!isTenantCaseRolePresent){
                    tenancyChangeErrorById.put(tenancyChangeRecord.Id, LABEL.CaseRoleApplicantMissingError);
                }

                if (!tenantContactIds.isEmpty()) {
                    membersToInsertList.add(
                        memberService.createMember(
                            caseByCaseIdMap.get(tenancyChangeRecord.Case__c).Tenancy__c,
                            tenantContactIds[0],
                            MemberDecorator.TYPE_JOINT,
                            tenancyChangeRecord.SoleToJointDate__c,
                            CaseDecorator.CASE_TYPE_SOLE_TO_JOINT,
                            caseByCaseIdMap.get(tenancyChangeRecord.Case__c)?.Tenancy__r?.Property__r?.Address__c
                        )
                    );
                }
            }

            if(tenancyChangeRecord.ParentCaseType__c ==  CaseDecorator.CASE_TYPE_JOINT_TO_SOLE){
                if(!isTenantCaseRolePresent){
                    tenancyChangeErrorById.put(tenancyChangeRecord.Id, LABEL.CaseRoleAddTenantError);
                }
                
                if(outgoingContactIds.isEmpty()){
                    tenancyChangeErrorById.put(tenancyChangeRecord.Id, LABEL.CaseRoleOutgoingCustomerError);
                } else if(!outgoingContactIds.isEmpty() && outgoingContactIds.size() > 1){
                    tenancyChangeErrorById.put(tenancyChangeRecord.Id, LABEL.CaseRoleMoreOutgoingCustomerError);
                } else if(!outgoingContactIds.isEmpty() && outgoingContactIds.size() == 1){
                    String key = outgoingContactIds[0] + '-' + caseByCaseIdMap.get(tenancyChangeRecord.Case__c).Tenancy__c;
                    if(this.memberMap.containsKey(key)){
                        membersToUpdatetList.add(
                            memberService.setOccupancyEndDate(
                                this.memberMap.get(key),
                                tenancyChangeRecord.JointToSoleDate__c
                            )
                        );
                    }
                }
            }

            if(tenancyChangeRecord.ParentCaseType__c ==  CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_NO_SUCCESSOR
                    || tenancyChangeRecord.ParentCaseType__c ==  CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_SUCCESSOR
                    || tenancyChangeRecord.ParentCaseType__c ==  CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_SURVIVOR){
                
                if(tenancyChangeRecord.ParentCaseType__c ==  CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_SUCCESSOR){
                    if(successorContactIds.isEmpty()){
                        tenancyChangeErrorById.put(tenancyChangeRecord.Id, LABEL.CaseRoleApplicantError);
                    } else if(!successorContactIds.isEmpty() && successorContactIds.size() > 1){
                        tenancyChangeErrorById.put(tenancyChangeRecord.Id, LABEL.CaseRoleMoreApplicantError);
                    }
                }
                
                if(deathOfTenantContactIds.isEmpty()){
                    tenancyChangeErrorById.put(tenancyChangeRecord.Id, LABEL.CaseRoleCustomerDeseasedError);
                } else if(!deathOfTenantContactIds.isEmpty() && deathOfTenantContactIds.size() > 1){
                    tenancyChangeErrorById.put(tenancyChangeRecord.Id, LABEL.CaseRoleMoreCustomerDeseasedError);
                } else if(!deathOfTenantContactIds.isEmpty() && deathOfTenantContactIds.size() == 1){
                    String key = deathOfTenantContactIds[0] + '-' + caseByCaseIdMap.get(tenancyChangeRecord.Case__c).Tenancy__c;
                    if(this.memberMap.containsKey(key)){
                        if(tenancyChangeRecord.ParentCaseType__c ==  CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_SUCCESSOR){
                            membersToUpdatetList.add(
                                memberService.setOccupancyEndDate(
                                    this.memberMap.get(key),
                                    tenancyChangeRecord.SuccessionDate__c
                                )
                            );
                            if(!successorContactIds.isEmpty() && successorContactIds.size() == 1){
                                membersToInsertList.add(
                                    memberService.createMember(
                                        caseByCaseIdMap.get(tenancyChangeRecord.Case__c).Tenancy__c,
                                        successorContactIds[0],
                                        MemberDecorator.TYPE_JOINT,
                                        tenancyChangeRecord.SuccessionDate__c,
                                        CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_SUCCESSOR,
                                        caseByCaseIdMap.get(tenancyChangeRecord.Case__c)?.Tenancy__r?.Property__r?.Address__c
                                    )
                                );
                            }
                        } else if(tenancyChangeRecord.ParentCaseType__c ==  CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_SURVIVOR){
                            membersToUpdatetList.add(
                                memberService.setOccupancyEndDate(
                                    this.memberMap.get(key),
                                    tenancyChangeRecord.SurvivorshipDate__c
                                )
                            );
                        }

                        contactsToUpdate.add(
                            contactService.setDateOfDeath(
                                deathOfTenantContactIds[0],
                                caseByCaseIdMap.get(tenancyChangeRecord.Case__c).DateOfDeath__c
                            )
                        );
                    }
                }
            }
        }

        if(!membersToInsertList.isEmpty()){
            insert membersToInsertList;
        }

        if(!membersToUpdatetList.isEmpty()){
            update membersToUpdatetList;
        }

        if(!contactsToUpdate.isEmpty()){
            update contactsToUpdate;
        }

        if(!tenancyToUpdate.isEmpty()){
            update tenancyToUpdate;
        }

        return tenancyChangeErrorById;
    }
}