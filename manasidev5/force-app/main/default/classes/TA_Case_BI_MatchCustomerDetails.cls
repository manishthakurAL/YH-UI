public without sharing class TA_Case_BI_MatchCustomerDetails  implements TriggerAction.BeforeInsert {
    
    private List<Case> newCaseList;
    private Map<String, CustomerMatchConfig> caseConfigMap;
    
    
    private class CustomerMatchConfig {
        public Id recordTypeId;
        public Set<String> caseOrigin;
        public Boolean dupeCheckRequired;
        public Boolean requireAllGivenFields;
        public List<String> requiredFields;
        public CustomerMatchConfig(Id rtId, Set<String> origin, Boolean dupeRule, Boolean requireAll, List<String> reqFields) {
            recordTypeId = rtId;
            caseOrigin = origin;
            dupeCheckRequired = dupeRule;
            requireAllGivenFields = requireAll;
            requiredFields = reqFields;
        }
    }
    
    private Map<Id, CustomerMatchConfig> customerMatchConfigMap {
        get {
            if (customerMatchConfigMap == null) {
                customerMatchConfigMap = new Map<Id, CustomerMatchConfig>();
                customerMatchConfigMap.put(CaseDecorator.RECORD_TYPE_ID_TERMINATION,
                    new CustomerMatchConfig(
                        CaseDecorator.RECORD_TYPE_ID_TERMINATION,
                        new Set<String>{CaseDecorator.CASE_ORIGIN_GUEST_PORTAL, CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL},
                        true,
                        true, 
                        new List<String>{
                            CaseDecorator.FIRST_NAME_FIELD,
                            CaseDecorator.LAST_NAME_FIELD,
                            CaseDecorator.TENANT_ADDRESS_STREET_FIELD,
                            CaseDecorator.TENANT_ADDRESS_CITY_FIELD,
                            CaseDecorator.TENANT_ADDRESS_POSTALCODE_FIELD
                        }
                    )
                );
                
                customerMatchConfigMap.put(CaseDecorator.RECORD_TYPE_ID_BREACH_ASB,
                    new CustomerMatchConfig(
                        CaseDecorator.RECORD_TYPE_ID_BREACH_ASB,
                        new Set<String>{CaseDecorator.CASE_ORIGIN_GUEST_PORTAL, CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL},
                        false,
                        false, 
                        new List<String>{
                            CaseDecorator.FIRST_NAME_FIELD,
                            CaseDecorator.LAST_NAME_FIELD,
                            CaseDecorator.ACCUSED_ADDRESS_STREET_FIELD,
                            CaseDecorator.ACCUSED_ADDRESS_CITY_FIELD,
                            CaseDecorator.ACCUSED_ADDRESS_POSTALCODE_FIELD
                        }
                    )
                );
                customerMatchConfigMap.put(CaseDecorator.RECORD_TYPE_ID_COMPLAINTS,
                    new CustomerMatchConfig(
                        CaseDecorator.RECORD_TYPE_ID_COMPLAINTS,
                        new Set<String>{CaseDecorator.CASE_ORIGIN_GUEST_PORTAL},
                        false,
                        true, 
                        new List<String>{
                            CaseDecorator.REPORTER_LAST_NAME_FIELD,
                            CaseDecorator.REPORTER_FIRST_NAME_FIELD,
                            CaseDecorator.REPORTER_ADDRESS_STREET_FIELD,
                            CaseDecorator.REPORTER_ADDRESS_CITY_FIELD,
                            CaseDecorator.REPORTER_ADDRESS_POSTALCODE_FIELD
                        }
                    )
                );
            }
            return customerMatchConfigMap;
        }
        set;
    }
    
     public void beforeInsert(List<Case> newList){
        this.newCaseList = newList;
        if (!this.accountListByCaseId.isEmpty()) {
            processCaseMatches();
        }
    }
    
    private void processCaseMatches() {
        Map<String, AccountAndTenancyAddressMatchService.AccountAndAddressMatchingResponse> responseByCaseIdxMap; 
        responseByCaseIdxMap = new AccountAndTenancyAddressMatchService(this.accountListByCaseId).findMatch();
        Map<String, Case> casesForDupeCheck = new Map<String, Case>();
        for (String caseIndex : this.accountListByCaseId.keySet()) {
            CustomerMatchConfig config = this.caseConfigMap.get(caseIndex);
            AccountAndTenancyAddressMatchService.AccountAndAddressMatchingResponse reponse = responseByCaseIdxMap.get(caseIndex);
            if (config.dupeCheckRequired) {
                Case caseForDupeCheck = this.createDupeCheckCase(reponse);
                if (caseForDupeCheck != null) {
                    casesForDupeCheck.put(caseIndex, caseForDupeCheck);
                }
            } else {
                this.tryApplyMatch(Integer.valueOf(caseIndex), reponse);
            }
        }
        
        if (!casesForDupeCheck.isEmpty()) {
            checkAndApplyMatches(responseByCaseIdxMap, casesForDupeCheck);
        }        
    }
    
    private Case createDupeCheckCase(
        AccountAndTenancyAddressMatchService.AccountAndAddressMatchingResponse matchResp
    ) {
        if (matchResp?.tenancy?.Id != null && matchResp?.tenancy?.TenancyEndDate__c == null) {
            return new Case(
                Tenancy__c = matchResp.tenancy.Id,
                RecordTypeId = CaseDecorator.RECORD_TYPE_ID_TERMINATION,
                CaseType__c = CaseDecorator.TYPE_TERMINATION
            );
        }
        return null;
    }
    
    private void checkAndApplyMatches(
        Map<String, AccountAndTenancyAddressMatchService.AccountAndAddressMatchingResponse> responseMap,
        Map<String, Case> dupeCheckCases
    ) {
        Map<Id, List<Case>> duplicateCaseMapByTenancyIdx = new CaseDuplicateCheckerService().getDuplicate(dupeCheckCases.values());
        for (String caseIndex : dupeCheckCases.keySet()) {
            AccountAndTenancyAddressMatchService.AccountAndAddressMatchingResponse matchResp = responseMap.get(caseIndex);
            String tenancyId = matchResp?.tenancy?.Id;
            if (String.isNotBlank(tenancyId) && 
                    (( duplicateCaseMapByTenancyIdx.size() == 1 && 
                      duplicateCaseMapByTenancyIdx.containsKey(null) && 
                      duplicateCaseMapByTenancyIdx.get(null).isEmpty()) ||
                    ( duplicateCaseMapByTenancyIdx.size() > 1 && 
                      !duplicateCaseMapByTenancyIdx.containsKey(tenancyId)
                    )
                    )) {
                this.applyMatchToCase(Integer.valueOf(caseIndex), matchResp);
            } 
        }
    }

    private void tryApplyMatch(
        Integer caseIndex,
        AccountAndTenancyAddressMatchService.AccountAndAddressMatchingResponse matchResp
    ) {
        if (matchResp?.tenancy != null) {
            this.applyMatchToCase(caseIndex, matchResp);
        }
    }
    
    private void applyMatchToCase(
        Integer caseIndex,
        AccountAndTenancyAddressMatchService.AccountAndAddressMatchingResponse matchResp
    ) {
        Case caseRecord = this.newCaseList[caseIndex];
        caseRecord.Tenancy__c = matchResp.tenancy.Id;
        caseRecord.MatchedContact__c = matchResp.contactId;
        if(caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_COMPLAINTS){
            caseRecord.Reporter__c = matchResp.contactId;
        }
       	if (caseRecord.RecordTypeId != CaseDecorator.RECORD_TYPE_ID_BREACH_ASB
                || (caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_BREACH_ASB 
                    && caseRecord.Origin == CaseDecorator.CASE_ORIGIN_GUEST_PORTAL)) {
            caseRecord.AccountId = matchResp.accountId;
            caseRecord.ContactId = matchResp.contactId;
            
        }
        if(caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_TERMINATION 
                && caseRecord.Origin == CaseDecorator.CASE_ORIGIN_GUEST_PORTAL){
            TenancyService.TenancyEndDateCalculationInterface instance = new TenancyService().getInstance(matchResp.tenancy);
            if(instance == null){        
                caseRecord.Tenancy__c = null;
                caseRecord.MatchedContact__c = null;
                caseRecord.AccountId = null;
                caseRecord.ContactId = null;
            }
        }
    }
    
    Map<String, List<Account>> accountListByCaseId {
        get {
            if (this.accountListByCaseId == null) {
                this.accountListByCaseId = new Map<String, List<Account>>();
                this.caseConfigMap = new Map<String, CustomerMatchConfig>();
                buildAccountListForEligibleCases();
            }
            return this.accountListByCaseId;
        }
        set;
    }
    
    private void buildAccountListForEligibleCases() {
        Integer index = 0;
        
        for (Case caseRecord : this.newCaseList) {
            CustomerMatchConfig config = customerMatchConfigMap.get(caseRecord.RecordTypeId);
            if (config != null && this.isCaseMatchConfigCriteria(caseRecord, config)) {
                List<Account> accounts = buildAccountsFromCase(caseRecord, config);
                
                if (!accounts.isEmpty()) {
                    this.accountListByCaseId.put(String.valueOf(index), accounts);
                    this.caseConfigMap.put(String.valueOf(index), config);
                }
            }
            index++;
        }
    }
    
    private Boolean isCaseMatchConfigCriteria(Case caseRecord, CustomerMatchConfig config) {
        Boolean isEligible = false;
        if (config.caseOrigin.contains(caseRecord.Origin)) {
            isEligible = config.requireAllGivenFields 
                        ? this.areAllGivenFieldsPopulated(caseRecord, config.requiredFields)
                        : this.isAnyGivenFieldsPopulated(caseRecord, config.requiredFields);
        }
        return isEligible;
    }
    
    private Boolean areAllGivenFieldsPopulated(Case caseRecord, List<String> requiredFields) {
        Boolean areAllPopulated = true;
        for (String fieldName : requiredFields) {
            if (String.isBlank((String)caseRecord.get(fieldName))) {
                areAllPopulated = false;
                break;
            }
        }
        return areAllPopulated;
    }
    
    private Boolean isAnyGivenFieldsPopulated(Case caseRecord, List<String> requiredFields) {
        Boolean isAnyPopulated = false;
        for (String fieldName : requiredFields) {
            if (!String.isBlank((String)caseRecord.get(fieldName))) {
                isAnyPopulated = true;
                break;
            }
        }
        return isAnyPopulated;
    }
    
    private List<Account> buildAccountsFromCase(Case caseRecord, CustomerMatchConfig config) {
        List<Account> accounts = new List<Account>();
        if (shouldIncludePrimaryTenant(caseRecord, config)) {
            accounts.add(createPersonAccount(caseRecord, config));
        }
        if (shouldIncludeJointTenant(caseRecord, config)) {
            accounts.add(createJointTenantAccount(caseRecord, config));
        }
        return accounts;
    }
    
    private Boolean shouldIncludePrimaryTenant(Case caseRecord, CustomerMatchConfig config) {
        String firstNameField;
        String lastNameField; 
        if(config.recordTypeId == CaseDecorator.RECORD_TYPE_ID_COMPLAINTS){
            firstNameField = CaseDecorator.REPORTER_FIRST_NAME_FIELD;
            lastNameField = CaseDecorator.REPORTER_LAST_NAME_FIELD;
        }else{
            firstNameField = CaseDecorator.FIRST_NAME_FIELD;
            lastNameField = CaseDecorator.LAST_NAME_FIELD;
        }
    
        Boolean includePrimaryTenant = !String.isBlank((String)caseRecord.get(firstNameField)) || 
                                        !String.isBlank((String)caseRecord.get(lastNameField));
        if (config.requireAllGivenFields) {
            includePrimaryTenant = !String.isBlank((String)caseRecord.get(firstNameField)) && 
                                    !String.isBlank((String)caseRecord.get(lastNameField));
        }
        return includePrimaryTenant;
    }
    
    private Boolean shouldIncludeJointTenant(Case caseRecord, CustomerMatchConfig config) {
       Boolean includeJointTenant = !String.isBlank(caseRecord.FirstNameofJointTenant__c) || 
                               !String.isBlank(caseRecord.LastNameOfJointTenant__c);
        if (config.requireAllGivenFields) {
            includeJointTenant = !String.isBlank(caseRecord.FirstNameofJointTenant__c) && 
                   !String.isBlank(caseRecord.LastNameOfJointTenant__c);
        }
        return includeJointTenant;
    }
    
    private Account createPersonAccount(Case caseRecord, CustomerMatchConfig config) {
        String fieldStreet = getAddressField(DuplicateCheckDecorator.SUFFIX_STREET,config);
        String fieldCity = getAddressField(DuplicateCheckDecorator.SUFFIX_CITY,config); 
        String fieldPostalcode = getAddressField(DuplicateCheckDecorator.SUFFIX_POSTALCODE,config);
        String valueStreet = (String.isNotBlank(fieldStreet) && caseRecord.get(fieldStreet) != null) ? String.valueOf(caseRecord.get(fieldStreet)) : null;
        String valueCity = (String.isNotBlank(fieldCity) && caseRecord.get(fieldCity) != null) ? String.valueOf(caseRecord.get(fieldCity)) : null; 
        String valuePostalcode = (String.isNotBlank(fieldPostalcode) && caseRecord.get(fieldPostalcode) != null) ? String.valueOf(caseRecord.get(fieldPostalcode)) : null;
        String firstNameField;
        String lastNameField;
        if(config.recordTypeId == CaseDecorator.RECORD_TYPE_ID_COMPLAINTS){
            firstNameField = CaseDecorator.REPORTER_FIRST_NAME_FIELD;
            lastNameField = CaseDecorator.REPORTER_LAST_NAME_FIELD;
        }else{
            firstNameField = CaseDecorator.FIRST_NAME_FIELD;
            lastNameField = CaseDecorator.LAST_NAME_FIELD;
        }
        String firstNameValue = (String.isNotBlank(firstNameField) && caseRecord.get(firstNameField) != null) ? String.valueOf(caseRecord.get(firstNameField)) : null;
        String lastNameValue = (String.isNotBlank(lastNameField) && caseRecord.get(lastNameField) != null) ? String.valueOf(caseRecord.get(lastNameField)) : null;
        return new AccountService().buildPersonAccount(
            firstNameValue,
            lastNameValue,
            valueStreet,
            valueCity,
            valuePostalcode
        );
    }
    
    private Account createJointTenantAccount(Case caseRecord, CustomerMatchConfig config) {
        String fieldStreet = getAddressField(DuplicateCheckDecorator.SUFFIX_STREET,config);
        String fieldCity = getAddressField(DuplicateCheckDecorator.SUFFIX_CITY,config); 
        String fieldPostalcode = getAddressField(DuplicateCheckDecorator.SUFFIX_POSTALCODE,config);
        String valueStreet = (String.isNotBlank(fieldStreet) && caseRecord.get(fieldStreet) != null) ? String.valueOf(caseRecord.get(fieldStreet)) : null;
        String valueCity = (String.isNotBlank(fieldCity) && caseRecord.get(fieldCity) != null) ? String.valueOf(caseRecord.get(fieldCity)) : null; 
        String valuePostalcode = (String.isNotBlank(fieldPostalcode) && caseRecord.get(fieldPostalcode) != null) ? String.valueOf(caseRecord.get(fieldPostalcode)) : null;
        return new AccountService().buildPersonAccount(
            caseRecord.FirstNameofJointTenant__c,
            caseRecord.LastNameOfJointTenant__c,
            valueStreet,
            valueCity,
            valuePostalcode
        );
    }

    private String getAddressField(String addressFieldSuffix, CustomerMatchConfig config) {
        String addressField;
        for (String field : config.requiredFields) {
            if (field.endsWithIgnoreCase(addressFieldSuffix)) {
                addressField = field;
            }
        }
        return addressField;
    }
}