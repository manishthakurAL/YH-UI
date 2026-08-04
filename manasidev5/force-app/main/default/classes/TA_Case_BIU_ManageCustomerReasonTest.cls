@isTest
public with sharing class TA_Case_BIU_ManageCustomerReasonTest {
   @TestSetup
    static void makeData(){
        UthFeatureSwitches.enableAllRT();

        TriggerBase.bypass('Account');
        Account account1 = UthAccount.buildPersonAccount();
        insert account1;
        YH_Property__c aproperty = uthProperty.buildPropertyWithDesignAssumptions(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE,
            PropertyDecorator.AUTHCODE_E08000038,
            PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
            PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE
            );
        insert aproperty;
    
        YH_Tenancy__c atenancy = UthTenancy.build(aproperty.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        insert atenancy;
        TriggerBase.clearBypass('Account'); 
    }

    @isTest
    static void testPermissionsProcessCreatePermission(){
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Permissions_BI_CheckPermission.class.getName());
            System.runAs(new User(Id = currentUserId)) {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildPermissionCaseWithCaseType(contactList[0].Id,UthTenancy.getAll()[0].Id, CaseDecorator.CASE_TYPE_PERMISSION_DISABLED_PARKING);
                    insert caseRec;                
            }
            MetadataTriggerHandler.clearbypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearbypass(TA_Permissions_BI_CheckPermission.class.getName());     
        }
        Test.stopTest();
        Case caseRec = UthCase.getAll()[0];
        Assert.isNotNull(caseRec.CustomerSharingReasons__c, 'Customer sharing reason should be populated');
        Assert.areEqual(true, caseRec.CustomerSharingReasons__c.contains('Tenant'), 'Customer sharing reason should be populated');

    }

    @isTest
    static void testPermissionProcessUpdatePermission(){
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Permissions_BI_CheckPermission.class.getName());   
            MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Permissions_BU_CheckPermission.class.getName());                
            System.runAs(new User(Id = currentUserId)) {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildPermissionCase(contactList[0].Id,UthTenancy.getAll()[0].Id);
                    insert caseRec; 
                    Assert.isNull(UthCase.getAll()[0].CustomerSharingReasons__c, 'Customer sharing reason should be null if case type is not populated');
                    caseRec.CaseType__c =  CaseDecorator.CASE_TYPE_PERMISSION_DISABLED_PARKING;
                    update caseRec;
            }
            MetadataTriggerHandler.clearbypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearbypass(TA_Permissions_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearbypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearbypass(TA_Permissions_BU_CheckPermission.class.getName());        
        }
        Test.stopTest();
        Case caseRec = UthCase.getAll()[0];
        Assert.areEqual(true, caseRec.CustomerSharingReasons__c.contains('Tenant'), 'Customer sharing reason should be populated');
    }

    @isTest
    static void testPermissionsProcessCreatePermissionBulk(){
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Permissions_BI_CheckPermission.class.getName());
                    List<Contact> contactList = UthContact.getAll();
                    List<Case> cases = new List<Case>();
                    Case caseRec = UthCase.buildPermissionCaseWithCaseType(contactList[0].Id,UthTenancy.getAll()[0].Id, CaseDecorator.CASE_TYPE_PERMISSION_DISABLED_PARKING);
                    cases.add(caseRec);
                    Case caseRec1 = UthCase.buildPermissionCaseWithCaseType(contactList[0].Id,UthTenancy.getAll()[0].Id, CaseDecorator.CASE_TYPE_PERMISSION_FOR_CARAVAN_MOTORHOME_BOAT);
                    cases.add(caseRec1);    
                    Case caseRec2 = UthCase.buildPermissionCaseWithCaseType(contactList[0].Id,UthTenancy.getAll()[0].Id, CaseDecorator.CASE_TYPE_PERMISSION_FOR_MOBILITY_SCOOTER);
                    cases.add(caseRec2);
                    insert cases;    
            MetadataTriggerHandler.clearbypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearbypass(TA_Permissions_BI_CheckPermission.class.getName());     
        }
        Test.stopTest();
        for(Case caseRec : UthCase.getAll()){
            Assert.areEqual(true, caseRec.CustomerSharingReasons__c.contains('Tenant'), 'Customer sharing reason should be populated');
        }
    }

    @isTest
    static void testPermissionProcessUpdatePermissionChangeinCaseType(){
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Permissions_BI_CheckPermission.class.getName());   
            MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Permissions_BU_CheckPermission.class.getName());                
            System.runAs(new User(Id = currentUserId)) {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildPermissionCaseWithCaseType(contactList[0].Id,UthTenancy.getAll()[0].Id, CaseDecorator.CASE_TYPE_PERMISSION_FOR_MOBILITY_SCOOTER);
                    insert caseRec; 
                    caseRec.CaseType__c =  CaseDecorator.CASE_TYPE_PERMISSION_DISABLED_PARKING;
                    update caseRec;
            }
            MetadataTriggerHandler.clearbypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearbypass(TA_Permissions_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearbypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearbypass(TA_Permissions_BU_CheckPermission.class.getName());        
        }
        Test.stopTest();
        Case caseRec = UthCase.getAll()[0];
        Assert.areEqual(true, caseRec.CustomerSharingReasons__c.contains('Tenant'), 'Customer sharing reason should be populated');
    }

    @isTest
    static void testGeneralEnquiryCaseSharing(){
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);               
           
            System.runAs(new User(Id = currentUserId)) {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildGeneralEnquiryCase(contactList[0].Id,UthTenancy.getAll()[0].Id);
                    caseRec.CaseType__c =  CaseDecorator.CASE_TYPE_GAS_REPAIR;
                    insert caseRec; 
            }       
        }
              
        Test.stopTest();
        Case caseRec = UthCase.getAll()[0];
        Assert.areEqual(null, caseRec.CustomerSharingReasons__c, 'Customer sharing reason should not be populated');
    }

    @isTest
    static void testSafeguardingCaseSharing(){
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_SAFEGUARDING_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_PS_CAN_UPDATE_SAFEGUARDING_CASE).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
           
            System.runAs(new User(Id = currentUserId)) {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildSafeguardingCase(contactList[0].Id);
                    caseRec.CaseType__c =  CaseDecorator.CASE_TYPE_GAS_REPAIR;
                    insert caseRec; 
            }       
        }
              
        Test.stopTest();
        Case caseRec = UthCase.getAll()[0];
        Assert.isNull(caseRec.CustomerSharingReasons__c, 'Customer sharing reason should not be populated');
    }

    /*  Test Methods implemented as part of US-34683.
     *  Commented as part of US-37607
     * 	Reason for Commenting : This code is intentially commented out as future enhancements may require Breach and ASB Cases to be shared.
    @isTest
    static void testBreachAndASBCaseNotReadyForSharing(){
        Exception ex;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_CREATE_AT_NEW).Id;
            Id permissionSetIdUpdate = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_UPDATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_SAFEGUARDING_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            PermissionSetAssignment permissionSetAssignmentupdate = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetIdUpdate);
            if (permissionSetAssignmentupdate == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetIdUpdate);
            }

            Contact contact = UthContact.getAll().get(0);
        
            System.runAs(new User(Id = currentUserId)){
                Case breachCaseRecord = UthCase.buildBreachAndASBCase(contact.Id);
                insert breachCaseRecord;

                Test.startTest();
                    try {
                        Update breachCaseRecord;
                    }catch(Exception exp){
                        Assert.isTrue(false, 'Exception occured');
                        ex = exp;
                    }
                Test.stopTest();
            }
        }
        Case caseRec = UthCase.getAll()[0];
        system.debug('YH LOGS caseRec.CustomerSharingReasons__c = ' + caseRec.CustomerSharingReasons__c);
        Assert.isNull(caseRec.CustomerSharingReasons__c, 'Customer sharing reason should not be populated');
    }

    @isTest
    static void testBreachAndASBCaseReadyForSharing(){
        Exception ex;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_CREATE_AT_NEW).Id;
            Id permissionSetIdUpdate = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_UPDATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_SAFEGUARDING_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            PermissionSetAssignment permissionSetAssignmentupdate = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetIdUpdate);
            if (permissionSetAssignmentupdate == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetIdUpdate);
            }

            Contact contact = UthContact.getAll().get(0);
        
            System.runAs(new User(Id = currentUserId)) {
                Case breachCaseRecord = UthCase.buildBreachAndASBCase(contact.Id);
                insert breachCaseRecord;

                Test.startTest();
                    try {
                        breachCaseRecord.CaseReadyForSharing__c = CaseDecorator.RECORD_TYPE_BREACH;
                        Update breachCaseRecord;
                    }catch(Exception exp){
                        Assert.isTrue(false, 'Exception occured');
                        ex = exp;
                    }
                Test.stopTest();
            }
        }
        Case caseRec = UthCase.getAll()[0];
        Assert.areEqual(true, caseRec.CustomerSharingReasons__c.contains('Accused Party'), 'Customer sharing reason should be populated');
    }
	*/
    @isTest
    static void testTenancyCaseDecantTypeTemporarySharing(){
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id; 
            Id permissionSetIdUpdate = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_UPDATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }

            PermissionSetAssignment permissionSetAssignmentUpdate = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetIdUpdate);
            if (permissionSetAssignmentUpdate == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetIdUpdate);
            }
           
            System.runAs(new User(Id = currentUserId)) {
                List<Contact> contactList = UthContact.getAll();
                Case caseRec = UthCase.buildTenancyCaseWithCaseType(contactList[0].Id, CaseDecorator.CASETYPE_DECANT);
                insert caseRec; 

                caseRec.DecantType__c = CaseDecorator.TENANCY_DECANT_CASE_TYPE_TEMPORARY;
                update caseRec; 
            }       
        }
              
        Test.stopTest();
        Case caseRec = UthCase.getAll()[0];
        Assert.areEqual(true, caseRec.CustomerSharingReasons__c.contains('Tenant'), 'Customer sharing reason should be populated');
    }

    @isTest
    static void testTenancyCaseDecantTypePermenentSharing(){
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
           
            System.runAs(new User(Id = currentUserId)) {
                List<Contact> contactList = UthContact.getAll();
                Case caseRec = UthCase.buildTenancyCaseWithCaseType(contactList[0].Id, CaseDecorator.CASETYPE_DECANT);
                caseRec.DecantType__c = CaseDecorator.TENANCY_DECANT_CASE_TYPE_PERMANENT;
                insert caseRec; 
            }       
        }
              
        Test.stopTest();
        Case caseRec = UthCase.getAll()[0];
        Assert.isNull(caseRec.CustomerSharingReasons__c, 'Customer sharing reason should not be populated');
    }

    @isTest
    static void testBulkSharing(){
        Exception ex;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id asbPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_CREATE_AT_NEW).Id;
            Id asbPermissionSetIdUpdate = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_UPDATE_AT_NEW).Id;
            Id tenancyPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id;
            Id tenancyPermissionSetIdUpdate = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_UPDATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_SAFEGUARDING_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        
            PermissionSetAssignment asbPermissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, asbPermissionSetId);
            if (asbPermissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, asbPermissionSetId);
            }
            PermissionSetAssignment asbPermissionSetAssignmentupdate = UthPermissionSet.getPermissionSetAssignment(currentUserId, asbPermissionSetIdUpdate);
            if (asbPermissionSetAssignmentupdate == null) {
                UthPermissionSet.setPermissionSet(currentUserId, asbPermissionSetIdUpdate);
            }

            PermissionSetAssignment tenancypermissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, tenancyPermissionSetId);
            if (tenancypermissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, tenancyPermissionSetId);
            }

            PermissionSetAssignment tenancypermissionSetAssignmentUpdate = UthPermissionSet.getPermissionSetAssignment(currentUserId, tenancyPermissionSetIdUpdate);
            if (tenancypermissionSetAssignmentUpdate == null) {
                UthPermissionSet.setPermissionSet(currentUserId, tenancyPermissionSetIdUpdate);
            }

            Contact contact = UthContact.getAll().get(0);
            YH_Tenancy__c tenancy = UthTenancy.getAll()[0];
        
            System.runAs(new User(Id = currentUserId)) {
                List<Case> casesForInsert = new List<Case>();
                Case geCase = UthCase.buildGeneralEnquiryCase(contact.Id, tenancy.Id);
                geCase.CaseType__c =  CaseDecorator.CASE_TYPE_GAS_REPAIR;
                casesForInsert.add(geCase);

                Case decPermCase = UthCase.buildTenancyCaseWithCaseType(contact.Id, CaseDecorator.CASETYPE_DECANT);
                insert decPermCase;
                decPermCase.DecantType__c = CaseDecorator.TENANCY_DECANT_CASE_TYPE_PERMANENT;
                casesForInsert.add(decPermCase);

                Case decTempCase = UthCase.buildTenancyCaseWithCaseType(contact.Id, CaseDecorator.CASETYPE_DECANT);
                insert decTempCase;
                decTempCase.DecantType__c = CaseDecorator.TENANCY_DECANT_CASE_TYPE_TEMPORARY;
                casesForInsert.add(decTempCase);
                
                Case breachCaseRecord = UthCase.buildBreachAndASBCase(contact.Id);
                insert breachCaseRecord;

                Test.startTest();
                    try {
                        breachCaseRecord.CaseReadyForSharing__c = CaseDecorator.RECORD_TYPE_BREACH;
                        casesForInsert.add(breachCaseRecord);
                        upsert casesForInsert;
                    }catch(Exception exp){
                        Assert.isTrue(false, 'Exception occured');
                        ex = exp;
                    }
                Test.stopTest();
            }
        }
        List<Case> caseRec = UthCase.getAll();
        Assert.areEqual(4, caseRec.size(), '3 cases should be created');
        for(Case caseRecord : caseRec){
            /*if(caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_BREACH_AND_ANTISOCIAL){
                Assert.areEqual(true, caseRecord.CustomerSharingReasons__c.contains('Accused Party'), 'Customer sharing reason should be populated');
            } else */
            if(caseRecord.CaseType__c == CaseDecorator.CASETYPE_DECANT){
                if(caseRecord.DecantType__c == CaseDecorator.TENANCY_DECANT_CASE_TYPE_PERMANENT){
                    Assert.isNull(caseRecord.CustomerSharingReasons__c, 'Customer sharing reason should not be populated');
                }else if(caseRecord.DecantType__c == CaseDecorator.TENANCY_DECANT_CASE_TYPE_TEMPORARY){
                    Assert.areEqual(true, caseRecord.CustomerSharingReasons__c.contains('Tenant'), 'Customer sharing reason should be populated');
                }
            } else if(caseRecord.CaseType__c == CaseDecorator.CASE_TYPE_GAS_REPAIR){
                Assert.areEqual(null, caseRecord.CustomerSharingReasons__c, 'Customer sharing reason should not be populated');
            }
        }
    }

     @isTest
    static void testGeneralEnquiryWithOriginCustomerPortalCaseSharing(){
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            List<Contact> contactList = UthContact.getAll();
            Case caseRec = UthCase.buildGeneralEnquiryOriginPortalCase(contactList[0].Id,UthTenancy.getAll()[0].Id);
            caseRec.CaseType__c =  CaseDecorator.CASE_TYPE_GAS_REPAIR;
            insert caseRec;      
        }
              
        Test.stopTest();
        Case caseRec = UthCase.getAll()[0];
        Assert.areEqual(true, caseRec.CustomerSharingReasons__c.contains('Tenant'), 'Customer sharing reason should be populated');
    }

    @isTest
    static void testGeneralEnquiryUpdateOriginCustomerPortalCaseSharing(){  
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.buildUser(roleId,adminProfileId,'fname1','lname1');
        insert adminUser;

        System.runAs(adminUser){
            List<Contact> contactList = UthContact.getAll();
            Case caseRec = UthCase.buildGeneralEnquiryCase(contactList[0].Id,UthTenancy.getAll()[0].Id);
            caseRec.CaseType__c =  CaseDecorator.CASE_TYPE_GAS_REPAIR;
            insert caseRec; 

            Test.startTest();
                caseRec.Origin = CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL;
                update caseRec;
            Test.stopTest();
        }

        Case caseRec = UthCase.getAll()[0];
        Assert.areEqual(true, caseRec.CustomerSharingReasons__c.contains('Tenant'), 'Customer sharing reason should be populated');
    }

    @isTest
    static void testGeneralEnquiryUpdateCaseTypeCustomerPortalCaseSharing(){  
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.buildUser(roleId,adminProfileId,'fname1','lname1');
        insert adminUser;

        System.runAs(adminUser){
            List<Contact> contactList = UthContact.getAll();
            Case caseRec = UthCase.buildGeneralEnquiryCase(contactList[0].Id,UthTenancy.getAll()[0].Id);
            caseRec.Origin = CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL;
            insert caseRec; 

            Test.startTest();
                caseRec.CaseType__c =  CaseDecorator.CASE_TYPE_GAS_REPAIR;
                update caseRec;
            Test.stopTest();
        }

        Case caseRec = UthCase.getAll()[0];
        Assert.areEqual(true, caseRec.CustomerSharingReasons__c.contains('Tenant'), 'Customer sharing reason should be populated');
    }
}