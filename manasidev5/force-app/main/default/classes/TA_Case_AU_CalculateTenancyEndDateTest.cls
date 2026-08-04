@isTest
public with sharing class TA_Case_AU_CalculateTenancyEndDateTest {
    @TestSetup
    static void makeData(){
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        UthFeatureSwitches.enableCaseTerminationRT();
        UthFeatureSwitches.enableCaseLettingRT();
        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact; 

        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
        PropertyDecorator.RENT_TYPE_SOCIAL_RENT,
        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10; 
        insert atenancy;
    }

    @isTest
    static void test_calculateforsocialrentsuccessInsert(){
       
        Test.startTest();
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
            List<Contact> contactList = UthContact.getAll();
            Case caseRec = UthCase.buildTerminationCase(contactList[0].Id, UthTenancy.getAll()[0].Id);
            caseRec.TerminationNoticeReceived__c =System.today() + 7;
        	caseRec.PrimaryReasonForLeaving__c = CaseDecorator.PRIMARY_REASON_FOR_LEAVING_NEEDSMALLHOME;
            caseRec.Origin = CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL;
            insert caseRec;
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
        Test.stopTest();
        Assert.isNotNull(UthTenancy.getAll()[0].TenancyEndDate__c);    
        Assert.areEqual(UthTenancy.getAll()[0].PrimaryReasonForLeaving__c, caseRec.PrimaryReasonForLeaving__c);    

    }

    @isTest
    static void test_calculateforsocialrentsuccess(){
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
        List<Contact> contactList = UthContact.getAll();
        Case caseRec = UthCase.buildTerminationCase(contactList[0].Id, UthTenancy.getAll()[0].Id);
        insert caseRec;
        Date terminationNoticeReceivedDatePlus7Days = System.today() + 7;
        MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
        Test.startTest();
            MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Termination_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_InspectionCheck_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_TerminationAmmend_BU_CheckPermission.class.getName());
            caseRec.TerminationNoticeReceived__c = System.today();
        	caseRec.PrimaryReasonForLeaving__c = CaseDecorator.PRIMARY_REASON_FOR_LEAVING_NEEDSMALLHOME;
            update caseRec;
            MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Termination_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BU_CheckPermission.class.getName());  
        Test.stopTest();
        Assert.isNotNull(UthTenancy.getAll()[0].TenancyEndDate__c);    
        Assert.areEqual(UthTenancy.getAll()[0].PrimaryReasonForLeaving__c, caseRec.PrimaryReasonForLeaving__c);    

    }

    @isTest
    static void test_calculateformsocialrentsuccessClosedWithConsent(){
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
        List<Contact> contactList = UthContact.getAll();
        Case caseRec = UthCase.buildTerminationCase(contactList[0].Id, UthTenancy.getAll()[0].Id);
        caseRec.CaseType__c = CaseDecorator.TYPE_TERMINATION;
        insert caseRec;
        Date terminationNoticeReceivedDatePlus7Days = System.today() + 7;
        MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
        Test.startTest();
            MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Termination_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_InspectionCheck_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_TerminationAmmend_BU_CheckPermission.class.getName());
            caseRec.TerminationNoticeReceived__c = System.today();
            caseRec.Status = CaseDecorator.STATUS_COMPLETE_CASE;
            caseRec.IsFullConsentForTerminationNotGive__c = true;
            caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_CONSENT_NOT_GIVE;
            update caseRec;
            MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Termination_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BU_CheckPermission.class.getName()); 
        Test.stopTest();
        Assert.isNull(UthTenancy.getAll()[0].TenancyEndDate__c);    
    }

    @isTest
    static void test_terminationguestportalsuccessInsert(){
       
        Test.startTest();
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
            List<Contact> contactList = UthContact.getAll();
            Case caseRec = UthCase.buildTerminationGuestPortalCase();
            insert caseRec;
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
        Test.stopTest();
        Assert.isNull(UthCase.getAll()[0].Tenancy__c,'Tenancy should be null');  
        Assert.isNull(UthTenancy.getAll()[0].TenancyEndDate__c, 'TenancyEndDate should be null');
    }

    @isTest
    static void test_terminationguestportalupdatetenancyoncase(){
       
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_InspectionCheck_BU_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
        List<Contact> contactList = UthContact.getAll();
        Case caseRec = UthCase.buildTerminationGuestPortalCase();
        insert caseRec;

        Test.startTest();

            YH_Tenancy__c tenancy = UthTenancy.getAll()[0];
            caseRec.Tenancy__c = tenancy.Id;
            update caseRec;

            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
        Test.stopTest();
        Assert.isNotNull(UthCase.getAll()[0].Tenancy__c, 'Tenancy should not be null');  
        Assert.isNotNull(UthTenancy.getAll()[0].TenancyEndDate__c, 'TenancyEndDate should not be null');
    }

    @isTest
    static void test_terminationguestportalvalidations(){
        
        Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TERMINATION_CASE_CREATE).Id;
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TERMINATION_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        String exceptionMessage;
        List<Contact> contactList = UthContact.getAll();
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            Case caseRec = UthCase.buildTerminationGuestPortalCase();
            insert caseRec;
    
            YH_Tenancy__c tenancy = UthTenancy.getAll()[0];
            caseRec.Tenancy__c = tenancy.Id;
            update caseRec;
                try{
                    caseRec.Tenancy__c = null;
                    update caseRec;
                } catch(exception e){
                    exceptionMessage = e.getMessage();
                }
        }
        Test.stopTest();
        Assert.isNotNull(exceptionMessage, 'Exception should not be null');  
        Assert.isTrue(exceptionMessage.contains('Once a Tenancy is linked to a Case, it cannot be changed.'), 'Exception message should be : Once a Tenancy is linked to a Case, it cannot be changed.');
        Assert.isNotNull(UthCase.getAll()[0].Tenancy__c, 'Tenancy should not be null');  
        Assert.isNotNull(UthTenancy.getAll()[0].TenancyEndDate__c, 'TenancyEndDate should not be null');
    }

    @isTest
    static void test_terminationguestportaltenancyWithEndDatevalidations(){
        List<Contact> contactList = UthContact.getAll();
        Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TERMINATION_CASE_CREATE).Id;
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TERMINATION_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        String exceptionMessage;
        Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                Case caseRec = UthCase.buildTerminationGuestPortalCase();
                insert caseRec;

                YH_Tenancy__c tenancy = UthTenancy.getAll()[0];
                caseRec.Tenancy__c = tenancy.Id;
                update caseRec;
                
                try{
                    Case caseRecNew = UthCase.buildTerminationGuestPortalCase();
                    insert caseRecNew;
                    caseRecNew.Tenancy__c = tenancy.Id;
                    update caseRecNew;
                } catch(exception e){
                    exceptionMessage = e.getMessage();
                }
            }
        Test.stopTest();
        Assert.isNotNull(exceptionMessage, 'Exception should not be null');  
        Assert.isTrue(exceptionMessage.contains('Tenancy cannot be linked to a case because Tenancy End Date is already populated on the Tenancy.'), 'Exception message should be : Tenancy cannot be linked to a case because Tenancy End Date is already populated on the Tenancy.');
        Assert.isNotNull(UthCase.getAll()[0].Tenancy__c, 'Tenancy should not be null');  
        Assert.isNotNull(UthTenancy.getAll()[0].TenancyEndDate__c, 'TenancyEndDate should not be null');
    }
    
    @isTest
    static void test_terminationguestportalOnInsert(){
        
        Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TERMINATION_CASE_CREATE).Id;
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TERMINATION_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        String exceptionMessage;
        List<Contact> contactList = UthContact.getAll();
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            YH_Tenancy__c tenancy = UthTenancy.getAll()[0];
            Case caseRec = UthCase.buildTerminationGuestPortalCase();
            caseRec.Tenancy__c = tenancy.Id;
            insert caseRec;
        }
        Test.stopTest();
        Assert.isNotNull(UthTenancy.getAll()[0].TenancyEndDate__c, 'TenancyEndDate should not be null');
    }
}