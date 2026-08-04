@isTest
public with sharing class UthTenancy {
    public static YH_Tenancy__c  build(Id propertyId, Boolean isActive, String type){
        YH_Tenancy__c  tenancyRecord = new YH_Tenancy__c (
            StartDate__c = Date.Today(),
            Property__c = propertyId,
            Active__c = isActive,
            YH_TenancyType__c = type
        );
        return tenancyRecord;
    }
    public static YH_Tenancy__c  build(Id propertyId, Boolean isActive, String type, String tenancyNumber){
        YH_Tenancy__c  tenancyRecord = new YH_Tenancy__c (
            StartDate__c = Date.Today(),
            Property__c = propertyId,
            Active__c = isActive,
            YH_TenancyType__c = type,
            YH_TenancyNumber__c = tenancyNumber
        );
        return tenancyRecord;
    }

    public static YH_Tenancy__c  build(Id propertyId, Boolean isActive, String type, Date tenancyEndDate){
        YH_Tenancy__c  tenancyRecord = new YH_Tenancy__c (
            StartDate__c = Date.Today(),
            Property__c = propertyId,
            Active__c = isActive,
            YH_TenancyType__c = type,
            TenancyEndDate__c = tenancyEndDate);
        return tenancyRecord;
    }

    public static YH_Tenancy__c  build(Date startDate, String primaryReason, Id propertyId, Boolean isActive, String type){
        YH_Tenancy__c  tenancyRecord = new YH_Tenancy__c (
            Property__c = propertyId,
            Active__c = isActive,
            YH_TenancyType__c = type,
            StartDate__c = startDate,
            PrimaryReasonForLeaving__c = primaryReason
        );
        return tenancyRecord;
    }

    public static YH_Tenancy__c  build(Id propertyId, Boolean isActive, String type, Date conversionDate, String agreementType){
        YH_Tenancy__c  tenancyRecord = new YH_Tenancy__c (
            Property__c = propertyId,
            Active__c = isActive,
            YH_TenancyType__c = type,
            ConversionDate__c = System.today() + 30,
            YH_AgreementType__c = TenancyDecorator.TENANCY_AGREEMENT_TYPE_STARTER,
            StartDate__c = System.today()
        );
        return tenancyRecord;
    }

    public static YH_Tenancy__c  insertWithEndDate(Id propertyId, Boolean isActive, String type, Date tenancyEndDate){
        YH_Tenancy__c  tenancyRecord = build(
            propertyId, isActive, type, tenancyEndDate);
        insert tenancyRecord;
        return tenancyRecord;
    }

    public static List<YH_Tenancy__c > getAll(){
        return Database.query('SELECT '+
                String.join(new List<String>(YH_Tenancy__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM YH_Tenancy__c ');
    }

    public static YH_Tenancy__c getTenancyById(Id tenancyId) {
        String query = 'SELECT ' +
                String.join(new List<String>(YH_Tenancy__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
                ' FROM YH_Tenancy__c WHERE Id = :tenancyId';
        List<YH_Tenancy__c> results = Database.query(query);
        return results[0];
    }

    public static List<YH_Tenancy__c > getAllWithPropertyDetails(){
        String query =  'SELECT '+ String.join(new List<String>(YH_Tenancy__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')+', Property__r.YH_HousingPurpose__c, Property__r.YH_RentType__c, Property__r.YH_ProductType__c FROM YH_Tenancy__c';
        return Database.query(query);
    }

}