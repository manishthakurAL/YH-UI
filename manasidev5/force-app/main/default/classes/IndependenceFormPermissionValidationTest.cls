@isTest
public with sharing class IndependenceFormPermissionValidationTest {
    @TestSetup
    static void makeData(){
        UthFeatureSwitches.enableCaseSchemesRT();
        TriggerBase.bypass('Account');
        Account account1 = UthAccount.buildPersonAccount();
        insert account1;
        TriggerBase.clearBypass('Account'); 
    }

    @isTest
    static void testIndependenceFormProcessCreatePermission(){
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
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Schemes')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(1, UthIndependenceForm.getAll().size());
        Assert.areEqual(false, actualErrorMsg.contains('Schemes'), 'Should not throw an error when creating a Independence Form process record');
    }

    @isTest
    static void testIndependenceFormProcessUpdatePermission(){
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
                    IndependenceForm__c iform = new IndependenceForm__c();
                    iform.Case__c = caseRec.Id;
                    insert iform;
                    iform.AdditionalInformationLong__c = 'Test';
                    update iform;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Schemes')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(false, actualErrorMsg.contains('Schemes'), 'Should not throw an error when updating a independence form process record');
    }

    @isTest
    static void testIndependenceFormProcessUpdatePermissionError(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
           
            try {
                TriggerBase.bypass('Case');
                List<Contact> contactList = UthContact.getAll();
                Case caseRec = UthCase.buildSchemesCase(contactList[0].Id);
                insert caseRec; 
                TriggerBase.clearBypass('Case');
                TriggerBase.bypass('IndependenceForm__c');
                IndependenceForm__c iform = new IndependenceForm__c();
                iform.Case__c = caseRec.Id;
                insert iform;
                TriggerBase.clearBypass('IndependenceForm__c');
                iform.AdditionalInformationLong__c = 'Test';
                update iform;
            }catch (Exception exp){
                actualErrorMsg = exp.getMessage();
                if(!actualErrorMsg.contains('Schemes')){
                    throw new StringException(exp.getMessage());
                }
            }    
            
            Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains(''), 'Should  throw an error when updating a independence form process record');
    }
}