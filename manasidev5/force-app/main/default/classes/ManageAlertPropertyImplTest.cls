@isTest
public class ManageAlertPropertyImplTest {
    
    @isTest
    static void test_new_AsbestosAssumedAlert_OnPropertyInsert() {
        Date startDate = Date.today().addDays(-1);
        Date endDate = Date.today().addMonths(1);
         
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        Test.startTest();
            property.AsbestosStatus__c = PropertyDecorator.ASBESTOS_ASSUMED;
            property.AsbestosStatusStartDate__c = startDate;
            property.AsbestosStatusEndDate__c = endDate;
            insert property;

        Test.stopTest();
        List<Alert__c> alerts = UthAlert.getAll(property.Id, AlertDecorator.CATEGORY_ASBESTOS, PropertyDecorator.ASBESTOS_ASSUMED);
        System.assertEquals(1, alerts.size(), 'Asbestos alert should be created');
        System.assertEquals(true, alerts.get(0).IsActive__c, 'Asbestos alert should be active');
        System.assertEquals(startDate, alerts.get(0).StartDate__c, 'Asbestos alert should be active');
        System.assertEquals(endDate, alerts.get(0).EndDate__c, 'Asbestos alert should be active');
    }

    @isTest
    static void test_deactivate_AsbestosAssumedAlert_OnPropertyUpdate() {

        Date startDate = Date.today().addDays(-1);
        Date endDate = Date.today().addMonths(1);
        Date yesterday = Date.today().addDays(-1);
         
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        property.AsbestosStatus__c = PropertyDecorator.ASBESTOS_ASSUMED;
        property.AsbestosStatusStartDate__c =  startDate;
        property.AsbestosStatusEndDate__c = endDate;
        insert property;
        Test.startTest();
            property.AsbestosStatus__c = PropertyDecorator.NO_ASBESTOS_ASSUMED;
            update property;
       Test.stopTest();
        List<Alert__c> asbestosAssumedAlerts = UthAlert.getAll(property.Id, AlertDecorator.CATEGORY_ASBESTOS, PropertyDecorator.ASBESTOS_ASSUMED);
        System.assertEquals(1, asbestosAssumedAlerts.size(), 'Asbestos Assumed alert should be updated');
        System.assertEquals(false, asbestosAssumedAlerts.get(0).IsActive__c, 'Asbestos alert should be deactived');
        System.assertEquals(yesterday, asbestosAssumedAlerts.get(0).EndDate__c, 'Asbestos alert end date should be updated');
        System.assertEquals(startDate, asbestosAssumedAlerts.get(0).StartDate__c, 'Asbestos alert start date should be updated');


        List<Alert__c> noAsbestosAssumedAlerts = UthAlert.getAll(property.Id, AlertDecorator.CATEGORY_ASBESTOS, PropertyDecorator.NO_ASBESTOS_ASSUMED);
        System.assertEquals(1, noAsbestosAssumedAlerts.size(), 'No Asbestos Assumed alert should be Created');
        System.assertEquals(true, noAsbestosAssumedAlerts.get(0).IsActive__c, 'No Asbestos Assumed alert should be active');
        System.assertEquals(endDate, noAsbestosAssumedAlerts.get(0).EndDate__c, 'Asbestos alert end date should be updated');
        System.assertEquals(startDate, noAsbestosAssumedAlerts.get(0).StartDate__c, 'Asbestos alert start date should be updated');
    }

    @isTest
    static void test_syncDates_AsbestosAssumedAlert_OnPropertyUpdate() {
        Date startDate = Date.today().addDays(-1);
        Date endDate = Date.today().addMonths(1);
        Date newStartDate = Date.today().addDays(1);
        Date newEndDate = Date.today().addMonths(2);
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        property.AsbestosStatus__c = PropertyDecorator.ASBESTOS_ASSUMED;
        property.AsbestosStatusStartDate__c = startDate;
        property.AsbestosStatusEndDate__c = endDate;
        insert property;
        Test.startTest();
            property.AsbestosStatusStartDate__c = newStartDate;
            property.AsbestosStatusEndDate__c = newEndDate;
            update property;
       Test.stopTest();
        List<Alert__c> asbestosAssumedAlerts = UthAlert.getAll(property.Id, AlertDecorator.CATEGORY_ASBESTOS, PropertyDecorator.ASBESTOS_ASSUMED);
        System.assertEquals(1, asbestosAssumedAlerts.size(), 'Asbestos Assumed alert should be updated');
        System.assertEquals(newStartDate, asbestosAssumedAlerts.get(0).StartDate__c, 'Asbestos alert start date should be updated');
        System.assertEquals(newEndDate, asbestosAssumedAlerts.get(0).EndDate__c, 'Asbestos alert end date should be updated');
        System.assertEquals(false, asbestosAssumedAlerts.get(0).IsActive__c, 'Asbestos alert should be deactive');        
    }

    @isTest
    static void test_syncDatesStatus_AsbestosAssumedAlert_OnPropertyUpdate() {
        Date startDate = Date.today().addDays(-1);
        Date endDate = Date.today().addMonths(1);
        Date newStartDate = Date.today().addDays(1);
        Date newEndDate = Date.today().addMonths(2);
        Date yesterday = Date.today().addDays(-1);
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        property.AsbestosStatus__c = PropertyDecorator.ASBESTOS_ASSUMED;
        property.AsbestosStatusStartDate__c = startDate;
        property.AsbestosStatusEndDate__c = endDate;
        insert property;
        Test.startTest();
            property.AsbestosStatus__c = PropertyDecorator.NO_ASBESTOS_ASSUMED;
            property.AsbestosStatusStartDate__c = newStartDate;
            property.AsbestosStatusEndDate__c = newEndDate;
            update property;
       Test.stopTest();
        List<Alert__c> asbestosAssumedAlerts = UthAlert.getAll(property.Id, AlertDecorator.CATEGORY_ASBESTOS, PropertyDecorator.ASBESTOS_ASSUMED);
        System.assertEquals(1, asbestosAssumedAlerts.size(), 'Asbestos Assumed alert should be updated');
        System.assertEquals(startDate, asbestosAssumedAlerts.get(0).StartDate__c, 'Asbestos alert start date should be updated');
        System.assertEquals(yesterday, asbestosAssumedAlerts.get(0).EndDate__c, 'Asbestos alert end date should be updated');
        System.assertEquals(false, asbestosAssumedAlerts.get(0).IsActive__c, 'Asbestos alert should be active');   
        
        List<Alert__c> noAsbestosAssumedAlerts = UthAlert.getAll(property.Id, AlertDecorator.CATEGORY_ASBESTOS, PropertyDecorator.NO_ASBESTOS_ASSUMED);
        System.assertEquals(1, noAsbestosAssumedAlerts.size(), 'No Asbestos Assumed alert should be Created');
        System.assertEquals(false, noAsbestosAssumedAlerts.get(0).IsActive__c, 'No Asbestos Assumed alert should be deActive');
        System.assertEquals(newStartDate, noAsbestosAssumedAlerts.get(0).StartDate__c, 'No Asbestos alert end date should be updated');
        System.assertEquals(newEndDate, noAsbestosAssumedAlerts.get(0).EndDate__c, 'No Asbestos alert start date should be updated');
    }

    

    @isTest
    static void test_new_RighttoBuyAlert_OnPropertyInsert() {
        Date startDate = Date.today().addDays(-1);
        Date endDate = Date.today().addMonths(1);
         
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        Test.startTest();
            property.RightToBuyOrAcquire__c = PropertyDecorator.RIGHT_TO_BUY;
            property.RighttoBuyorAcquireStartDate__c = startDate;
            property.RighttoBuyorAcquireEndDate__c = endDate;
            insert property;

        Test.stopTest();
        List<Alert__c> righttoBuyAlerts = UthAlert.getAll(property.Id, AlertDecorator.TYPE_PROPERTY, PropertyDecorator.RIGHT_TO_BUY);
        System.assertEquals(1, righttoBuyAlerts.size(), 'Right to Buy alert should be created');
        System.assertEquals(true, righttoBuyAlerts.get(0).IsActive__c, 'Right to Buy alert should be active');
        System.assertEquals(startDate, righttoBuyAlerts.get(0).StartDate__c, 'Right to Buy alert should be active');
        System.assertEquals(endDate, righttoBuyAlerts.get(0).EndDate__c, 'Right to Buy alert should be active');
    }

    @isTest
    static void test_deactivate_RighttoBuyAlert_OnPropertyUpdate() {

        Date startDate = Date.today().addDays(-1);
        Date endDate = Date.today().addMonths(1);
        Date yesterday = Date.today().addDays(-1);
         
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        property.RightToBuyOrAcquire__c = PropertyDecorator.RIGHT_TO_BUY;
        property.RighttoBuyorAcquireStartDate__c = Date.today().addDays(-1);
        property.RighttoBuyorAcquireEndDate__c = Date.today().addMonths(1);
        insert property;
        Test.startTest();
            property.RightToBuyOrAcquire__c = null;
            update property;
        Test.stopTest();
        
        List<Alert__c> righttoBuyAlerts = UthAlert.getAll(property.Id, AlertDecorator.TYPE_PROPERTY, PropertyDecorator.RIGHT_TO_BUY);
        System.assertEquals(1, righttoBuyAlerts.size(), 'Right to Buy alert should be updated and new created');
        System.assertEquals(false, righttoBuyAlerts.get(0).IsActive__c, 'Right to Buy alert should be deactived');
        System.assertEquals(startDate, righttoBuyAlerts.get(0).StartDate__c, 'Right to Buy alert should be active');
        System.assertEquals(yesterday, righttoBuyAlerts.get(0).EndDate__c, 'Right to Buy alert should be active');
    }

    @isTest
    static void test_syncDates_RighttoBuyAlert_OnPropertyUpdate() {
        Date startDate = Date.today().addDays(-1);
        Date endDate = Date.today().addMonths(1);
        Date newStartDate = Date.today().addDays(1);
        Date newEndDate = Date.today().addMonths(2);
        
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        property.RightToBuyOrAcquire__c = PropertyDecorator.RIGHT_TO_BUY;
        property.RighttoBuyorAcquireStartDate__c = startDate;
        property.RighttoBuyorAcquireEndDate__c = endDate;
        insert property;
        Test.startTest();
            property.RighttoBuyorAcquireStartDate__c = newStartDate;
            property.RighttoBuyorAcquireEndDate__c = newEndDate;
            update property;
       Test.stopTest();
        List<Alert__c> righttoBuyAlerts = UthAlert.getAll(property.Id, AlertDecorator.TYPE_PROPERTY, PropertyDecorator.RIGHT_TO_BUY);
        System.assertEquals(1, righttoBuyAlerts.size(), 'Right to Buy alert should be updated');
        System.assertEquals(newStartDate, righttoBuyAlerts.get(0).StartDate__c, 'Right to Buy alert start date should be updated');
        System.assertEquals(newEndDate, righttoBuyAlerts.get(0).EndDate__c, 'Right to Buy alert end date should be updated');
        System.assertEquals(false, righttoBuyAlerts.get(0).IsActive__c, 'Right to Buy alert should be deactive');        
    }

    @isTest
    static void test_syncDatesStatus_RighttoBuyAlert_OnPropertyUpdate() {
        Date startDate = Date.today().addDays(-1);
        Date endDate = Date.today().addMonths(1);
        Date newStartDate = Date.today().addDays(1);
        Date newEndDate = Date.today().addMonths(2);
        Date yesterday = Date.today().addDays(-1);
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        property.RightToBuyOrAcquire__c = PropertyDecorator.RIGHT_TO_BUY;
        property.RighttoBuyorAcquireStartDate__c = startDate;
        property.RighttoBuyorAcquireEndDate__c = endDate;
        insert property;
        Test.startTest();
            property.RightToBuyOrAcquire__c = PropertyDecorator.RIGHT_TO_ACQUIRE;
            property.RighttoBuyorAcquireStartDate__c = newStartDate;
            property.RighttoBuyorAcquireEndDate__c = newEndDate;
            update property;
        Test.stopTest();
        List<Alert__c> righttoBuyAlerts = UthAlert.getAll(property.Id, AlertDecorator.TYPE_PROPERTY, PropertyDecorator.RIGHT_TO_BUY);
        System.assertEquals(1, righttoBuyAlerts.size(), 'Right to Buy alert should be updated');
        System.assertEquals(startDate, righttoBuyAlerts.get(0).StartDate__c, 'Right to Buy alert start date should not be updated');
        System.assertEquals(yesterday, righttoBuyAlerts.get(0).EndDate__c, 'Right to Buy alert end date should be updated');
        System.assertEquals(false, righttoBuyAlerts.get(0).IsActive__c, 'Right to Buy alert should be deactive'); 
        
        List<Alert__c> righttoAcquireAlerts = UthAlert.getAll(property.Id, AlertDecorator.TYPE_PROPERTY, PropertyDecorator.RIGHT_TO_ACQUIRE);
        System.assertEquals(1, righttoAcquireAlerts.size(), 'Right to Acquire alert should be updated');
        System.assertEquals(newStartDate, righttoAcquireAlerts.get(0).StartDate__c, 'Right to Acquire alert start date should be updated');
        System.assertEquals(newEndDate, righttoAcquireAlerts.get(0).EndDate__c, 'Right to Acquire alert end date should be updated');
        System.assertEquals(false, righttoAcquireAlerts.get(0).IsActive__c, 'Right to Acquire alert should be deActive'); 
    }



    @isTest
    static void test_new_Section20Alert_OnPropertyInsert() {
        Date startDate = Date.today().addDays(-1);
        Date endDate = Date.today().addMonths(1);
         
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        Test.startTest();
            property.Section20ConsultationRequired__c = PropertyDecorator.SECTION_20_YES;
            property.Section20ConsultationReqStartDate__c = startDate;
            property.Section20ConsultationReqEndDate__c = endDate;
            insert property;

        Test.stopTest();
        List<Alert__c> section20Alerts = UthAlert.getAll(property.Id, AlertDecorator.TYPE_PROPERTY, AlertDecorator.SUB_CATEGORY_SECTION_20);
        System.assertEquals(1, section20Alerts.size(), 'Section 20 alert should be created');
        System.assertEquals(true, section20Alerts.get(0).IsActive__c, 'Section 20 alert should be active');
        System.assertEquals(startDate, section20Alerts.get(0).StartDate__c, 'Section 20 alert should be active');
        System.assertEquals(endDate, section20Alerts.get(0).EndDate__c, 'Section 20 alert should be active');
    }

    @isTest
    static void test_deactivate_Section20Alert_OnPropertyUpdate() {

        Date startDate = Date.today().addDays(-1);
        Date endDate = Date.today().addMonths(1);
        Date yesterday = Date.today().addDays(-1);
         
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        property.Section20ConsultationRequired__c = PropertyDecorator.SECTION_20_YES;
        property.Section20ConsultationReqStartDate__c = startDate;
        property.Section20ConsultationReqEndDate__c = endDate;
        insert property;
        Test.startTest();
            property.Section20ConsultationRequired__c = PropertyDecorator.SECTION_20_NO;
            update property;
        Test.stopTest();
        
        List<Alert__c> section20Alerts = UthAlert.getAll(property.Id, AlertDecorator.TYPE_PROPERTY, AlertDecorator.SUB_CATEGORY_SECTION_20);
        System.assertEquals(1, section20Alerts.size(), 'Section 20 alert should be updated and new created');
        System.assertEquals(false, section20Alerts.get(0).IsActive__c, 'Section 20 alert should be deactived');
        System.assertEquals(startDate, section20Alerts.get(0).StartDate__c, 'Section 20 alert should be active');
        System.assertEquals(yesterday, section20Alerts.get(0).EndDate__c, 'Section 20 alert should be active');
    }

    @isTest
    static void test_syncDates_Section20Alert_OnPropertyUpdate() {
        Date startDate = Date.today().addDays(-1);
        Date endDate = Date.today().addMonths(1);
        Date newStartDate = Date.today().addDays(1);
        Date newEndDate = Date.today().addMonths(2);
        
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        property.Section20ConsultationRequired__c = PropertyDecorator.SECTION_20_YES;
        property.Section20ConsultationReqStartDate__c = startDate;
        property.Section20ConsultationReqEndDate__c = endDate;
        insert property;
        Test.startTest();
            property.Section20ConsultationReqStartDate__c = newStartDate;
            property.Section20ConsultationReqEndDate__c = newEndDate;
            update property;
       Test.stopTest();
        List<Alert__c> section20Alerts = UthAlert.getAll(property.Id, AlertDecorator.TYPE_PROPERTY, AlertDecorator.SUB_CATEGORY_SECTION_20);
        System.assertEquals(1, section20Alerts.size(), 'Section 20 alert should be updated');
        System.assertEquals(newStartDate, section20Alerts.get(0).StartDate__c, 'Section 20 alert start date should be updated');
        System.assertEquals(newEndDate, section20Alerts.get(0).EndDate__c, 'Section 20 alert end date should be updated');
        System.assertEquals(false, section20Alerts.get(0).IsActive__c, 'Section 20 alert should be deactive');        
    }

    @isTest
    static void test_syncDatesStatus_Section20Alert_OnPropertyUpdate() {
        Date startDate = Date.today().addDays(-1);
        Date endDate = Date.today().addMonths(1);
        Date newStartDate = Date.today().addDays(1);
        Date newEndDate = Date.today().addMonths(2);
        Date yesterday = Date.today().addDays(-1);
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        property.Section20ConsultationRequired__c = PropertyDecorator.SECTION_20_YES;
        property.Section20ConsultationReqStartDate__c = startDate;
        property.Section20ConsultationReqEndDate__c = endDate;
        insert property;
        Test.startTest();
            property.Section20ConsultationRequired__c = PropertyDecorator.SECTION_20_NO;
            property.Section20ConsultationReqStartDate__c = newStartDate;
            property.Section20ConsultationReqEndDate__c = newEndDate;
            update property;
        Test.stopTest();
        List<Alert__c> section20Alerts = UthAlert.getAll(property.Id, AlertDecorator.TYPE_PROPERTY, AlertDecorator.SUB_CATEGORY_SECTION_20);
        System.assertEquals(1, section20Alerts.size(), 'Section 20 alert should be updated');
        System.assertEquals(startDate, section20Alerts.get(0).StartDate__c, 'Section 20 alert start date should not be updated');
        System.assertEquals(yesterday, section20Alerts.get(0).EndDate__c, 'Section 20 alert end date should be updated');
        System.assertEquals(false, section20Alerts.get(0).IsActive__c, 'Section 20 alert should be deactive'); 
    }

    @isTest
    static void test_propertyAlerts_Combined_OnPropertyInsert() {
        Date startDate = Date.today().addDays(-1);
        Date endDate = Date.today().addMonths(1);
        Date newStartDate = Date.today().addDays(1);
        Date newEndDate = Date.today().addMonths(2);
        Date yesterday = Date.today().addDays(-1);
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        
        Test.startTest();
            property.AsbestosStatus__c = PropertyDecorator.ASBESTOS_ASSUMED;
            property.AsbestosStatusStartDate__c = startDate;
            property.AsbestosStatusEndDate__c = endDate;
            property.RightToBuyOrAcquire__c = PropertyDecorator.RIGHT_TO_BUY;
            property.RighttoBuyorAcquireStartDate__c = startDate;
            property.RighttoBuyorAcquireEndDate__c = endDate;
            property.Section20ConsultationRequired__c = PropertyDecorator.SECTION_20_YES;
            property.Section20ConsultationReqStartDate__c = startDate;
            property.Section20ConsultationReqEndDate__c = endDate;
            insert property;
        Test.stopTest();
        List<Alert__c> alerts = UthAlert.getAll(property.Id, AlertDecorator.CATEGORY_ASBESTOS, PropertyDecorator.ASBESTOS_ASSUMED);
        System.assertEquals(1, alerts.size(), 'Asbestos alert should be created');
        System.assertEquals(true, alerts.get(0).IsActive__c, 'Asbestos alert should be active');
        System.assertEquals(startDate, alerts.get(0).StartDate__c, 'Asbestos alert should be active');
        System.assertEquals(endDate, alerts.get(0).EndDate__c, 'Asbestos alert should be active');

        List<Alert__c> righttoBuyAlerts = UthAlert.getAll(property.Id, AlertDecorator.TYPE_PROPERTY, PropertyDecorator.RIGHT_TO_BUY);
        System.assertEquals(1, righttoBuyAlerts.size(), 'Right to Buy alert should be created');
        System.assertEquals(true, righttoBuyAlerts.get(0).IsActive__c, 'Right to Buy alert should be active');
        System.assertEquals(startDate, righttoBuyAlerts.get(0).StartDate__c, 'Right to Buy alert should be active');
        System.assertEquals(endDate, righttoBuyAlerts.get(0).EndDate__c, 'Right to Buy alert should be active');

        List<Alert__c> section20Alerts = UthAlert.getAll(property.Id, AlertDecorator.TYPE_PROPERTY, AlertDecorator.SUB_CATEGORY_SECTION_20);
        System.assertEquals(1, section20Alerts.size(), 'Section 20 alert should be updated');
        System.assertEquals(startDate, section20Alerts.get(0).StartDate__c, 'Section 20 alert start date should not be updated');
        System.assertEquals(endDate, section20Alerts.get(0).EndDate__c, 'Section 20 alert end date should be updated');
        System.assertEquals(true, section20Alerts.get(0).IsActive__c, 'Section 20 alert should be deactive'); 
    }


    @isTest
    static void test_propertyAlerts_Combined_OnPropertyUpdate() {
        Date startDate = Date.today().addDays(-1);
        Date endDate = Date.today().addMonths(1);
        Date newStartDate = Date.today().addDays(1);
        Date newEndDate = Date.today().addMonths(2);
        Date yesterday = Date.today().addDays(-1);
        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );

        property.AsbestosStatus__c = PropertyDecorator.ASBESTOS_ASSUMED;
        property.AsbestosStatusStartDate__c = startDate;
        property.AsbestosStatusEndDate__c = endDate;
        property.RightToBuyOrAcquire__c = PropertyDecorator.RIGHT_TO_BUY;
        property.RighttoBuyorAcquireStartDate__c = startDate;
        property.RighttoBuyorAcquireEndDate__c = endDate;
        property.Section20ConsultationRequired__c = PropertyDecorator.SECTION_20_YES;
        property.Section20ConsultationReqStartDate__c = startDate;
        property.Section20ConsultationReqEndDate__c = endDate;
        insert property;
        
        Test.startTest();

            property.AsbestosStatus__c = PropertyDecorator.NO_ASBESTOS_ASSUMED;
            property.AsbestosStatusStartDate__c = newStartDate;
            property.AsbestosStatusEndDate__c = newEndDate;
            property.RightToBuyOrAcquire__c = PropertyDecorator.RIGHT_TO_ACQUIRE;
            property.RighttoBuyorAcquireStartDate__c = newStartDate;
            property.RighttoBuyorAcquireEndDate__c = newEndDate;
            property.Section20ConsultationRequired__c = PropertyDecorator.SECTION_20_NO;
            property.Section20ConsultationReqStartDate__c = newStartDate;
            property.Section20ConsultationReqEndDate__c = newEndDate;
            update property;
            
        Test.stopTest();
        List<Alert__c> asbetoseAssumedAlerts = UthAlert.getAll(property.Id, AlertDecorator.CATEGORY_ASBESTOS, PropertyDecorator.ASBESTOS_ASSUMED);
        System.assertEquals(1, asbetoseAssumedAlerts.size(), 'Asbestos alert should be created');
        System.assertEquals(false, asbetoseAssumedAlerts.get(0).IsActive__c, 'Asbestos alert should be active');
        System.assertEquals(startDate, asbetoseAssumedAlerts.get(0).StartDate__c, 'Asbestos alert should be active');
        System.assertEquals(yesterday, asbetoseAssumedAlerts.get(0).EndDate__c, 'Asbestos alert should be active');

        List<Alert__c> noAsbestosAssumedAlerts = UthAlert.getAll(property.Id, AlertDecorator.CATEGORY_ASBESTOS, PropertyDecorator.NO_ASBESTOS_ASSUMED);
        System.assertEquals(1, noAsbestosAssumedAlerts.size(), 'Asbestos alert should be created');
        System.assertEquals(false, noAsbestosAssumedAlerts.get(0).IsActive__c, 'Asbestos alert should be deactive');
        System.assertEquals(newStartDate, noAsbestosAssumedAlerts.get(0).StartDate__c, 'Asbestos alert should be active');
        System.assertEquals(newEndDate, noAsbestosAssumedAlerts.get(0).EndDate__c, 'Asbestos alert should be active');

        List<Alert__c> righttoBuyAlerts = UthAlert.getAll(property.Id, AlertDecorator.TYPE_PROPERTY, PropertyDecorator.RIGHT_TO_BUY);
        System.assertEquals(1, righttoBuyAlerts.size(), 'Right to Buy alert should be created');
        System.assertEquals(false, righttoBuyAlerts.get(0).IsActive__c, 'Right to Buy alert should be active');
        System.assertEquals(startDate, righttoBuyAlerts.get(0).StartDate__c, 'Right to Buy alert should be active');
        System.assertEquals(yesterday, righttoBuyAlerts.get(0).EndDate__c, 'Right to Buy alert should be active');
        
        List<Alert__c> righttoBuyAquired = UthAlert.getAll(property.Id, AlertDecorator.TYPE_PROPERTY, PropertyDecorator.RIGHT_TO_ACQUIRE);
        System.assertEquals(1, righttoBuyAquired.size(), 'Right to Buy alert should be created');
        System.assertEquals(false, righttoBuyAquired.get(0).IsActive__c, 'Right to Buy alert should be active');
        System.assertEquals(newStartDate, righttoBuyAquired.get(0).StartDate__c, 'Right to Buy alert should be active');
        System.assertEquals(newEndDate, righttoBuyAquired.get(0).EndDate__c, 'Right to Buy alert should be active');
        
        List<Alert__c> section20Alerts = UthAlert.getAll(property.Id, AlertDecorator.TYPE_PROPERTY, AlertDecorator.SUB_CATEGORY_SECTION_20);
        System.assertEquals(1, section20Alerts.size(), 'Section 20 alert should be updated');
        System.assertEquals(startDate, section20Alerts.get(0).StartDate__c, 'Section 20 alert start date should not be updated');
        System.assertEquals(yesterday, section20Alerts.get(0).EndDate__c, 'Section 20 alert end date should be updated');
        System.assertEquals(false, section20Alerts.get(0).IsActive__c, 'Section 20 alert should be deactive'); 
    }
    
}