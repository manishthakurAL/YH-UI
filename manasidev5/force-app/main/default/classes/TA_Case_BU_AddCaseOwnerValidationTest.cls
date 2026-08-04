@isTest(seeAllData=false)
public with sharing class TA_Case_BU_AddCaseOwnerValidationTest {
      
        @testSetup
        static void setUpTestData(){

            TriggerBase.bypass('Account');
            TriggerBase.bypass('Contact');
            TriggerBase.bypass('Case');

            Account account = UthAccount.build();
            insert account;

            Contact contact = UthContact.build(account.Id);
            insert contact;

            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('Contact');
            TriggerBase.clearBypass('Case');
        }

        @isTest
        static void test_SafeguardingOwnerChangeSuccess(){
            UthFeatureSwitches.enableSafeguardingRT();
            Exception myException;
            String expectedErrorMsg = TA_Case_BU_AddCaseOwnerValidation.ERROR_MESSAGE;
            String actualErrorMsg = '';
            System.runAs(new User(Id = UserInfo.getUserId())){
                Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_SAFEGUARDING_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
                Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_PS_CAN_UPDATE_SAFEGUARDING_CASE).Id;
                PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
                if (permissionSetAssignment == null) {
                    UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
                }
                Contact contact = UthContact.getAll().get(0);
                TriggerBase.bypass('Case');
                Case caseRecord = UthCase.buildSafeguardingCase(contact.Id);
                caseRecord.ReporterType__c = CaseDecorator.REPORTER_TYPE_PERSONATRISK;
                insert caseRecord;
                UthCase.createCaseShareRecords(caseRecord.Id, currentUserId, 'Edit','Manual');
                TriggerBase.clearBypass('Case');
                Test.startTest();
                System.runAs(new User(Id = currentUserId)) {
                    try {
                        caseRecord.OwnerId = currentUserId;
                        update caseRecord;
                    }catch(Exception exp){
                        actualErrorMsg = exp.getMessage();
                        myException = exp;
                    }
                } 
                Test.stopTest();
            }
            Assert.areEqual(false, actualErrorMsg.contains(expectedErrorMsg), 'Should not throw an error when owner assignment');
            Assert.isNull(myException, 'Owner assignment correct');
        }
        
        @isTest
        static void test_SafeguardingOwnerChangeFailure(){
            UthFeatureSwitches.enableSafeguardingRT();
            Exception myException;
            String expectedErrorMsg = TA_Case_BU_AddCaseOwnerValidation.ERROR_MESSAGE;
            String actualErrorMsg = '';
            System.runAs(new User(Id = UserInfo.getUserId())){
                Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_SAFEGUARDING_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
                Contact contact = UthContact.getAll().get(0);
                TriggerBase.bypass('Case');
                Case caseRecord = UthCase.buildSafeguardingCase(contact.Id);
                caseRecord.ReporterType__c = CaseDecorator.REPORTER_TYPE_PERSONATRISK;
                insert caseRecord;
                UthCase.createCaseShareRecords(caseRecord.Id, currentUserId, 'Edit','Manual');
                TriggerBase.clearBypass('Case');
                Test.startTest();
                System.runAs(new User(Id = currentUserId)) {
                    try {
                        caseRecord.OwnerId = currentUserId;
                        update caseRecord;
                    }catch(Exception exp){
                        actualErrorMsg = exp.getMessage();
                        myException = exp;
                    }
                } 
                Test.stopTest();
            }
            Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when owner assignment');
            Assert.isNotNull(myException, 'Owner assignment incorrect');
        }
        
    
}