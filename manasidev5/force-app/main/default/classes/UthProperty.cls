@isTest
public with sharing class UthProperty {
    public static YH_Property__c build(){
        return new YH_Property__c();
    }

    public static YH_Property__c buildHousingPurposeProperty(String authority, String authorityCode, String housingPurpose){
        YH_Property__c propertyRecord = build();
        propertyRecord.YH_LocalAuthority__c = authority;
        propertyRecord.YH_LocalAuthorityCode__c = authorityCode;
        propertyRecord.YH_HousingPurpose__c = housingPurpose;
        propertyRecord.HandoverDate__c = Date.today().addMonths(-72);
        return propertyRecord;
    }

    public static YH_Property__c buildPropertyWithDesignAssumptions(String localAuthority, String housingPurpose, String localAuthorityCode, String rentType, String productType) {
        YH_Property__c propertyRecord = build();
        propertyRecord.YH_LocalAuthority__c = localAuthority;
        propertyRecord.YH_HousingPurpose__c = housingPurpose;
        propertyRecord.YH_LocalAuthorityCode__c = localAuthorityCode;
        propertyRecord.YH_RentType__c = rentType;
        propertyRecord.YH_ProductType__c = productType;
        return propertyRecord;
    }

    public static YH_Property__c buildPropertyWithAddress(String localAuthority, String housingPurpose, String localAuthorityCode, String rentType, String productType, String city, String postalCode) {
        YH_Property__c propertyRecord = build();
        propertyRecord.YH_LocalAuthority__c = localAuthority;
        propertyRecord.YH_HousingPurpose__c = housingPurpose;
        propertyRecord.YH_LocalAuthorityCode__c = localAuthorityCode;
        propertyRecord.YH_RentType__c = rentType;
        propertyRecord.YH_ProductType__c = productType;
        propertyRecord.Address__City__s = city;
        propertyRecord.Address__PostalCode__s = postalCode;
        return propertyRecord;
    }

    public static YH_Property__c buildPropertyWithAssetClass(String localAuthority, String housingPurpose, String localAuthorityCode, String rentType, String productType, String assetClass) {
        YH_Property__c propertyRecord = build();
        propertyRecord.YH_LocalAuthority__c = localAuthority;
        propertyRecord.YH_HousingPurpose__c = housingPurpose;
        propertyRecord.YH_LocalAuthorityCode__c = localAuthorityCode;
        propertyRecord.YH_RentType__c = rentType;
        propertyRecord.YH_ProductType__c = productType;
        propertyRecord.YH_AssetClass__c = assetClass;
        return propertyRecord;
    }

     public static YH_Property__c insertPropertyWithDesignAssumptions(String localAuthority, String housingPurpose, String localAuthorityCode, String rentType, String productType) {
          YH_Property__c propertyRecord =  buildPropertyWithDesignAssumptions(localAuthority, housingPurpose, localAuthorityCode, rentType, productType);
          insert propertyRecord;
          return propertyRecord;
    }
    
    public static YH_Property__c buildPropertyWithAssetClass(String localAuthority, String housingPurpose, String localAuthorityCode, String rentType, String productType, String Street,  String city, String postalCode, String assetClass) {
        YH_Property__c propertyRecord = build();
        propertyRecord.YH_LocalAuthority__c = localAuthority;
        propertyRecord.YH_HousingPurpose__c = housingPurpose;
        propertyRecord.YH_LocalAuthorityCode__c = localAuthorityCode;
        propertyRecord.YH_RentType__c = rentType;
        propertyRecord.YH_ProductType__c = productType;
        propertyRecord.Address__City__s = city;
         propertyRecord.Address__Street__s = Street;
        propertyRecord.Address__PostalCode__s = postalCode;
        propertyRecord.YH_AssetClass__c = assetClass;
        return propertyRecord;
    }


    public static List<YH_Property__c> getAll(){
        return Database.query('SELECT '+
                String.join(new List<String>(YH_Property__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM YH_Property__c');
    }
}