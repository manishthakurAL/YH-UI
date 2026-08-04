@isTest
public with sharing class MonitoringFormPermissionValidationTest {
    @TestSetup
    static void makeData(){
        UthFeatureSwitches.enableCaseSchemesRT();
        TriggerBase.bypass('Account');
        Account account1 = UthAccount.buildPersonAccount();
        insert account1;
        TriggerBase.clearBypass('Account'); 
    }

    @isTest
    static void testMonitoringFormProcessCreatePermission(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_SCHEMES_CASE_CREATE).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            System.runAs(new User(Id = currentUserId)) {
                try {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildSchemesCase(contactList[0].Id);
                    insert caseRec; 
                    Monitoring_Form__c mform = new Monitoring_Form__c();
                    mform.Case__c = caseRec.Id;
                    insert mform;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Schemes')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(1, UthMonitoringForm.getAll().size());
        Assert.areEqual(false, actualErrorMsg.contains('Schemes'), 'Should not throw an error when creating a Monitoring Form process record');
    }

    @isTest
    static void testMonitoringFormProcessUpdatePermission(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_SCHEMES_CASE_CREATE).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_SCHEMES_CASE_UPDATE).Id;
            permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            System.runAs(new User(Id = currentUserId)) {
                try {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildSchemesCase(contactList[0].Id);
                    insert caseRec; 
                    Monitoring_Form__c mform = new Monitoring_Form__c();
                    mform.Case__c = caseRec.Id;
                    insert mform;
                    mform.AdditionalInformation__c = 'Test';
                    update mform;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Schemes')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(false, actualErrorMsg.contains('Schemes'), 'Should not throw an error when updating a monitoring form process record');
    }
}