@isTest
public with sharing class AuthorityDetailPermissionsValidationTest {
    @TestSetup
    static void makeData(){
        UthFeatureSwitches.enableCustomerRT();
        TriggerBase.bypass('Account');
        Account account1 = UthAccount.buildPersonAccount();
        insert account1;
        TriggerBase.clearBypass('Account');
        
    }

    @isTest
    static void testAuthorityDetailProcessCreatePermission(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CEC_RT_CREATE).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            System.runAs(new User(Id = currentUserId)) {
                try {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildCustomerCase(contactList[0].Id);
                    caseRec.CaseType__c = CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_NEW;
                    insert caseRec; 
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Customer')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(1, UthAuthorityAndDetail.getAll().size());
        Assert.areEqual(false, actualErrorMsg.contains('Customer'), 'Should not throw an error when creating a authority and detail process record');
    }

    @isTest
    static void testAuthorityDetailProcessUpdatePermission(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CEC_RT_UPDATE).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CEC_RT_CREATE).Id;
            permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            System.runAs(new User(Id = currentUserId)) {
                try {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildCustomerCase(contactList[0].Id);
                    caseRec.CaseType__c = CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_NEW;
                    insert caseRec; 
                    AuthorityAndDetail__c authRec = UthAuthorityAndDetail.updateRequiredDetailsForAuthorityDetailsOfPANew(caseRec.Id);
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Customer')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(false, actualErrorMsg.contains('Customer'), 'Should  throw an error when updating a authority and detail process record');
    }

    @isTest
    static void testAuthorityDetailProcessPermissionError(){
        String actualErrorMsg = '';
       
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
                try {
                    TriggerBase.bypass('Case');
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildCustomerCase(contactList[0].Id);
                    caseRec.CaseType__c = CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_NEW;
                    insert caseRec; 
                    TriggerBase.clearBypass('Case');
                    AuthorityAndDetail__c auth = new AuthorityAndDetail__c(Case__c = caseRec.Id);
                    insert auth;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Customer')){
                        throw new StringException(exp.getMessage());
                    }
                }     
            Test.stopTest();
        }
        Assert.areEqual(0, [SELECT Id FROM AuthorityAndDetail__c].size());
    }

    @isTest
    static void testAuthorityDetailProcessPermissionUpdateError(){
        String actualErrorMsg = '';
       
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
                try {
                    TriggerBase.bypass('Case');
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildCustomerCase(contactList[0].Id);
                    caseRec.CaseType__c = CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_NEW;
                    insert caseRec; 
                    TriggerBase.clearBypass('Case');
                    TriggerBase.bypass('AuthorityAndDetail__c');
                    AuthorityAndDetail__c auth = new AuthorityAndDetail__c(Case__c = caseRec.Id);
                    insert auth;
                    TriggerBase.clearBypass('AuthorityAndDetail__c');
                    AuthorityAndDetail__c authRec = UthAuthorityAndDetail.updateRequiredDetailsForAuthorityDetailsOfPANew(caseRec.Id);
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Customer')){
                        throw new StringException(exp.getMessage());
                    }
                }     
            Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains('Customer'), 'Should  throw an error when updating a authority and detail process record');
    }
}