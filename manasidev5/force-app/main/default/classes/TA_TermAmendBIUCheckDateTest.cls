@isTest
public with sharing class TA_TermAmendBIUCheckDateTest {
    @TestSetup
    static void makeData(){
        UthFeatureSwitches.enableCaseTerminationRT(); 
        UthFeatureSwitches.enableCaseLettingRT();
        TriggerBase.bypass('Account');
        Account account1 = UthAccount.buildPersonAccount();
        insert account1;
        TriggerBase.clearBypass('Account');    
        
        YH_Property__c aproperty = uthProperty.buildPropertyWithDesignAssumptions(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE,
            PropertyDecorator.AUTHCODE_E08000038,
            PropertyDecorator.RENT_TYPE_SOCIAL_RENT,
            PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE
            );
        insert aproperty;

        YH_Tenancy__c tenancy = UthTenancy.build(aproperty.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        tenancy.StartDate__c = System.today().addYears(-2);
        tenancy.TenancyEndDate__c = System.today().addMonths(-1);
        insert tenancy;
    }
    
    @isTest
    static void testBeforeInsertChangeDateForTermAmendment(){
        YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
        Boolean errorThown = false;
        List<Contact> contactList = UthContact.getAll();
        Case caseRec = UthCase.buildTerminationCase(contactList[0].Id, UthTenancy.getAll()[0].Id);
        Date terminationNoticeReceivedDatePlus7Days = System.today() + 7;
        integer remainder = Math.MOD((Date.newInstance(1900,1,7)).daysbetween(terminationNoticeReceivedDatePlus7Days), 7);
        Integer deltaDays = remainder == 0 ? 0 : 7 - remainder;
        TerminationAmendment__c ta = UthTerminationAmendment.buildChangeTenancyEndDate(caseRec.Id, contactList[0].Id); 
        ta.ReasonTenancyEndDateChanged__c = TenancyDecorator.TRANSFER_TENANCY_END_DATE_REASON;
        ta.AmendedTenancyEndDate__c = terminationNoticeReceivedDatePlus7Days.adddays(deltaDays);
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
        Test.startTest(); 
        System.runAs(new User(Id = UserInfo.getUserId())) {
            try {
                insert caseRec; 
                ta.Case__c = caseRec.Id;
                insert ta; 
                MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
                MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
                MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
                MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
                MetadataTriggerHandler.bypass(TA_TerminationAmmend_BU_CheckPermission.class.getName());

                ta.Decision__c = 'Approved'; 
                update ta; 
            }catch (Exception exp){
                    errorThown = true; 
            }    
            MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BU_CheckPermission.class.getName());
        }
        Test.stopTest();
        Assert.areEqual(false, errorThown, 'An exception was incorrectly thrown');
        Date endDate = UthTenancy.getTenancyById(caseRec.Tenancy__c).TenancyEndDate__c;
        Assert.areEqual(UthTerminationAmendment.getAll()[0].AmendedTenancyEndDate__c, endDate, 'The tenancy end date should be amended');
    }

    @isTest
    static void testBeforeInsertChangeDateForTermAmendmentFailure(){
        YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
        Boolean errorThown = false;
        List<Contact> contactList = UthContact.getAll();
        Case caseRec = UthCase.buildTerminationCase(contactList[0].Id, UthTenancy.getAll()[0].Id);
        caseRec.TerminationNoticeReceived__c = System.today();
        Date newTenancyEndDate = System.today().addMonths(-1)+1;
        TerminationAmendment__c ta = UthTerminationAmendment.buildChangeTenancyEndDate(caseRec.Id, contactList[0].Id); 
        ta.ReasonTenancyEndDateChanged__c = TenancyDecorator.TRANSFER_TENANCY_END_DATE_REASON;
        ta.AmendedTenancyEndDate__c = newTenancyEndDate;
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
        Test.startTest(); 
        System.runAs(new User(Id = UserInfo.getUserId())) {
            try {
                insert caseRec; 
                ta.Case__c = caseRec.Id;
                insert ta; 
                MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
                MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
                MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
                MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
                MetadataTriggerHandler.bypass(TA_TerminationAmmend_BU_CheckPermission.class.getName());
            }catch (Exception exp){
                    errorThown = true; 
            }    
            MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BU_CheckPermission.class.getName());
        }
        Test.stopTest();
        Assert.areEqual(true, errorThown, 'An exception was correctly thrown as amended tenancy end date cannot be less than termination notice recieved date');
        Assert.areEqual(UthTerminationAmendment.getAll().size(), 0, 'No termination amendment is created');
    }
}