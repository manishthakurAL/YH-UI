@isTest
public with sharing class PermissionProcessPermissionValidTest {
    @TestSetup
    static void makeData(){
        UthFeatureSwitches.enableCasePermissionRT();
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
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PERMISSION_CASE_CREATE_AT_NEW).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            System.runAs(new User(Id = currentUserId)) {
                try {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildPermissionCase(contactList[0].Id,UthTenancy.getAll()[0].Id);
                    insert caseRec; 
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Permission')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(1, UthPermissions.getAll().size());
        Assert.areEqual(false, actualErrorMsg.contains('Permission'), 'Should not throw an error when creating a Permission process record');
    }

    @isTest
    static void testPermissionsProcessCreatePermissionError(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            try {
                TriggerBase.bypass('Case');
                List<Contact> contactList = UthContact.getAll();
                Case caseRec = UthCase.buildPermissionCase(contactList[0].Id,UthTenancy.getAll()[0].Id);
                insert caseRec; 
                TriggerBase.clearBypass('Case');
                Permissions__c perm = new Permissions__c();
                perm.Case__c = caseRec.Id;
                insert perm;
            }catch (Exception exp){
                actualErrorMsg = exp.getMessage();
                if(!actualErrorMsg.contains('Permission')){
                    throw new StringException(exp.getMessage());
                }
            }    
        }
        Test.stopTest();
        Assert.areEqual(true, actualErrorMsg.contains('Permission'), 'Should  throw an error when creating a Permission process record');
    }

    @isTest
    static void testPermissionProcessUpdatePermission(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PERMISSION_CASE_UPDATE).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PERMISSION_CASE_CREATE_AT_NEW).Id;
            permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            System.runAs(new User(Id = currentUserId)) {
                try {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildPermissionCase(contactList[0].Id,UthTenancy.getAll()[0].Id);
                    insert caseRec; 
                    Permissions__c apermission = [SELECT Id FROM Permissions__c ][0];
                    apermission.AdditionalInformation__c = 'test';
                    update apermission;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Permission')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(1, UthPermissions.getAll().size());
        Assert.areEqual(false, actualErrorMsg.contains('Permission'), 'Should not throw an error when creating a Permissions process record');
    }

    @isTest
    static void testPermissionProcessPermissionUpdateError(){
        String actualErrorMsg = '';
       
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
                try {
                    TriggerBase.bypass('Case');
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildPermissionCase(contactList[0].Id,UthTenancy.getAll()[0].Id);
                    insert caseRec; 
                    TriggerBase.clearBypass('Case');
                    TriggerBase.bypass('Permissions__c');
                    Permissions__c apermission = new Permissions__c(Case__c = caseRec.Id,
                        Contact__c = contactList[0].Id, Tenancy__c = UthTenancy.getAll()[0].Id);
                    insert apermission;
                    TriggerBase.clearBypass('Permissions__c');                  
                    apermission.AdditionalInformation__c = 'Add me';
                    update apermission;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Permission')){
                        throw new StringException(exp.getMessage());
                    }
                }     
            Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains('Permission'), 'Should  throw an error when updating a Tenancy Incident process record');
    }
}