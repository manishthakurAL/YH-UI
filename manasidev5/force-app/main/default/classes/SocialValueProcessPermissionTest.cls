@isTest
public with sharing class SocialValueProcessPermissionTest {
    @TestSetup
    static void makeData(){
        UthFeatureSwitches.enableCaseMoneyCoachingRT();
        TriggerBase.bypass('Account');
        Account account1 = UthAccount.buildPersonAccount();
        insert account1;
        TriggerBase.clearBypass('Account');        
    }

    @isTest
    static void testSocialValueProcessCreatePermission(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MONEY_COACHING_CASE_CREATE).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            System.runAs(new User(Id = currentUserId)) {
                try {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildMoneyCoachingCase(contactList[0].Id);
                    insert caseRec; 
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Money Coach')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(1, UthSocialValue.getAll().size());
        Assert.areEqual(false, actualErrorMsg.contains('Money Coach'), 'Should not throw an error when creating a Social Value process record');
    }

    @isTest
    static void testSocialValueProcessUpdatePermission(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MONEY_COACHING_CASE_UPDATE).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MONEY_COACHING_CASE_CREATE).Id;
            permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            System.runAs(new User(Id = currentUserId)) {
                try {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildMoneyCoachingCase(contactList[0].Id);
                    insert caseRec; 
                    SocialValue__c asocialVal = UthSocialValue.getAll()[0];
                    asocialVal.GoodOverallHealth__c = true;
                    update asocialVal;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Money Coach')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(false, actualErrorMsg.contains('Money Coach'), 'Should not throw an error when updating a social value process record');
    }

    @isTest
    static void testSocialValuerocessPermissionError(){
        String actualErrorMsg = '';
       
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
                try {
                    TriggerBase.bypass('Case');
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildMoneyCoachingCase(contactList[0].Id);
                    insert caseRec; 
                    TriggerBase.clearBypass('Case');
                    SocialValue__c asocval = UthSocialValue.build(caseRec.Id);
                    insert asocval;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Money Coaching')){
                        throw new StringException(exp.getMessage());
                    }
                }     
            Test.stopTest();
        }
        Assert.areEqual(0, UthSocialValue.getAll().size());
    }

    @isTest
    static void testSocialValueProcessPermissionUpdateError(){
        String actualErrorMsg = '';
       
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
                try {
                    TriggerBase.bypass('Case');
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildMoneyCoachingCase(contactList[0].Id);
                    insert caseRec; 
                    TriggerBase.clearBypass('Case');
                    TriggerBase.bypass('SocialValue__c');
                    SocialValue__c socval = UthSocialValue.build(caseRec.Id);
                    insert socval;
                    TriggerBase.clearBypass('SocialValue__c');
                    socval.GoodOverallHealth__c = true;
                    update socval;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Money Coaching')){
                        throw new StringException(exp.getMessage());
                    }
                }     
            Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains('Money Coaching'), 'Should  throw an error when updating a Social Value process record');
    }
}