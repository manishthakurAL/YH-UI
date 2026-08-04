@isTest
public with sharing class UthApplication {

    public static List<YH_Application__c> getAll(){
        return Database.query('SELECT '+
            String.join(new List<String>(YH_Application__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
            ' FROM YH_Application__c ' + 
            ' ORDER BY Id'
        );
    }

    public static YH_Application__c buildApplication(String caseId, String propertyId){
        YH_Application__c aApplication = new YH_Application__c(
            Case__c = caseId,
            Property__c = propertyId,
            TypeOfTenancy__c = ApplicationDecorator.SOLE_TENANCY,
            ASBChecksPassed__c = ApplicationDecorator.YES,
            ApplicationToProceed__c = ApplicationDecorator.YES,
            AwareOfBathroomType__c = ApplicationDecorator.YES,
            AwareOfFloorLevel__c = ApplicationDecorator.YES,
            BringingFurniture__c = ApplicationDecorator.NO,
            CameFromTempAccomOrRefuge__c = ApplicationDecorator.YES,
            CanGetItemsFromLACharities__c = ApplicationDecorator.YES,
            CarParking__c = ApplicationDecorator.YES,
            CreditCheckPassed__c = ApplicationDecorator.YES,
            CriminalConvictionsChecksPassed__c = ApplicationDecorator.YES,
            Disabilities__c = ApplicationDecorator.NO,
            EmployerReferenceCheck__c = ApplicationDecorator.YES,
            FaceFinancialHardship__c = ApplicationDecorator.YES,
            FurnitureRequired__c = ApplicationDecorator.YES,
            FutureHouseholdMembers__c = ApplicationDecorator.NO,
            GardenSize__c = ApplicationDecorator.YES,
            HaveYoungChildren__c = ApplicationDecorator.YES,
            HeatingType__c = ApplicationDecorator.YES,
            IDCheckCompleteRightToRent__c = ApplicationDecorator.YES,
            ItemsInProperty__c = ApplicationDecorator.YES,
            LandlordCheckResideChecked__c = ApplicationDecorator.YES,
            Pets__c = ApplicationDecorator.YES,
            PhotosProvided__c = ApplicationDecorator.YES,
            RentDebtChecksPassed__c = ApplicationDecorator.YES,
            UrbanRural__c = ApplicationDecorator.YES,
            VideoWalkthroughProvided__c = ApplicationDecorator.YES,
            YHEmployeeRelatedToYH_Employee__c = ApplicationDecorator.YES,
            FloorplanProvided__c = ApplicationDecorator.YES,
            HowWillHomeBeFurnished__c = 'Good'
        );
        return aApplication;
    }

    public static YH_Application__c buildApplication(String caseId, String propertyId, String starterOrAssured, Date tenancyStartDate){
        YH_Application__c application = buildApplication(caseId, propertyId);
        application.StarterOrAssured__c = starterOrAssured;
        application.Property__c = propertyId;
        application.TenancyStartDate__c = tenancyStartDate;
        return application;
    }
 
    public static YH_Application__c signApplication(YH_Application__c application){
        application.TenancyAgreementSigned__c = ApplicationDecorator.YES;
        application.MailingAddressUpdate__c = ApplicationDecorator.MAILING_ADDRESS_UPDATE_ADDRESS_NOT_PROPERTY_ADDRESS;
        return application;
    }

    public static YH_Application__c buildApplication(String caseId, String propertyId, String starterOrAssured, Date tenancyStartDate, String agrSigned, String welcomPack, String mailAddressUpdate){
        YH_Application__c aApplication = buildApplication(caseId, propertyId, starterOrAssured, tenancyStartDate);
        aApplication.TenancyAgreementSigned__c = agrSigned;
        aApplication.MailingAddressUpdate__c = mailAddressUpdate;
        aApplication.WelcomePackSent__c = welcomPack;
        return aApplication;
    }

}