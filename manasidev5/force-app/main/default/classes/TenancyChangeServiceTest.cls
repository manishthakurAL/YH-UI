@isTest
public with sharing class TenancyChangeServiceTest {
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
    
        YH_Tenancy__c atenancy = UthTenancy.build(aproperty.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO,
                        System.today() + 30,  TenancyDecorator.TENANCY_AGREEMENT_TYPE_STARTER);
        insert atenancy;
        TriggerBase.clearBypass('Account'); 
    }
    

    @isTest
    static void testTenancyChangeProcess12MonthReview(){
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
                    Case caseRec = UthCase.buildChangesCase(contactList[0].Id, CaseDecorator.CASETYPE_STARTERTENANCY12MONTHREVIEW, UthTenancy.getAll()[0].Id);
                    insert caseRec;
                    caseRec.Status = CaseDecorator.STATUS_STAGE_CLOSED;
                    TenancyChange__c tenchange = UthTenancyChange.getAll()[0];
                    tenchange.DeferReviewDate__c = System.today() + 1;
                    tenchange.DeferReason__c = 'Test';
                    update tenchange;
                    caseRec.CaseOutCome__c = CaseDecorator.CASE_OUTCOME_DEFER;
                    caseRec.ClosureReason__c = 'Test';
                    update caseRec;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Change')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual( System.today() + 1, UthTenancy.getAll()[0].DeferReviewDate9month__c ,'Date should match');
    }
    
    @isTest
    static void testTenancyChangeProcess12MonthExtend(){
        String actualErrorMsg = '';
        Date currentConversionDate;
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
                    currentConversionDate = UthTenancy.getAll()[0].ConversionDate__c;
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildChangesCase(contactList[0].Id, CaseDecorator.CASETYPE_STARTERTENANCY12MONTHREVIEW, UthTenancy.getAll()[0].Id);
                    insert caseRec;
                    caseRec.Status = CaseDecorator.STATUS_STAGE_CLOSED;
                    TenancyChange__c tenchange = UthTenancyChange.getAll()[0];
                    tenchange.ExtensionReasonDetail__c = 'test';
                    tenchange.ExtensionReason__c = 'ASB';
                    update tenchange;
                    caseRec.CaseOutCome__c = CaseDecorator.CASE_OUTCOME_EXTEND;
                    caseRec.ClosureReason__c = 'Test';
                    update caseRec;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Change')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(  currentConversionDate.addmonths(6), UthTenancy.getAll()[0].ConversionDate__c ,'Date should match');
        Assert.areEqual(  true, UthTenancy.getAll()[0].IsStarterTenancyExtended__c ,'Tenancy extended');

    }


    
    @isTest
    static void testTenancyChangeProcess18MonthReview(){
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
                    Case caseRec = UthCase.buildChangesCase(contactList[0].Id, CaseDecorator.CASETYPE_STARTERTENANCY18MONTHREVIEW, UthTenancy.getAll()[0].Id);
                    insert caseRec;
                    caseRec.Status = CaseDecorator.STATUS_STAGE_CLOSED;
                    TenancyChange__c tenchange = UthTenancyChange.getAll()[0];
                    tenchange.DeferReviewDate__c = System.today() + 1;
                    tenchange.DeferReason__c = 'Test';
                    update tenchange;
                    caseRec.CaseOutCome__c = CaseDecorator.CASE_OUTCOME_DEFER;
                    caseRec.ClosureReason__c = 'Test';
                    update caseRec;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Change')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual( System.today() + 1, UthTenancy.getAll()[0].DeferReviewDate15month__c ,'Date should match');
    }

    @isTest
    static void testTenancyChangeProcessConvert(){
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
                    Case caseRec = UthCase.buildChangesCase(contactList[0].Id, CaseDecorator.CASETYPE_STARTERTENANCY18MONTHREVIEW, UthTenancy.getAll()[0].Id);
                    insert caseRec;
                    caseRec.Status = CaseDecorator.STATUS_STAGE_CLOSED;
                    caseRec.CaseOutCome__c = CaseDecorator.CASE_OUTCOME_CONVERT;
                    caseRec.ClosureReason__c = 'Test';
                    update caseRec;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Change')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(true, UthTenancy.getAll()[0].StarterTenancyMarkedForConversion__c ,'Is starter tenancy converted should be set to true');
    }
}