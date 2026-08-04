@isTest
public with sharing class TenancyChangePermissionValidationTest {
    @TestSetup
    static void makeData(){
        UthFeatureSwitches.enableCaseChangesRT();
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
    static void testTenancyChangeProcessCreatePermission(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_CREATE_AT_NEW).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            System.runAs(new User(Id = currentUserId)) {
                try {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildChangesCase(contactList[0].Id);
                    caseRec.CaseType__c = CaseDecorator.CASE_TYPE_SOLE_TO_JOINT;
                    caseRec.Tenancy__c = UthTenancy.getAll()[0].Id;
                    insert caseRec; 
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Change')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(1, UthTenancyChange.getAll().size());
        Assert.areEqual(false, actualErrorMsg.contains('Change'), 'Should not throw an error when creating a Tenancy change process record');
    }

    @isTest
    static void testTenancyChangeProcessCreatePermissionError(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            try {
                TriggerBase.bypass('Case');
                List<Contact> contactList = UthContact.getAll();
                Case caseRec = UthCase.buildChangesCase(contactList[0].Id, CaseDecorator.CASE_TYPE_SOLE_TO_JOINT, UthTenancy.getAll()[0].Id);
                insert caseRec; 
                TriggerBase.clearBypass('Case');
                TenancyChange__c tenChange = new TenancyChange__c();
                tenChange.Case__c = caseRec.Id;
                insert tenChange;
            }catch (Exception exp){
                actualErrorMsg = exp.getMessage();
                if(!actualErrorMsg.contains('Change')){
                    throw new StringException(exp.getMessage());
                }
            }    
        }
        Test.stopTest();
        Assert.areEqual(true, actualErrorMsg.contains('Change'), 'Should not throw an error when creating a Tenancy change process record');
    }


   @isTest
    static void testTenancyChangeProcessUpdatePermission(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_CREATE_AT_NEW).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_UPDATE).Id;
            permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            System.runAs(new User(Id = currentUserId)) {
                try {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildChangesCase(contactList[0].Id, CaseDecorator.CASE_TYPE_SOLE_TO_JOINT, UthTenancy.getAll()[0].Id);
                    insert caseRec; 
                    TenancyChange__c tenchange = [SELECT Id FROM TenancyChange__c][0];
                    tenchange.FurtherInformation__c = 'test';
                    update tenchange;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Change')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(1, UthTenancyChange.getAll().size());
        Assert.areEqual(false, actualErrorMsg.contains('Change'), 'Should not throw an error when creating a Tenancy change process record');
    }

    @isTest
    static void testTenancyChangeProcessPermissionUpdateError(){
        String actualErrorMsg = '';
       
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
                try {
                    TriggerBase.bypass('Case');
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildChangesCase(contactList[0].Id, CaseDecorator.CASE_TYPE_SOLE_TO_JOINT, UthTenancy.getAll()[0].Id);
                    insert caseRec; 
                    TriggerBase.clearBypass('Case');
                    TriggerBase.bypass('TenancyChange__c');
                    TenancyChange__c tchange = new TenancyChange__c(Case__c = caseRec.Id);
                    insert tchange;
                    TriggerBase.clearBypass('TenancyChange__c');
                    tchange.FurtherInformation__c = 'Add me';
                    update tchange;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Change')){
                        throw new StringException(exp.getMessage());
                    }
                }     
            Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains('Change'), 'Should  throw an error when updating a Tenancy Change process record');
    }
}