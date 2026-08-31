public with sharing class RentStatementController {

    private static String getRentFrequencyLabel(String chargeFrequency) {
        if (TenancyDecorator.WEEKLY_CHARGE_FREQUENCIES.contains(chargeFrequency)) {
            return Label.CP_RentFrequencyWeekly;
        }
        if (TenancyDecorator.MONTHLY_CHARGE_FREQUENCIES.contains(chargeFrequency)) {
            return Label.CP_RentFrequencyMonthly;
        }
        if (TenancyDecorator.QUARTERLY_CHARGE_FREQUENCIES.contains(chargeFrequency)) {
            return Label.CP_RentFrequencyQuarterly;
        }
        return Label.CP_RentFrequencyDefault;
    }

    private static String getRentPeriodLabel(String chargeFrequency) {
        if (TenancyDecorator.WEEKLY_CHARGE_FREQUENCIES.contains(chargeFrequency)) {
            return Label.CP_RentPeriodWeekly;
        }
        if (TenancyDecorator.MONTHLY_CHARGE_FREQUENCIES.contains(chargeFrequency)) {
            return Label.CP_RentPeriodMonthly;
        }
        if (TenancyDecorator.QUARTERLY_CHARGE_FREQUENCIES.contains(chargeFrequency)) {
            return Label.CP_RentPeriodQuarterly;
        }
        return chargeFrequency;
    }

    @AuraEnabled(cacheable=true)
    public static List<TenancyWrapper> getTenancies() {
        List<TenancyWrapper> tenancyList = new List<TenancyWrapper>();
        User currentUser =  [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        List<Member__c> memberList = new MemberService().getActiveMembersByContactId(currentUser.ContactId);
        for(Member__c mem : memberList) {
                TenancyWrapper tenancy = new TenancyWrapper(mem);
                tenancyList.add(tenancy);
        }
        populateRentDetails(tenancyList);
        return tenancyList;
    }

    private static void populateRentDetails(List<TenancyWrapper> tenancies) {
        Set<Id> tenancyIds = new Set<Id>();
        for (TenancyWrapper t : tenancies) {
            if (t.tenancyId != null) {
                tenancyIds.add(t.tenancyId);
            }
        }
        if (!tenancyIds.isEmpty()) {
            Map<Id, YH_Tenancy__c> tenancyById = new TenancyService().getTenanciesWithRentDetails(tenancyIds);
            for (TenancyWrapper t : tenancies) {
                YH_Tenancy__c ten = tenancyById.get(t.tenancyId);
                if (ten != null) {
                    t.chargeFrequency = ten.YH_ChargeFrequency__c;
                    t.weeklyRent = ten.Property__r.CurrentGrossRent__c;
                    t.rentFrequencyLabel = getRentFrequencyLabel(ten.YH_ChargeFrequency__c);
                    t.rentPeriodLabel = getRentPeriodLabel(ten.YH_ChargeFrequency__c);
                }
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<AccountWrapper> getAccountsByTenancyNumber(String tenancyNumber, String orchardChequeDigit){
        List<AccountWrapper> accountList = new List<AccountWrapper>();
        try{
            isValidTenancy(tenancyNumber);
            ExternalService.ExtSvcGetAccountsBasedOnTenancyNumberV1 service = new ExternalService.ExtSvcGetAccountsBasedOnTenancyNumberV1();
            ExternalService.ExtSvcGetAccountsBasedOnTenancyNumberV1.getTenancyAccountList_Request request = new ExternalService.ExtSvcGetAccountsBasedOnTenancyNumberV1.getTenancyAccountList_Request();
            request.tenancyNumber = Integer.valueOf(tenancyNumber);
            ExternalService.ExtSvcGetAccountsBasedOnTenancyNumberV1.GetTenancyAccountList_Response res = service.GetTenancyAccountList(request);
            if(res != null && res.responseCode == HTTPRequestResponseDecorator.SUCCESS_CODE &&  res.Code200 != null){
                for(ExternalService.ExtSvcGetAccountsBasedOnTenancyNumberV1_VT_getTenancyAccountsListResponse response : res.Code200){
                    accountList.add(new AccountWrapper(
                                            String.valueOf(response.subAccountNumber),
                                            response.accountDescription,
                                            response?.occupancyCommenced,
                                            response?.occupancyTerminated,
                                            response.accountBalance,
                                            orchardChequeDigit,
                                            tenancyNumber
                    ));
                }
            }
            else {
                throw new AuraHandledException('Oops! Something didn\'t load quite right. Please try again later.');
            }
        }
        catch (Exception ex) {
            AuraHandledException userException = new AuraHandledException('Oops! Something didn\'t load quite right. Please try again later.');
            userException.setMessage('Oops! Something didn\'t load quite right. Please try again later.');
            throw userException;
        }
        return accountList;
    }
    
    @AuraEnabled(cacheable=true)
    public static StatementsWrapper getStatements(String accountId, String tenancy, String filter) {
        System.debug('filter:'+filter);
        StatementsWrapper statementWrap = new StatementsWrapper();
        try {
                Map<String, Object> filterMap = new Map<String, Object>();
                    if (String.isNotBlank(filter)) {
                        filterMap = (Map<String, Object>)JSON.deserializeUntyped(filter);
                    }
                

                Map<String, Object> tenancyMap = new Map<String, Object>();
                if (String.isNotBlank(tenancy)) {
                        tenancyMap = (Map<String, Object>) JSON.deserializeUntyped(tenancy);
                }
                String tenancyNumber = (String) tenancyMap.get('tenancyNumber');
                String chargeFrequency = (String) tenancyMap.get('chargeFrequency');
                String rentType = (String) tenancyMap.get('rentType');
                isValidTenancy(tenancyNumber);
                List<Date> dateList = applyPeriodFilter(tenancyNumber, filterMap);
                if(!dateList.isEmpty()){
                    ExternalService.ExtSvcGetTenancyAccountDetailsV5 service  = new ExternalService.ExtSvcGetTenancyAccountDetailsV5(); 
                    ExternalService.ExtSvcGetTenancyAccountDetailsV5.getTenancyAccountDetails_Request   request = new ExternalService.ExtSvcGetTenancyAccountDetailsV5.getTenancyAccountDetails_Request (); 
                    request.tenancyNumber = Integer.valueOf(tenancyNumber); 
                    request.subAccountNumber  = Integer.valueOf(accountId); 
                    request.dateFrom  = dateList[0];
                    request.dateTo = dateList[1];
                    request.rentType = rentType;
                    request.chargeFrequency = chargeFrequency;
                    ExternalService.ExtSvcGetTenancyAccountDetailsV5.getTenancyAccountDetails_Response res = service.getTenancyAccountDetails(request); 
                    if(res != null && res.responseCode == HTTPRequestResponseDecorator.SUCCESS_CODE &&  res.Code200 != null){
                        ExternalService.ExtSvcGetTenancyAccountDetailsV5_getTenancyAccountDetailsResponse response = res.Code200;
                        for(ExternalService.ExtSvcGetTenancyAccountDetailsV5_z0transaction transactionRec : response.transactions ){
                            TransactionWrapper rent;
                            if(transactionRec.rent != null){
                                rent = new TransactionWrapper(transactionRec?.rent?.amount,transactionRec?.rent?.transactionDate);
                            } 
                            List<TransactionWrapper> adjustments = new List<TransactionWrapper>();
                            if(transactionRec.adjustments != null){ 
                               for(ExternalService.ExtSvcGetTenancyAccountDetailsV5_transactionDetails adjustment: transactionRec.adjustments){
                                	adjustments.add(new TransactionWrapper(adjustment?.amount, adjustment?.transactionDate, adjustment?.description));
                            	}
                            }
                            List<TransactionWrapper> benefits = new List<TransactionWrapper>();
                            if(transactionRec.benefits != null){ 
                               for(ExternalService.ExtSvcGetTenancyAccountDetailsV5_transactionDetails benefit: transactionRec.benefits){
                                	benefits.add(new TransactionWrapper(benefit?.amount, benefit?.transactionDate, benefit?.description));
                            	}
                            }
                            List<TransactionWrapper> payments = new List<TransactionWrapper>();
                            if(transactionRec.payments != null){
                               for(ExternalService.ExtSvcGetTenancyAccountDetailsV5_transactionDetails payment: transactionRec.payments){
                                	payments.add(new TransactionWrapper(payment?.amount ,payment?.transactionDate, payment?.description));
                            	} 
                            }
							List<TransactionWrapper> charges = new List<TransactionWrapper>(); 
                            ChargesWrapper chargesWrap;
                            if(transactionRec.charges != null){
                                for(ExternalService.ExtSvcGetTenancyAccountDetailsV5_transactionDetails charge: transactionRec.charges.chargesBreakdown ){
                                	charges.add(new TransactionWrapper(charge.amount, charge.transactionDate, charge.description));
                            	}
                                chargesWrap = new ChargesWrapper(transactionRec.charges.totalAmount, charges);
                            }
                            statementWrap.statements.add(new StatementWrapper(transactionRec.balanceDate, 
                                        transactionRec.balance, 
                                        rent,                                              		
										chargesWrap,
                                        benefits, 
                                        payments,
                                        adjustments
                                    ));   
                        }   
                        statementWrap.totalCount = statementWrap.statements.size();
                    }
                    else{
                        throw new AuraHandledException('Oops! Something didn\'t load quite right. Please try again later.');
                    } 
                }
                else{
                        throw new AuraHandledException('Oops! Something didn\'t load quite right. Please try again later.');
                } 
        } 
        catch (Exception e) {
            AuraHandledException userException = new AuraHandledException('Oops! Something didn\'t load quite right. Please try again later.');
            userException.setMessage('Oops! Something didn\'t load quite right. Please try again later.');
            throw userException;
        }
        return statementWrap;
    }

    private static List<Date> applyPeriodFilter(String tenancyNumber, Map<String, Object> filterMap) {
        String period = String.valueOf(filterMap.get('period')).toLowerCase();
        Date startDate;
        Date endDate = Date.today(); 
        Date occupancyStartDate = getOccupancyStartDate(tenancyNumber);
        try {
            switch on period {
                when '7days' {
                    startDate = endDate.addDays(-7);
                }
                when '30days' {
                    startDate = endDate.addDays(-30);
                }
                when 'quarter' {
                    startDate = endDate.addMonths(-3);
                }
                when '6months' {
                    startDate = endDate.addMonths(-6);
                }
                when 'custom' {
                    startDate = Date.valueOf(String.valueOf(filterMap.get('startDate')));
                    endDate   = Date.valueOf(String.valueOf(filterMap.get('endDate')));
                    
                }
                when else {
                    startDate = endDate.addMonths(-24); 
                }
            }
            if (startDate < occupancyStartDate) {
                startDate = occupancyStartDate;
            }
            return new List<Date>{ startDate, endDate };
        } 
        catch (Exception ex) {
            throw new AuraHandledException('Invalid date filter input.');
        }
    }

    private static void isValidTenancy(String tenancyNumber) {
        Boolean isFound = false;
        for (TenancyWrapper tenancy : getTenancies()) {
            if (tenancy.tenancyNumber == tenancyNumber) {
                isFound = true;
                break;
            }
        }
        if (!isFound) {
            throw new AuraHandledException('Invalid tenancy number.');
        }
    }

    private static Date getOccupancyStartDate(String tenancyNumber) {
        Date occupancyStartDate;
        List<TenancyWrapper> tenancies = getTenancies();
        for (TenancyWrapper tenancy : tenancies) {
            if (tenancy.tenancyNumber == tenancyNumber) {
                occupancyStartDate = tenancy.occupancyStartDate;
                break;
            }
        }
        return occupancyStartDate;
    }
    
    /*@AuraEnabled(cacheable=true)
    public static List<TenancyGroupWrapper> getRentStatements() {
        List<TenancyGroupWrapper> tenancyGroups = new List<TenancyGroupWrapper>();
        try {
            tenancyGroups = getMockRentAccounts();
            // if (tenancyGroups.size() > 0) {
            //     throw new AuraHandledException('Error retrieving rent statements');
            // }
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving rent statements: ' + e.getMessage());
        }
        
        return tenancyGroups;
    }*/

    @AuraEnabled(cacheable=true)
    public static String getAllPayPaymentURL() {
            return OrgSetting__c.getOrgDefaults().AllPayPaymentURL__c;
    }
    
   // @AuraEnabled(cacheable=true)
    /*public static StatementsWrapper getStatements(String accountId, String filterJson) {
        try {
            Map<String, Object> filterMap = new Map<String, Object>();
            if (String.isNotBlank(filterJson)) {
                filterMap = (Map<String, Object>)JSON.deserializeUntyped(filterJson);
            }            
            
            Integer pageSize = (Integer)filterMap.get('pageSize');
            Integer pageNumber = (Integer)filterMap.get('pageNumber');

            return getMockStatements(accountId, filterMap, pageSize, pageNumber);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving statements: ' + e.getMessage());
        }
    }*/
    
    /*private static List<TenancyGroupWrapper> getMockRentAccounts() {
        List<TenancyGroupWrapper> mockGroups = new List<TenancyGroupWrapper>();
        
        List<AccountWrapper> accounts1 = new List<AccountWrapper>();
        accounts1.add(new AccountWrapper(
            'ACC-001',
            'Mohammad Ramees',
            'Main Rent Account',
            '01 January 2023',
            'Current',
             1250.00
        ));
        accounts1.add(new AccountWrapper(
            'ACC-002', 
            'Mohammad Ramees',
            'Chargeable Repairs',
            '01 January 2023',
            'Current',
             150.00
        ));
        accounts1.add(new AccountWrapper(
            'ACC-003',
            'Mohammad Ramees',
            'Legal Costs',
            '01 January 2023',
            '15 March 2024',
             75.00
        ));
        accounts1.add(new AccountWrapper(
            'ACC-004',
            'Mohammad Ramees',
            'Admin Costs',
            '01 January 2023',
            'Current',
             45.00
        ));

        
        mockGroups.add(new TenancyGroupWrapper(
            'TEN-001',
            '123 Main Street, London, W1 1AB',
            'House',
            true,
            true,
            accounts1
        ));
        
        List<AccountWrapper> accounts2 = new List<AccountWrapper>();
        accounts2.add(new AccountWrapper(
            'ACC-005',
            'Mohammad Ramees',
            'Main Rent Account',
            '15 March 2023',
            'Current',
             950.00
        ));
        accounts2.add(new AccountWrapper(
            'ACC-006',
            'Mohammad Ramees',
            'Service Charges',
            '15 March 2023',
            'Current',
             120.00
        ));
        accounts2.add(new AccountWrapper(
            'ACC-007',
            'Mohammad Ramees',
            'Ground Rent',
            '15 March 2023',
            'Current',
             60.00
        ));
        
        mockGroups.add(new TenancyGroupWrapper(
            'TEN-002',
            '456 Oak Avenue, Manchester, M1 2BC',
            'House',
            true,
            false,
            accounts2
        ));
        
        List<AccountWrapper> accounts3 = new List<AccountWrapper>();
        accounts3.add(new AccountWrapper(
            'ACC-008',
            'Mohammad Ramees',
            'Main Rent Account',
            '01 June 2022',
            '31 December 2023',
             0.00
        ));
        accounts3.add(new AccountWrapper(
            'ACC-009',
            'Mohammad Ramees',
            'Cleaning Fees',
            '01 June 2022',
            '31 December 2023',
             25.00
        ));
        
        mockGroups.add(new TenancyGroupWrapper(
            'TEN-003',
            '789 Pine Road, Birmingham, B1 3CD',
            'Garage',
            false,
            false,
            accounts3
        ));
        
        return mockGroups;
    }
    
    
    private static StatementsWrapper getMockStatements(String accountId, Map<String, Object> filter, Integer pageSize, Integer pageNumber) {
        StatementsWrapper wrapper = new StatementsWrapper();
        List<StatementWrapper> allStatements = new List<StatementWrapper>();
        
        // Generate transaction data based on account type
        if (accountId == 'ACC-001') {
            // Main Rent Account transactions - 15 records
            allStatements.add(new StatementWrapper('TXN-001', Date.newInstance(2024, 1, 1), 1250.00, 1250.00, 450.00, 800.00, Date.newInstance(2024, 1, 2), 0.00));
            allStatements.add(new StatementWrapper('TXN-002', Date.newInstance(2024, 1, 1), 1250.00, 1250.00, 450.00, 0.00, null, -800.00));
            allStatements.add(new StatementWrapper('TXN-003', Date.newInstance(2024, 1, 8), 0.00, 0.00, 0.00, 800.00, Date.newInstance(2024, 1, 8), 0.00));
            allStatements.add(new StatementWrapper('TXN-004', Date.newInstance(2024, 2, 1), 1250.00, 1250.00, 450.00, 800.00, Date.newInstance(2024, 2, 3), 0.00));
            allStatements.add(new StatementWrapper('TXN-005', Date.newInstance(2024, 2, 1), 1250.00, 1250.00, 450.00, 0.00, null, -1250.00));
            allStatements.add(new StatementWrapper('TXN-006', Date.newInstance(2024, 2, 5), 0.00, 0.00, 0.00, 600.00, Date.newInstance(2024, 2, 5), -650.00));
            allStatements.add(new StatementWrapper('TXN-007', Date.newInstance(2024, 2, 10), 0.00, 0.00, 0.00, 650.00, Date.newInstance(2024, 2, 10), 0.00));
            allStatements.add(new StatementWrapper('TXN-008', Date.newInstance(2024, 3, 1), 1250.00, 1250.00, 450.00, 800.00, Date.newInstance(2024, 3, 2), 0.00));
            allStatements.add(new StatementWrapper('TXN-009', Date.newInstance(2024, 3, 1), 1250.00, 1250.00, 450.00, 0.00, null, -1250.00));
            allStatements.add(new StatementWrapper('TXN-010', Date.newInstance(2024, 3, 7), 0.00, 0.00, 0.00, 1250.00, Date.newInstance(2024, 3, 7), 0.00));
            allStatements.add(new StatementWrapper('TXN-011', Date.newInstance(2024, 4, 1), 1250.00, 1250.00, 450.00, 800.00, Date.newInstance(2024, 4, 3), 0.00));
            allStatements.add(new StatementWrapper('TXN-012', Date.newInstance(2024, 4, 1), 1250.00, 1250.00, 450.00, 0.00, null, -1250.00));
            allStatements.add(new StatementWrapper('TXN-013', Date.newInstance(2024, 4, 10), 0.00, 0.00, 0.00, 800.00, Date.newInstance(2024, 4, 10), -450.00));
            allStatements.add(new StatementWrapper('TXN-014', Date.newInstance(2024, 4, 15), 0.00, 0.00, 0.00, 450.00, Date.newInstance(2024, 4, 15), 0.00));
            allStatements.add(new StatementWrapper('TXN-015', Date.newInstance(2024, 5, 1), 1250.00, 1250.00, 450.00, 800.00, Date.newInstance(2024, 5, 2), 0.00));
            allStatements.add(new StatementWrapper('TXN-016', Date.newInstance(2024, 5, 15), 800.00, 800.00, 0.00, 800.00, Date.newInstance(2024, 5, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-017', Date.newInstance(2024, 6, 1), 0.00, 0.00, 800.00, 1200.00, Date.newInstance(2024, 6, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-018', Date.newInstance(2024, 6, 15), 1200.00, 1200.00, 0.00, 1200.00, Date.newInstance(2024, 6, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-019', Date.newInstance(2024, 7, 1), 0.00, 0.00, 1200.00, 950.00, Date.newInstance(2024, 7, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-020', Date.newInstance(2024, 7, 15), 950.00, 950.00, 0.00, 950.00, Date.newInstance(2024, 7, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-021', Date.newInstance(2024, 8, 1), 0.00, 0.00, 950.00, 1800.00, Date.newInstance(2024, 8, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-022', Date.newInstance(2024, 8, 15), 1800.00, 1800.00, 0.00, 1800.00, Date.newInstance(2024, 8, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-023', Date.newInstance(2024, 9, 1), 0.00, 0.00, 1800.00, 650.00, Date.newInstance(2024, 9, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-024', Date.newInstance(2024, 9, 15), 650.00, 650.00, 0.00, 650.00, Date.newInstance(2024, 9, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-025', Date.newInstance(2024, 10, 1), 0.00, 0.00, 650.00, 1100.00, Date.newInstance(2024, 10, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-026', Date.newInstance(2024, 10, 15), 1100.00, 1100.00, 0.00, 1100.00, Date.newInstance(2024, 10, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-027', Date.newInstance(2024, 11, 1), 0.00, 0.00, 1100.00, 750.00, Date.newInstance(2024, 11, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-028', Date.newInstance(2024, 11, 15), 750.00, 750.00, 0.00, 750.00, Date.newInstance(2024, 11, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-029', Date.newInstance(2024, 12, 1), 0.00, 0.00, 750.00, 2000.00, Date.newInstance(2024, 12, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-030', Date.newInstance(2024, 12, 15), 2000.00, 2000.00, 0.00, 2000.00, Date.newInstance(2024, 12, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-031', Date.newInstance(2025, 1, 1), 0.00, 0.00, 2000.00, 850.00, Date.newInstance(2025, 1, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-032', Date.newInstance(2025, 1, 15), 850.00, 850.00, 0.00, 850.00, Date.newInstance(2025, 1, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-033', Date.newInstance(2025, 2, 1), 0.00, 0.00, 850.00, 1300.00, Date.newInstance(2025, 2, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-034', Date.newInstance(2025, 2, 15), 1300.00, 1300.00, 0.00, 1300.00, Date.newInstance(2025, 2, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-035', Date.newInstance(2025, 3, 1), 0.00, 0.00, 1300.00, 550.00, Date.newInstance(2025, 3, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-036', Date.newInstance(2025, 3, 15), 550.00, 550.00, 0.00, 550.00, Date.newInstance(2025, 3, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-037', Date.newInstance(2025, 4, 1), 0.00, 0.00, 550.00, 1600.00, Date.newInstance(2025, 4, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-038', Date.newInstance(2025, 4, 15), 1600.00, 1600.00, 0.00, 1600.00, Date.newInstance(2025, 4, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-039', Date.newInstance(2025, 5, 1), 0.00, 0.00, 1600.00, 900.00, Date.newInstance(2025, 5, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-040', Date.newInstance(2025, 5, 15), 900.00, 900.00, 0.00, 900.00, Date.newInstance(2025, 5, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-041', Date.newInstance(2025, 6, 1), 0.00, 0.00, 900.00, 1400.00, Date.newInstance(2025, 6, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-042', Date.newInstance(2025, 6, 15), 1400.00, 1400.00, 0.00, 1400.00, Date.newInstance(2025, 6, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-043', Date.newInstance(2025, 7, 1), 0.00, 0.00, 1400.00, 700.00, Date.newInstance(2025, 7, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-044', Date.newInstance(2025, 7, 15), 700.00, 700.00, 0.00, 700.00, Date.newInstance(2025, 7, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-045', Date.newInstance(2025, 8, 1), 0.00, 0.00, 700.00, 1900.00, Date.newInstance(2025, 8, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-046', Date.newInstance(2025, 8, 15), 1900.00, 1900.00, 0.00, 1900.00, Date.newInstance(2025, 8, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-047', Date.newInstance(2025, 9, 1), 0.00, 0.00, 1900.00, 600.00, Date.newInstance(2025, 9, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-048', Date.newInstance(2025, 9, 15), 600.00, 600.00, 0.00, 600.00, Date.newInstance(2025, 9, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-049', Date.newInstance(2025, 10, 1), 0.00, 0.00, 600.00, 1250.00, Date.newInstance(2025, 10, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-050', Date.newInstance(2025, 10, 15), 1250.00, 1250.00, 0.00, 1250.00, Date.newInstance(2025, 10, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-051', Date.newInstance(2025, 11, 1), 0.00, 0.00, 1250.00, 800.00, Date.newInstance(2025, 11, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-052', Date.newInstance(2025, 11, 15), 800.00, 800.00, 0.00, 800.00, Date.newInstance(2025, 11, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-053', Date.newInstance(2025, 12, 1), 0.00, 0.00, 800.00, 2200.00, Date.newInstance(2025, 12, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-054', Date.newInstance(2025, 12, 15), 2200.00, 2200.00, 0.00, 2200.00, Date.newInstance(2025, 12, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-055', Date.newInstance(2026, 1, 1), 0.00, 0.00, 2200.00, 950.00, Date.newInstance(2026, 1, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-056', Date.newInstance(2026, 1, 15), 950.00, 950.00, 0.00, 950.00, Date.newInstance(2026, 1, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-057', Date.newInstance(2026, 2, 1), 0.00, 0.00, 950.00, 1350.00, Date.newInstance(2026, 2, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-058', Date.newInstance(2026, 2, 15), 1350.00, 1350.00, 0.00, 1350.00, Date.newInstance(2026, 2, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-059', Date.newInstance(2026, 3, 1), 0.00, 0.00, 1350.00, 580.00, Date.newInstance(2026, 3, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-060', Date.newInstance(2026, 3, 15), 580.00, 580.00, 0.00, 580.00, Date.newInstance(2026, 3, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-061', Date.newInstance(2026, 4, 1), 0.00, 0.00, 580.00, 1700.00, Date.newInstance(2026, 4, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-062', Date.newInstance(2026, 4, 15), 1700.00, 1700.00, 0.00, 1700.00, Date.newInstance(2026, 4, 16), 0.00));
            allStatements.add(new StatementWrapper('TXN-063', Date.newInstance(2026, 5, 1), 0.00, 0.00, 1700.00, 850.00, Date.newInstance(2026, 5, 1), 0.00));
            allStatements.add(new StatementWrapper('TXN-064', Date.newInstance(2026, 5, 15), 850.00, 850.00, 0.00, 850.00, Date.newInstance(2026, 5, 16), 0.00));
            
        } else if (accountId == 'ACC-002') {
            // Chargeable Repairs transactions - 12 records
            allStatements.add(new StatementWrapper('TXN-101', Date.newInstance(2024, 1, 15), 0.00, 150.00, 0.00, 150.00, Date.newInstance(2024, 1, 20), 0.00));
            allStatements.add(new StatementWrapper('TXN-102', Date.newInstance(2024, 2, 15), 0.00, 75.00, 0.00, 0.00, null, -75.00));
            allStatements.add(new StatementWrapper('TXN-103', Date.newInstance(2024, 2, 20), 0.00, 0.00, 0.00, 75.00, Date.newInstance(2024, 2, 20), 0.00));
            allStatements.add(new StatementWrapper('TXN-104', Date.newInstance(2024, 3, 10), 0.00, 200.00, 0.00, 0.00, null, -200.00));
            allStatements.add(new StatementWrapper('TXN-105', Date.newInstance(2024, 3, 15), 0.00, 0.00, 0.00, 100.00, Date.newInstance(2024, 3, 15), -100.00));
            allStatements.add(new StatementWrapper('TXN-106', Date.newInstance(2024, 3, 20), 0.00, 0.00, 0.00, 100.00, Date.newInstance(2024, 3, 20), 0.00));
            allStatements.add(new StatementWrapper('TXN-107', Date.newInstance(2024, 4, 5), 0.00, 120.00, 0.00, 0.00, null, -120.00));
            allStatements.add(new StatementWrapper('TXN-108', Date.newInstance(2024, 4, 10), 0.00, 0.00, 0.00, 120.00, Date.newInstance(2024, 4, 10), 0.00));
            allStatements.add(new StatementWrapper('TXN-109', Date.newInstance(2024, 5, 8), 0.00, 90.00, 0.00, 0.00, null, -90.00));
            allStatements.add(new StatementWrapper('TXN-110', Date.newInstance(2024, 5, 12), 0.00, 0.00, 0.00, 90.00, Date.newInstance(2024, 5, 12), 0.00));
            allStatements.add(new StatementWrapper('TXN-111', Date.newInstance(2024, 6, 5), 0.00, 180.00, 0.00, 0.00, null, -180.00));
            allStatements.add(new StatementWrapper('TXN-112', Date.newInstance(2024, 6, 10), 0.00, 0.00, 0.00, 180.00, Date.newInstance(2024, 6, 10), 0.00));
            
        } else if (accountId.startsWith('GAR')) {
            // Garage Tenancy transactions - 12 records
            allStatements.add(new StatementWrapper('TXN-201', Date.newInstance(2024, 1, 1), 60.00, 0.00, 0.00, 60.00, Date.newInstance(2024, 1, 2), 0.00));
            allStatements.add(new StatementWrapper('TXN-202', Date.newInstance(2024, 2, 1), 60.00, 0.00, 0.00, 60.00, Date.newInstance(2024, 2, 3), 0.00));
            allStatements.add(new StatementWrapper('TXN-203', Date.newInstance(2024, 3, 1), 60.00, 0.00, 0.00, 60.00, Date.newInstance(2024, 3, 2), 0.00));
            allStatements.add(new StatementWrapper('TXN-204', Date.newInstance(2024, 4, 1), 60.00, 0.00, 0.00, 60.00, Date.newInstance(2024, 4, 3), 0.00));
            allStatements.add(new StatementWrapper('TXN-205', Date.newInstance(2024, 5, 1), 60.00, 0.00, 0.00, 60.00, Date.newInstance(2024, 5, 2), 0.00));
            allStatements.add(new StatementWrapper('TXN-206', Date.newInstance(2024, 6, 1), 60.00, 0.00, 0.00, 60.00, Date.newInstance(2024, 6, 3), 0.00));
            allStatements.add(new StatementWrapper('TXN-207', Date.newInstance(2024, 7, 1), 60.00, 0.00, 0.00, 60.00, Date.newInstance(2024, 7, 2), 0.00));
            allStatements.add(new StatementWrapper('TXN-208', Date.newInstance(2024, 8, 1), 60.00, 0.00, 0.00, 60.00, Date.newInstance(2024, 8, 3), 0.00));
            allStatements.add(new StatementWrapper('TXN-209', Date.newInstance(2024, 9, 1), 60.00, 0.00, 0.00, 60.00, Date.newInstance(2024, 9, 2), 0.00));
            allStatements.add(new StatementWrapper('TXN-210', Date.newInstance(2024, 10, 1), 60.00, 0.00, 0.00, 60.00, Date.newInstance(2024, 10, 3), 0.00));
            allStatements.add(new StatementWrapper('TXN-211', Date.newInstance(2024, 11, 1), 60.00, 0.00, 0.00, 60.00, Date.newInstance(2024, 11, 2), 0.00));
            allStatements.add(new StatementWrapper('TXN-212', Date.newInstance(2024, 12, 1), 60.00, 0.00, 0.00, 60.00, Date.newInstance(2024, 12, 3), 0.00));
            
        } else if (accountId == 'ACC-003') {
            // Legal Costs transactions - 10 records
            allStatements.add(new StatementWrapper('TXN-301', Date.newInstance(2024, 1, 1), 0.00, 75.00, 0.00, 75.00, Date.newInstance(2024, 1, 5), 0.00));
            allStatements.add(new StatementWrapper('TXN-302', Date.newInstance(2024, 2, 10), 0.00, 150.00, 0.00, 0.00, null, -150.00));
            allStatements.add(new StatementWrapper('TXN-303', Date.newInstance(2024, 2, 15), 0.00, 0.00, 0.00, 150.00, Date.newInstance(2024, 2, 15), 0.00));
            allStatements.add(new StatementWrapper('TXN-304', Date.newInstance(2024, 3, 5), 0.00, 200.00, 0.00, 0.00, null, -200.00));
            allStatements.add(new StatementWrapper('TXN-305', Date.newInstance(2024, 3, 20), 0.00, 0.00, 0.00, 200.00, Date.newInstance(2024, 3, 20), 0.00));
            allStatements.add(new StatementWrapper('TXN-306', Date.newInstance(2024, 4, 8), 0.00, 100.00, 0.00, 0.00, null, -100.00));
            allStatements.add(new StatementWrapper('TXN-307', Date.newInstance(2024, 4, 12), 0.00, 0.00, 0.00, 100.00, Date.newInstance(2024, 4, 12), 0.00));
            allStatements.add(new StatementWrapper('TXN-308', Date.newInstance(2024, 5, 3), 0.00, 125.00, 0.00, 0.00, null, -125.00));
            allStatements.add(new StatementWrapper('TXN-309', Date.newInstance(2024, 5, 10), 0.00, 0.00, 0.00, 125.00, Date.newInstance(2024, 5, 10), 0.00));
            allStatements.add(new StatementWrapper('TXN-310', Date.newInstance(2024, 6, 1), 0.00, 80.00, 0.00, 0.00, null, -80.00));
            
        } else if (accountId == 'ACC-004') {
            // Homeownership Admin Costs - 8 records
            allStatements.add(new StatementWrapper('TXN-401', Date.newInstance(2024, 1, 1), 0.00, 45.00, 0.00, 45.00, Date.newInstance(2024, 1, 5), 0.00));
            allStatements.add(new StatementWrapper('TXN-402', Date.newInstance(2024, 2, 1), 0.00, 45.00, 0.00, 45.00, Date.newInstance(2024, 2, 3), 0.00));
            allStatements.add(new StatementWrapper('TXN-403', Date.newInstance(2024, 3, 1), 0.00, 45.00, 0.00, 45.00, Date.newInstance(2024, 3, 2), 0.00));
            allStatements.add(new StatementWrapper('TXN-404', Date.newInstance(2024, 4, 1), 0.00, 45.00, 0.00, 45.00, Date.newInstance(2024, 4, 3), 0.00));
            allStatements.add(new StatementWrapper('TXN-405', Date.newInstance(2024, 5, 1), 0.00, 45.00, 0.00, 45.00, Date.newInstance(2024, 5, 2), 0.00));
            allStatements.add(new StatementWrapper('TXN-406', Date.newInstance(2024, 6, 1), 0.00, 45.00, 0.00, 45.00, Date.newInstance(2024, 6, 3), 0.00));
            allStatements.add(new StatementWrapper('TXN-407', Date.newInstance(2024, 7, 1), 0.00, 45.00, 0.00, 45.00, Date.newInstance(2024, 7, 2), 0.00));
            allStatements.add(new StatementWrapper('TXN-408', Date.newInstance(2024, 8, 1), 0.00, 45.00, 0.00, 45.00, Date.newInstance(2024, 8, 3), 0.00));
            
        } else {
            // Default transactions for other accounts - 6 records
            allStatements.add(new StatementWrapper('TXN-501', Date.newInstance(2024, 1, 1), 0.00, 25.00, 0.00, 25.00, Date.newInstance(2024, 1, 5), 0.00));
            allStatements.add(new StatementWrapper('TXN-502', Date.newInstance(2024, 2, 1), 0.00, 25.00, 0.00, 25.00, Date.newInstance(2024, 2, 3), 0.00));
            allStatements.add(new StatementWrapper('TXN-503', Date.newInstance(2024, 3, 1), 0.00, 25.00, 0.00, 25.00, Date.newInstance(2024, 3, 2), 0.00));
            allStatements.add(new StatementWrapper('TXN-504', Date.newInstance(2024, 4, 1), 0.00, 25.00, 0.00, 25.00, Date.newInstance(2024, 4, 3), 0.00));
            allStatements.add(new StatementWrapper('TXN-505', Date.newInstance(2024, 5, 1), 0.00, 25.00, 0.00, 25.00, Date.newInstance(2024, 5, 2), 0.00));
            allStatements.add(new StatementWrapper('TXN-506', Date.newInstance(2024, 6, 1), 0.00, 25.00, 0.00, 25.00, Date.newInstance(2024, 6, 3), 0.00));
        }
        
        // Apply filter if provided
        if (!filter.isEmpty()) {
            String period = (String)filter.get('period');
            allStatements = applyPeriodFilter(allStatements, period);
        }
        
        // Apply pagination
        if (pageSize != null && pageNumber != null) {
            Integer startIndex = (pageNumber - 1) * pageSize;
            Integer endIndex = Math.min(startIndex + pageSize, allStatements.size());
            
            if (startIndex < allStatements.size()) {
                wrapper.statements = new List<StatementWrapper>();
                for (Integer i = startIndex; i < endIndex; i++) {
                    wrapper.statements.add(allStatements[i]);
                }
            } else {
                wrapper.statements = new List<StatementWrapper>();
            }
        } else {
            wrapper.statements = allStatements;
        }
        
        wrapper.totalCount = allStatements.size();
        
        return wrapper;
    }*/

    /*private static List<StatementWrapper> applyPeriodFilter(List<StatementWrapper> statements, String period) {
        System.debug('>>> period: ' + period);
        if (period == null || period == 'all') {
            return statements;
        }
        Integer limitCount = 0;
        
        switch on period {
            when '7days' {
                limitCount = 1;
            }
            when '30days' {
                limitCount = 2;
            }
            when 'quarter' {
                limitCount = 3;
            }
            when '6months' {
                limitCount = 6;
            }
            when else {
                return statements;
            }
        }
        
        List<StatementWrapper> filteredStatements = new List<StatementWrapper>();
        for (Integer i = 0; i < Math.min(limitCount, statements.size()); i++) {
            filteredStatements.add(statements[i]);
        }
        System.debug('>>> filteredStatements:size = ' + filteredStatements.size());
        
        return filteredStatements;
    }
    */
    public class TenancyWrapper {
        @AuraEnabled public String tenancyId { get; set; }
        @AuraEnabled public String customerName { get; set; }
        @AuraEnabled public String tenancyNumber { get; set; }
        @AuraEnabled public String propertyAddress { get; set; }
        @AuraEnabled public String propertyType { get; set; }
        @AuraEnabled public String rentTag { get; set; }
        @AuraEnabled public Boolean isActive { get; set; }
        @AuraEnabled public Decimal orchardChequeDigit {get; set;}
        @AuraEnabled public Date occupancyStartDate {get; set;}
        @AuraEnabled public String rentType {get; set;}
        @AuraEnabled public String chargeFrequency {get; set;}
        @AuraEnabled public Decimal weeklyRent {get; set;}
        @AuraEnabled public String rentFrequencyLabel {get; set;}
        @AuraEnabled public String rentPeriodLabel {get; set;}

        public TenancyWrapper(Member__c member) {
            this.tenancyId = member.Tenancy__c;
            this.customerName = member.Contact__r.name;
            this.tenancyNumber = member.Tenancy__r.YH_TenancyNumber__c;
            this.propertyAddress = member.Tenancy__r.PropertyAddress__c;
            this.propertyType = member.Tenancy__r.AssetClass__c;
            this.rentTag = member.Tenancy__r.RentTag__c;
            this.isActive = member.IsActive__c;
            this.orchardChequeDigit = member.Tenancy__r.OrchardChequeDigit__c;
            this.occupancyStartDate = member.DateOfOccupancy__c;
            this.rentType = member.Tenancy__r.RentType__c;
            this.chargeFrequency = member.Tenancy__r.YH_ChargeFrequency__c;
        }
    }

   /* public class TenancyGroupWrapper {
        @AuraEnabled public String tenancyId { get; set; }
        @AuraEnabled public Boolean isExpand { get; set; }
        @AuraEnabled public String propertyAddress { get; set; }
        @AuraEnabled public String propertyType { get; set; }
        @AuraEnabled public Boolean isActive { get; set; }
        @AuraEnabled public List<AccountWrapper> accounts { get; set; }
        
        public TenancyGroupWrapper(String tenancyId, String propertyAddress, String propertyType, Boolean isActive, Boolean isExpand, List<AccountWrapper> accounts) {
            this.tenancyId = tenancyId;
            this.isExpand = isExpand;
            this.propertyAddress = propertyAddress;
            this.propertyType = propertyType;
            this.isActive = isActive;
            this.accounts = accounts;
        }
    }*/
    public class AccountWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String accountDescription { get; set; }
        @AuraEnabled public String occupancyCommenced { get; set; }
        @AuraEnabled public String occupancyTerminated { get; set; }
        @AuraEnabled public Decimal accountBalance { get; set; }
        @AuraEnabled public String orchardChequeDigit {get; set;}
        @AuraEnabled public String tenancyNumber {get; set;}
        public AccountWrapper(String id, String accountDescription, String occupancyCommenced, 
                            String occupancyTerminated, Decimal accountBalance, String orchardChequeDigit, String tenancyNumber) {
            this.id = id;
            this.accountDescription = accountDescription;
            this.occupancyCommenced = occupancyCommenced;
            this.occupancyTerminated = occupancyTerminated;
            this.accountBalance = accountBalance;
            this.orchardChequeDigit = orchardChequeDigit;
            this.tenancyNumber = tenancyNumber;
        }
    }
    
    public class StatementsWrapper {
        @AuraEnabled public List<StatementWrapper> statements { get; set; }
        @AuraEnabled public Integer totalCount { get; set; }
        
        public StatementsWrapper() {
            this.statements = new List<StatementWrapper>();
            this.totalCount = 0;
        }
    }
    
    public class StatementWrapper {
        @AuraEnabled public String balanceDate{ get; set; }
        @AuraEnabled public TransactionWrapper rent { get; set; }
        @AuraEnabled public ChargesWrapper charges { get; set; }
        @AuraEnabled public List<TransactionWrapper> adjustments { get; set; }
        @AuraEnabled public List<TransactionWrapper> benefits { get; set; }
        @AuraEnabled public List<TransactionWrapper> payments { get; set; }
        @AuraEnabled public Decimal balance { get; set; }
        @AuraEnabled public String formattedBalance {get; set;}
                
        public StatementWrapper(String balanceDate, Decimal balance, TransactionWrapper rent, ChargesWrapper charges, List<TransactionWrapper> benefits, 
                                List<TransactionWrapper> payments, List<TransactionWrapper> adjustments ){
            this.balanceDate  = String.isNotBlank(balanceDate) ? balanceDate : '-';
            this.rent = rent;
            this.charges = charges;
            this.adjustments = adjustments;
            this.benefits = benefits;
            this.payments = payments;
            this.balance = balance;
            this.formattedBalance = getFormattedBalance(balance);
        }
        private String getFormattedBalance(Decimal balance){
            if(balance == 0.00){
                return '0.00';
            } else if(balance < 0.00){
                return this.balance + '(CR)';
            }else if(balance > 0.00){
                return this.balance + '(AR)';
            }else{
                return '-';
            }
        }
    }
    public class TransactionWrapper{
        @AuraEnabled public Decimal amount { get; set; }
        @AuraEnabled public String transactionDate { get; set; }
        @AuraEnabled public String description { get; set; }
        public TransactionWrapper(Decimal amount, String transactionDate) {
            this.amount = amount;
            this.transactionDate = transactionDate;
        }
        public TransactionWrapper(Decimal amount, String transactionDate, String description) {
            this.amount = amount;
            this.transactionDate = transactionDate;
            this.description = description;
        }
    }
    public class ChargesWrapper{
        @AuraEnabled public Decimal totalAmount { get; set; }
        @AuraEnabled public List<TransactionWrapper> chargesTransactions { get; set; }
        public ChargesWrapper(Decimal totalAmount, List<TransactionWrapper> chargesTransactions) {
            this.totalAmount = totalAmount;
            this.chargesTransactions = chargesTransactions;
        }
    }
    
}