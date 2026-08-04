@isTest
public with sharing class TenancyIncidentPermissionValidationTest {
    @TestSetup
    static void makeData(){
        UthFeatureSwitches.enableCasePlaceRT();
        UthFeatureSwitches.enableCaseTenancyRT();
        TriggerBase.bypass('Account');
        Account account1 = UthAccount.buildPersonAccount();
        insert account1;
        TriggerBase.clearBypass('Account'); 
    }

    @isTest
    static void testTenancyIncidentProcessCreatePermission(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_CREATE_AT_NEW).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            System.runAs(new User(Id = currentUserId)) {
                try {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildPlaceCase(contactList[0].Id);
                    caseRec.CaseType__c = CaseDecorator.CASE_TYPE_ABANDONED_VEHICLES;
                    insert caseRec; 
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Place')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(1, UthTenancyIncident.getAll().size());
        Assert.areEqual(false, actualErrorMsg.contains('Place'), 'Should not throw an error when creating a Tenancy Incident process record');
    }

    @isTest
    static void testTenancyIncidentProcessCreatePermissionError(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            try {
                TriggerBase.bypass('Case');
                List<Contact> contactList = UthContact.getAll();
                Case caseRec = UthCase.buildPlaceCase(contactList[0].Id);
                caseRec.CaseType__c = CaseDecorator.CASE_TYPE_ABANDONED_VEHICLES;
                insert caseRec; 
                TriggerBase.clearBypass('Case');
                TenancyIncident__c tenInc = new TenancyIncident__c();
                tenInc.Case__c = caseRec.Id;
                insert tenInc;
            }catch (Exception exp){
                actualErrorMsg = exp.getMessage();
                if(!actualErrorMsg.contains('Place')){
                    throw new StringException(exp.getMessage());
                }
            }    
        }
        Test.stopTest();
        Assert.areEqual(true, actualErrorMsg.contains('Place'), 'Should  throw an error when creating a Tenancy Incident process record');
    }

    @isTest
    static void testTenancyIncidentProcessUpdatePermission(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_UPDATE_AT_NEW).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id;
            permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            System.runAs(new User(Id = currentUserId)) {
                try {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildTenancyCase(contactList[0].Id);
                    caseRec.CaseType__C = CaseDecorator.CASE_TYPE_ABANDONED_GOODS;
                    insert caseRec; 
                    TenancyIncident__c tenIncident = [SELECT Id FROM TenancyIncident__c][0];
                    tenIncident.AdditionalInformation__c = 'test';
                    update tenIncident;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Tenancy')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(1, UthTenancyIncident.getAll().size());
        Assert.areEqual(false, actualErrorMsg.contains('Tenancy'), 'Should not throw an error when creating a Tenancy Incident process record');
    }

    @isTest
    static void testTenancyIncidentProcessPermissionUpdateError(){
        String actualErrorMsg = '';
       
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
                try {
                    TriggerBase.bypass('Case');
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildTenancyCase(contactList[0].Id);
                    caseRec.CaseType__C = CaseDecorator.CASE_TYPE_ABANDONED_GOODS;
                    insert caseRec; 
                    TriggerBase.clearBypass('Case');
                    TriggerBase.bypass('TenancyIncident__c');
                    TenancyIncident__c tenIncident = new TenancyIncident__c(Case__c = caseRec.Id);
                    insert tenIncident;
                    TriggerBase.clearBypass('TenancyIncident__c');                  
                    tenIncident.AdditionalInformation__c = 'Add me';
                    update tenIncident;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Tenancy')){
                        throw new StringException(exp.getMessage());
                    }
                }     
            Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains('Tenancy'), 'Should  throw an error when updating a Tenancy Incident process record');
    }
}