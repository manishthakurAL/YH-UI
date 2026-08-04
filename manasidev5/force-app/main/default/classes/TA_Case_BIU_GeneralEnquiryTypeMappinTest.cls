@isTest
private class TA_Case_BIU_GeneralEnquiryTypeMappinTest {

    @TestSetup
    static void makeData(){
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName()); 

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact; 

        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        insert tenancy;

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        
    }

    @isTest
    static void internalToExternalAndViceVersaMapping() { 
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        UthFeatureSwitches.EnableCaseGeneralEnquiryRT();
        list<Contact> conList = UthContact.getAll();
        list<YH_Tenancy__c> tenancyList = UthTenancy.getAll();

        Case caseRec1 = UthCase.buildGeneralEnquiryCase(conList[0].Id, tenancyList[0].Id);
        caseRec1.CustomerCaseType__c = CaseDecorator.CASE_CUSTOMER_TYPE_OUTSTANDING_REPAIR;
        caseRec1.CustomerEnquiryType__c = CaseDecorator.CASE_CUSTOMER_INQUIRY_CHANGE_TIME;
        caseRec1.Origin = CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL;        
        
        Case caseRec2 = UthCase.buildGeneralEnquiryCase(conList[0].Id, tenancyList[0].Id);
        caseRec2.CaseType__c = CaseDecorator.CASE_TYPE_BUILDING_ELECTRICAL;
        caseRec2.EnquiryType__c = CaseDecorator.CASE_INQUIRY_CANCELLED;
        caseRec2.Origin = CaseDecorator.ORIGIN_SYSTEM;
        List<Case> caseList = new List<Case>{caseRec1, caseRec2};

        Test.startTest();
        insert caseList;
        Test.stopTest();

        for(Case cRec : UthCase.getAll()){
            if(cRec.Origin == CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL) {
                System.assertEquals(CaseDecorator.CASE_TYPE_BUILDING_ELECTRICAL, cRec.CaseType__c, 'Case Type is not set correctly');
                System.assertEquals(CaseDecorator.CASE_INQUIRY_APPOINTMENT_AMENDMENT, cRec.EnquiryType__c, 'Enquiry Type is not set correctly');
            }else if(cRec.Origin == CaseDecorator.ORIGIN_SYSTEM){
                System.assertEquals(CaseDecorator.CASE_CUSTOMER_TYPE_OUTSTANDING_REPAIR, cRec.CustomerCaseType__c, 'Case Type is not set correctly');
                System.assertEquals(CaseDecorator.CASE_CUSTOMER_INQUIRY_NO_LONGER_NEED, cRec.CustomerEnquiryType__c, 'Case Type is not set correctly');
            }
        }



    }
    
}