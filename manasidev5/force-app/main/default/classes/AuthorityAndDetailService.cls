public with sharing class AuthorityAndDetailService {
    public static final Map<String, String> CASEROLE_BY_CASETYPE_FOR_CUSTOMER_CASE {
        get {
            if(CASEROLE_BY_CASETYPE_FOR_CUSTOMER_CASE == null) {
                CASEROLE_BY_CASETYPE_FOR_CUSTOMER_CASE = new Map<String, String>{
                    CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_NEW => CaseRoleDecorator.POA_INQUIRER_ROLE,
                    CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_REMOVE => CaseRoleDecorator.POA_ROLE, 
                    CaseDecorator.CASE_TYPE_DELEGATED_AUTHORITY_NEW => CaseRoleDecorator.DA_INQUIRER_ROLE,
                    CaseDecorator.CASE_TYPE_DELEGATED_AUTHORITY_REMOVE => CaseRoleDecorator.DA_ROLE
                };
            }
            return CASEROLE_BY_CASETYPE_FOR_CUSTOMER_CASE;
          }
          set;
    }

    public static final Map<String, String> ADVOCATETYPE_BY_CASETYPE_FOR_CUSTOMER_CASE{
        get {
            if(ADVOCATETYPE_BY_CASETYPE_FOR_CUSTOMER_CASE == null) {
                ADVOCATETYPE_BY_CASETYPE_FOR_CUSTOMER_CASE = new Map<String, String>{
                    CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_NEW => AdvocateDecorator.AUTHORIZATIONTYPE_POWER_OF_ATTORNEY, 
                    CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_REMOVE => AdvocateDecorator.AUTHORIZATIONTYPE_POWER_OF_ATTORNEY, 
                    CaseDecorator.CASE_TYPE_DELEGATED_AUTHORITY_NEW => AdvocateDecorator.AUTHORIZATIONTYPE_DELEGATED_AUTHORITY,
                    CaseDecorator.CASE_TYPE_DELEGATED_AUTHORITY_REMOVE => AdvocateDecorator.AUTHORIZATIONTYPE_DELEGATED_AUTHORITY
                };
            }
            return ADVOCATETYPE_BY_CASETYPE_FOR_CUSTOMER_CASE;
        }
        set;
    }

    public static final List<String> MANAGE_ADVOCATES_FOR_CUSTOMER_CASETYPES = new List<String>{
        CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_NEW,
        CaseDecorator.CASE_TYPE_DELEGATED_AUTHORITY_NEW,
        CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_REMOVE,
        CaseDecorator.CASE_TYPE_DELEGATED_AUTHORITY_REMOVE
    };

    private Map<Id,AuthorityAndDetail__c> authorityAndDetailByCaseIdMap;

    private List<Id> tenantIds;

    private Map<Id,List<CaseRole__c>> caseRolesByAuthorityDetailIdMap{
        get{
            this.caseRolesByAuthorityDetailIdMap = new Map<Id,List<CaseRole__c>>();
            if(this.authorityAndDetailByCaseIdMap != null && !this.authorityAndDetailByCaseIdMap.isEmpty()){
                for(CaseRole__c caseRoleRec : [SELECT Id, Case__c, Role__c, Contact__c 
                            FROM CaseRole__c 
                            WHERE Case__c IN:authorityAndDetailByCaseIdMap.keySet()]){
                    if (!caseRolesByAuthorityDetailIdMap.containsKey(authorityAndDetailByCaseIdMap.get(caseRoleRec.Case__c).Id)) {
                        caseRolesByAuthorityDetailIdMap.put(authorityAndDetailByCaseIdMap.get(caseRoleRec.Case__c)?.Id,new List<CaseRole__c>());
                    }
                    caseRolesByAuthorityDetailIdMap.get(authorityAndDetailByCaseIdMap.get(caseRoleRec.Case__c).Id).add(caseRoleRec);
                    if(caseRoleRec.Role__c ==  CaseRoleDecorator.TENANT_ROLE){
                        tenantIds.add(caseRoleRec.Contact__c);
                    }
                }
            }
            return caseRolesByAuthorityDetailIdMap;
        }
        set;
    }

    private Map<String, Advocate__c> advocateMap{
        get{
            if(this.advocateMap == null){
                this.advocateMap = new Map<String, Advocate__c>();
                if(!this.tenantIds.isEmpty()){
                    for(Advocate__c advocate : [SELECT Id,AuthorisedBy__c, AuthorisedTo__c, AuthorisationType__c 
                                                FROM Advocate__c 
                                                WHERE AuthorisedBy__c IN:tenantIds AND IsActive__c = true]) {
                        advocateMap.put(advocate.AuthorisedBy__c+'-'+advocate.AuthorisedTo__c+'-'+advocate.AuthorisationType__c, advocate);
                    }
                }
            }
            return advocateMap;
        }
        set;
    } 

    public AuthorityAndDetailService(Map<Id,AuthorityAndDetail__c> authorityAndDetailByCaseIdMap){
        this.authorityAndDetailByCaseIdMap = authorityAndDetailByCaseIdMap;
        this.tenantIds =  new List<Id>();
    }

    public Map<Id, String> applyChanges(){
        List<Advocate__c> advocateToInsertList = new List<Advocate__c>();
        List<Advocate__c> advocatesToUpdateList = new List<Advocate__c>();
        Map<Id, String> authDetailErrorById = new Map<Id, String>();
        Boolean isTenantCaseRolePresent;
        Boolean isInquirerRolePresent;
        AdvocateService advocateServ = new AdvocateService();
        for(AuthorityAndDetail__c authDetailRecord : this.authorityAndDetailByCaseIdMap.values()){
            isTenantCaseRolePresent = false;
            isInquirerRolePresent = false;
            List<Id> inquirerContactIds  = new List<Id>();
            List<Id> tenantContactIds = new List<Id>();
            if(caseRolesByAuthorityDetailIdMap.containsKey(authDetailRecord.Id)){
                for(CaseRole__c cr : caseRolesByAuthorityDetailIdMap.get(authDetailRecord.Id)){
                    if(cr.Role__c == CaseRoleDecorator.TENANT_ROLE){
                        isTenantCaseRolePresent = true;
                        tenantContactIds.add(cr.Contact__c);
                    } else if(cr.Role__c == CASEROLE_BY_CASETYPE_FOR_CUSTOMER_CASE.get(authDetailRecord.ParentCaseType__c)){
                        isInquirerRolePresent = true;
                        inquirerContactIds.add(cr.Contact__c);
                    }
                }
            }
            if(!isTenantCaseRolePresent){
                authDetailErrorById.put(authDetailRecord.Id, LABEL.CaseRoleAddTenantError);
            }
            if(!isInquirerRolePresent){
                authDetailErrorById.put(authDetailRecord.Id, LABEL.CaseRoleAddInquirerError);
            }
            if(!tenantContactIds.isEmpty() && tenantContactIds.size() > 1){
                authDetailErrorById.put(authDetailRecord.Id, LABEL.MoreThanOneTenantError);
            }
            if(isTenantCaseRolePresent && isInquirerRolePresent && tenantContactIds.size() == 1 && !inquirerContactIds.isEmpty()){
                String authType = ADVOCATETYPE_BY_CASETYPE_FOR_CUSTOMER_CASE.get(authDetailRecord.ParentCaseType__c);
                for(Id contactId : inquirerContactIds){
                    if(authDetailRecord.ParentCaseType__c == CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_REMOVE || 
                            authDetailRecord.ParentCaseType__c == CaseDecorator.CASE_TYPE_DELEGATED_AUTHORITY_REMOVE){
                        if(advocateMap.containsKey(tenantContactIds[0]+'-'+contactId+'-'+authType)){
                            advocatesToUpdateList.add(
                                advocateServ.deactivateAdvocate(advocateMap.get(tenantContactIds[0]+'-'+contactId+'-'+authType))
                            );
                        }
                        else{
                            authDetailErrorById.put(authDetailRecord.Id, LABEL.AdvocateNotFoundError);
                        }
                    } else if( (authDetailRecord.ParentCaseType__c == CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_NEW ||
                                   authDetailRecord.ParentCaseType__c == CaseDecorator.CASE_TYPE_DELEGATED_AUTHORITY_NEW) ){
                                if(!advocateMap.containsKey(tenantContactIds[0]+'-'+contactId+'-'+authType)){
                                    advocateToInsertList.add(
                                        advocateServ.createAdvocate(tenantContactIds[0],contactId,authDetailRecord,authType)
                                    );
                                }
                                else{
                                    authDetailErrorById.put(authDetailRecord.Id, LABEL.ActiveAdvocateAlreadyExistsError);
                                }
                    }
                }
            }
        }
        if(!advocateToInsertList.isEmpty()){
            insert advocateToInsertList;
        }
        if(!advocatesToUpdateList.isEmpty()){
            update advocatesToUpdateList;
        }
        return authDetailErrorById;
    }
}