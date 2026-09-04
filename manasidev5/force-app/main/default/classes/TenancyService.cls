public without sharing class TenancyService {

    YH_Application__c[] applications;

    public static TenancyService getInstance(YH_Application__c[] applications) {
        return (new TenancyService(applications));
    }

    private TenancyService(YH_Application__c[] applications) {
        this.applications = applications;
    }
    public TenancyService(){}
    
    public void createTenancy() {
        List<YH_Tenancy__c> tenancies = new List<YH_Tenancy__c>();
        List<Member__c> members = new List<Member__c>();
        MemberService memberService = new MemberService();
        for(YH_Application__c app : this.applicationMap.values()){
            YH_Tenancy__c tenancy = new YH_Tenancy__c();
            YH_Property__c property = this.propertyMap.get(app.Case__r.Property__c);
            tenancy.Active__c = true;
            tenancy.Property__c = property.Id;
            tenancy.YH_AgreementType__c = getAgreementType(app, property);
            tenancy.YH_ApplicationMethod__c = app.ApplicationMethod__c;
            tenancy.YH_TenancyReason__c = app.ReasonForTenancy__c;
            tenancy.YH_TenancyType__c = app.TypeOfTenancy__c;
            tenancy.StartDate__c = app.TenancyStartDate__c;
            tenancy.FixedTermEndDateFromLettings__c = app.FixedTermEndDate__c;
            tenancy.ConversionDate__c = setConversionDateOnStarterTenancy(app, property);
            for (Applicant__c applicant:app.Applicants__r) {
                Boolean addressUpdate = (app.MailingAddressUpdate__c == ApplicationDecorator.MAILING_ADDRESS_UPDATE_UPDATE_TO_PROPERTY_ADDRESS)? true : false;
                String SynchPropertyAddressOnActivation = addressUpdate ? CaseDecorator.CASE_TYPE_LETTING : null;
                Address SynchAddress = addressUpdate ? property.Address__c : null;
                Member__c mem =  memberService.createMember(
                                        null,
                                        applicant.Contact__c,
                                        applicant.ApplicantType__c,
                                        app.TenancyStartDate__c,
                                        SynchPropertyAddressOnActivation,
                                        SynchAddress
                                    );
                mem.Tenancy__r = tenancy;
                members.add(mem);
            }
            tenancies.add(tenancy);
        }
        saveTenancyAndMembers(tenancies, members);
    }

    public TenancyService.Result validateEndDate(YH_Tenancy__c tenancy, Date previousTenancyEndDate, Date newTenancyEndDate, String tenancyEndDateChangeReason, Date dateNoticereceiveddate, String originOfRequest){
        TenancyService.TenancyEndDateCalculationInterface result = getInstance(tenancy);
        if(result == null){
            NoDataFoundException e = new NoDataFoundException();
            e.setMessage(tenancy.Name +' : The requirements for handling the Rent Tag have not been specified. Therefore, there is no implementation to manage these Rent Tags, and the Tenancy End Date cannot be updated. Please contact the system administrator.');
            throw e;
        }
        return result.validateTenancyEndDate(tenancy, newTenancyEndDate, previousTenancyEndDate, dateNoticereceiveddate, tenancyEndDateChangeReason, originOfRequest);
    } 

    public Date calculateTenancyEndDate(YH_Tenancy__c tenancy, Date dateNoticereceiveddate){
        TenancyService.TenancyEndDateCalculationInterface result = getInstance(tenancy);
        if(result == null){
            NoDataFoundException e = new NoDataFoundException();
            e.setMessage(tenancy.Name +' : The requirements for handling the Rent Tag have not been specified. Therefore, there is no implementation to manage these Rent Tags, and the Tenancy End Date cannot be updated. Please contact the system administrator.');
            throw e;   
        }
        return result.calculateTenancyEndDate(tenancy, dateNoticereceiveddate);
        
    }

    private String getAgreementType(YH_Application__c application, YH_Property__c property) {
        String agreementType;
        if (application.StarterOrAssured__c == ApplicationDecorator.STARTER_TENANCY) {
            agreementType = TenancyDecorator.TENANCY_AGREEMENT_TYPE_STARTER;
        } else if (application.StarterOrAssured__c == ApplicationDecorator.ASSURED_TENANCY) {
            agreementType = TenancyDecorator.TENANCY_AGREEMENT_TYPE_ASSURED;
        } else if (property.YH_ProductType__c == TenancyDecorator.TENANCY_AGREEMENT_TYPE_RENT_TO_BUY) {
            agreementType = TenancyDecorator.TENANCY_AGREEMENT_TYPE_RENT_TO_BUY;
        } else if (property.YH_HousingPurpose__c == PropertyDecorator.HOUSINGPURPOSE_SUPPORTED_HOUSING || 
                    property.YH_RentType__c == PropertyDecorator.RENT_TYPE_MARKET_RENT || 
                    property.YH_RentType__c == PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT) {
            agreementType = TenancyDecorator.TENANCY_AGREEMENT_TYPE_ASSURED_SHORT_HOLD;
        }
        return agreementType;
    }


    private Date setConversionDateOnStarterTenancy(YH_Application__c application, YH_Property__c property) {
        Date conversionDate;
        if (application.StarterOrAssured__c == ApplicationDecorator.STARTER_TENANCY
                    && (property.RentTag__c ==  PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT
                        || property.RentTag__c ==  PropertyDecorator.RENT_TYPE_SOCIAL_RENT 
                        || property.RentTag__c ==  PropertyDecorator.PRODUCT_TYPE_SCHEMES_SOCIAL 
                        || property.RentTag__c ==  PropertyDecorator.PRODUCT_TYPE_SCHEMES_AFFORDABLE 
                        || property.RentTag__c ==  PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE_SOCIAL 
                        || property.RentTag__c ==  PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE_AFFORDABLE 
                        )) {
                            conversionDate = application.StarterTenancyConversionDate__c;
        } 
        return conversionDate;
    }

    private void saveTenancyAndMembers(List<YH_Tenancy__c> tenancies, List<Member__c> members) {
        // Assert.areEqual(5, tenancies.size(), 'atleast one tenancy to insert');
        insert tenancies;
        for (Member__c member: members) {
            member.Tenancy__c = member.Tenancy__r.Id;
        }
        insert members;
    }


    private Map<Id, YH_Application__c> applicationMap {
        get {
            if (this.applicationMap == null) {
                this.applicationMap = new Map<Id, YH_Application__c>( [  
                    SELECT StarterTenancyConversionDate__c, ApplicationMethod__c, ReasonForTenancy__c, Case__c, Case__r.Property__c, StarterOrAssured__c, 
                        TypeOfTenancy__c, TenancyStartDate__c, FixedTermEndDate__c,MailingAddressUpdate__c,
                        (SELECT Contact__c, ApplicantType__c  FROM Applicants__r) 
                    FROM   YH_Application__c 
                    WHERE  Id IN :this.applications
                ]);
            }
            return this.applicationMap;
        }
        set;
    }

    private Map<Id, YH_Property__c> propertyMap {
        get {
            if (this.propertyMap == null) {
                this.propertyMap = new Map<Id, YH_Property__c>();
                Set<Id> propertyIds = new Set<Id>();
                for (YH_Application__c app: this.applicationMap.values()) {
                    propertyIds.add(app.case__r.Property__c);
                }                
                this.propertyMap = new Map<Id, YH_Property__c>([  
                    SELECT YH_ProductType__c, YH_HousingPurpose__c, YH_RentType__c, RentTag__c,Address__c
                    FROM   YH_Property__c 
                    WHERE  Id IN :propertyIds
                ]);
            }
            return this.propertyMap;
        }
        set;
    }

    public TenancyService.TenancyEndDateCalculationInterface getInstance(YH_Tenancy__c tenancyRecord){
		TenancyService.TenancyEndDateCalculationInterface instance;
       if(
        tenancyRecord.HousingPurposeFormula__c == PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS && tenancyRecord.RentType__c == PropertyDecorator.RENT_TYPE_SOCIAL_RENT && tenancyRecord.ProductType__c == PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL ||
        tenancyRecord.HousingPurposeFormula__c == PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS && tenancyRecord.RentType__c == PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT && tenancyRecord.ProductType__c == PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL ||
        tenancyRecord.HousingPurposeFormula__c == PropertyDecorator.HOUSINGPURPOSE_SUPPORTED_HOUSING && tenancyRecord.RentType__c == PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT && tenancyRecord.ProductType__c == PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL ||
        tenancyRecord.HousingPurposeFormula__c == PropertyDecorator.HOUSINGPURPOSE_SUPPORTED_HOUSING && tenancyRecord.RentType__c == PropertyDecorator.RENT_TYPE_SOCIAL_RENT && tenancyRecord.ProductType__c == PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL ||
        tenancyRecord.HousingPurposeFormula__c == PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE && tenancyRecord.RentType__c == PropertyDecorator.RENT_TYPE_SOCIAL_RENT && tenancyRecord.ProductType__c == PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL ||
        tenancyRecord.HousingPurposeFormula__c == PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE && tenancyRecord.RentType__c == PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT && tenancyRecord.ProductType__c == PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL ||
        tenancyRecord.HousingPurposeFormula__c == PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE && tenancyRecord.RentType__c == PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT && tenancyRecord.ProductType__c == PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE ||
        tenancyRecord.HousingPurposeFormula__c == PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE && tenancyRecord.RentType__c == PropertyDecorator.RENT_TYPE_SOCIAL_RENT && tenancyRecord.ProductType__c == PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE){
            instance = new SocialRentTenancyEndDateCalculateImpl();

        } else if(
            tenancyRecord.HousingPurposeFormula__c == PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS && tenancyRecord.RentType__c == PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT && tenancyRecord.ProductType__c == PropertyDecorator.RENT_TYPE_RENTTOBUY ||
            tenancyRecord.HousingPurposeFormula__c == PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS && tenancyRecord.RentType__c == PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT && tenancyRecord.ProductType__c == PropertyDecorator.PRODUCT_TYPE_MORTGAGE_RESCUE ||
            tenancyRecord.HousingPurposeFormula__c == PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS && tenancyRecord.RentType__c == PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT && tenancyRecord.ProductType__c == PropertyDecorator.PRODUCT_TYPE_TRY_BEFORE_YOU_BUY ||
            tenancyRecord.HousingPurposeFormula__c == PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS && tenancyRecord.RentType__c == PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT && tenancyRecord.ProductType__c == PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT) {
                instance = new INTRentTenancyEndDateCalculateImpl();
        
        } else if(
            tenancyRecord.HousingPurposeFormula__c == PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS && tenancyRecord.RentType__c == PropertyDecorator.RENT_TYPE_MARKET_RENT && tenancyRecord.ProductType__c == PropertyDecorator.PRODUCT_TYPE_MARKETRENTAL){
               instance = new MarketRentTenancyEndDateCalculateImpl();
    
        }
        else if(
            tenancyRecord.HousingPurposeFormula__c == PropertyDecorator.NON_RESEDENTIAL_STOCK && tenancyRecord.RentType__c == PropertyDecorator.GARAGE_RENT && tenancyRecord.ProductType__c == PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL ||
            tenancyRecord.HousingPurposeFormula__c == PropertyDecorator.NON_RESEDENTIAL_STOCK && tenancyRecord.RentType__c == PropertyDecorator.GARAGE_RENT && tenancyRecord.ProductType__c == PropertyDecorator.PRODUCT_TYPE_MARKETRENTAL){
                instance = new GarageRentTenancyEndDateCalculateImpl();
                
        }
        return instance;

    }

    public Map<Id, Member__c>  getResidentialActiveMemberByAccount(List<Account> accountList) {
        Map<Id, Member__c> memberByAccountId = new Map<Id, Member__c>();
        List<Id> accountIds = new List<Id>();
        if (!accountList.isEmpty()){
            for(Account acc : accountList){
                accountIds.add(acc.Id);
            }
            for (Member__c mem : [SELECT Contact__c,Contact__r.AccountId,Tenancy__c, Tenancy__r.Property__c, Tenancy__r.TenancyEndDate__c, AssetClass__c,
                                    Tenancy__r.HousingPurposeFormula__c, Tenancy__r.RentType__c, Tenancy__r.ProductType__c
                                    FROM Member__c
                                    WHERE Contact__r.AccountId IN :accountIds
                                    AND IsActive__c = true
                                    AND Tenancy__c != Null
                                    AND (Type__c =: MemberDecorator.TYPE_SOLO OR Type__c =: MemberDecorator.TYPE_JOINT)]) {
                                if((memberByAccountId.containsKey(mem.Contact__r.AccountId) 
                                    || (mem.AssetClass__c != PropertyDecorator.FLAT_ASSET_CLASS 
                                        && mem.AssetClass__c != PropertyDecorator.HOUSE_ASSET_CLASS) )){
                                    memberByAccountId.put(mem.Contact__r.AccountId, null); 
                                }
                                else {
                                    memberByAccountId.put(mem.Contact__r.AccountId, mem);
                                }
            }
        }
        return memberByAccountId;
    }

    public List<Member__c> getActiveTenanciesByPostCode(Id accountId, String postCode){
        List<Member__c> activeMembers = new List<Member__c>();
        if(String.isNotBlank(accountId) && String.isNotBlank(postCode)){
            activeMembers = [SELECT Contact__c, Contact__r.AccountId, Tenancy__c, Tenancy__r.Property__c, Tenancy__r.TenancyEndDate__c, AssetClass__c
                                    FROM Member__c
                                    WHERE Contact__r.AccountId = :accountId AND 
                                        IsActive__c = true AND
                                        (Type__c =: MemberDecorator.TYPE_SOLO OR Type__c =: MemberDecorator.TYPE_JOINT) AND
                                        Tenancy__r.Property__r.AddressPostalCode__c = :postCode

            ];
        }
        return activeMembers;
    }

    public interface TenancyEndDateCalculationInterface {
        TenancyService.Result validateTenancyEndDate(YH_Tenancy__c tenancy, Date newTenancyEndDate,
                    Date previousTenancyEndDate,
                    Date dateNoticereceiveddate,
                    String tenancyEndDateChangeReason,
                    String originOfRequest);
        
        Date calculateTenancyEndDate(YH_Tenancy__c tenancy, Date terminationNoticeReceivedDate);
    }
    
    public class Result{
        public Boolean isSuccessful;
        public String message;

        public Result(){
            this.isSuccessful = true;
        }
        public void setError(String message){
            this.isSuccessful = false;
            this.message = message;

        }
    }

    public String getGroupName(String tenancyName){
        return TenancyDecorator.TENANCY_SHARING + tenancyName.replace('-', '_');
    }

    /* Portal users' sharing model doesn't grant record-level access to
       YH_Property__c, so a "with sharing" traversal silently nulls out
       the property's rent fields even though the tenant has every right
       to see their own rent amount. This bypasses sharing (this class is
       "without sharing") to read just the fields the rent overview card
       needs. */
    public Map<Id, YH_Tenancy__c> getTenanciesWithRentDetails(Set<Id> tenancyIds) {
        return new Map<Id, YH_Tenancy__c>(
            [SELECT Id, YH_ChargeFrequency__c, Property__r.CurrentGrossRent__c
             FROM YH_Tenancy__c
             WHERE Id IN :tenancyIds]
        );
    }
}