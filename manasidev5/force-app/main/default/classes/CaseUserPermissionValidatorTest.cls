@isTest(seeAllData=false)
public with sharing class CaseUserPermissionValidatorTest {
    
    @testSetup
    static void setUpTestData(){

        
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        TriggerBase.bypass('Case');
        Account account = UthAccount.build();
        insert account;
        

        Contact contact = UthContact.build(account.Id);
        insert contact;

        Case caseRecord = UthCase.buildComplaintCase(contact.Id);
        caseRecord.StageOneEscalatedDate__c = System.now().addDays(-1);
        caseRecord.StageTwoEscalatedDate__c = System.now().addDays(-1);
        caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
        insert caseRecord;
        

        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        insert tenancy;

        Member__c member = UthMember.build(contact.Id, tenancy.Id, MemberDecorator.TYPE_SOLO);
        insert member;
        
        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        TriggerBase.clearBypass('Case');
    }

    @isTest
    static void testInsertComplaintCasePermission_Success(){
        Id currentUserId = UserInfo.getUserId();
        UthCase.assignComplaintStageOneCreateAndUpdatePermission();
        Contact contact = UthContact.getAll().get(0);
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            Case caseRecord = UthCase.buildComplaintCase(contact.Id);
            caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_COMPLAINTS;
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.Type = CaseDecorator.TYPE_COMPLAINT;
            caseRecord.StageOneEscalatedDate__c = System.now().addDays(-1);
            insert caseRecord;
        }
        Test.stopTest();

        Integer size = UthCase.getAll().size();
        Assert.areEqual(2,size,'Should be able to insert successfully');
    }

    @isTest
    static void testInsertLettingsCasePermission_Success(){
        
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_LETTINGS_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        Contact contact = UthContact.getAll().get(0);
        UthPermissionAssigner.assignPermissionSet(currentUserId, permissionSetId);
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            Case caseRecord = UthCase.buildLettingsCase(contact.Id);
            insert caseRecord;
        }
        Test.stopTest();

        Integer size = UthCase.getAll().size();
        Assert.areEqual(2,size,'Should be able to insert successfully');
    }

    @isTest
    static void testInsertComplaintCasePermission_Failure(){
        Id currentUserId = UserInfo.getUserId();
        Contact contact = UthContact.getAll().get(0);
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg;
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
                Case caseRecord = UthCase.buildComplaintCase(contact.Id);
                caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_COMPLAINTS;
                caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
                caseRecord.Type = CaseDecorator.TYPE_COMPLAINT;
                caseRecord.StageOneEscalatedDate__c = System.now().addDays(-1);
                insert caseRecord;
            }catch(Exception exp){
                actualErrorMsg = exp.getMessage();
            }
        }
        Test.stopTest();
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg),  'Expected exception when inserting case' );
    
    }

    @isTest
    static void testInsertLettingsCasePermission_Failure(){
        Id currentUserId = UserInfo.getUserId();
        Contact contact = UthContact.getAll().get(0);
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg;
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
                Case caseRecord = UthCase.buildLettingsCase(contact.Id);
                caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_LETTINGS;
                caseRecord.Status = CaseDecorator.STATUS_NEW;
                caseRecord.Type = CaseDecorator.TYPE_LETTING_TERMINATION;
                insert caseRecord;
            }catch(Exception exp){
                actualErrorMsg = exp.getMessage();
            }
        }
        Test.stopTest();
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg),  'Expected exception when inserting case' );
    
    }

    @isTest
    static void testUpdateComplaintCasePermission_Success(){
        
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE2).Id;
        
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        Case caseRecord = UthCase.getAll().get(0);

        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {

            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            update caseRecord;
            caseRecord.Status =  CaseDecorator.STATUS_STAGE_TWO;

            update caseRecord;
        }
        Test.stopTest();

        caseRecord = [SELECT Id, Status FROM Case WHERE Id = :caseRecord.Id LIMIT 1];
        Assert.areEqual( CaseDecorator.STATUS_STAGE_TWO, caseRecord.Status,'Status should be updated');
    }

    @isTest
    static void testStageOneCasePermission(){
        Id currentUserId = UserInfo.getUserId();
        Case caseRecord = UthCase.getAll().get(0);
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
                caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
                caseRecord.StageOneEscalatedDate__c = System.now().addDays(-1);
                update caseRecord;
                caseRecord.Status = CaseDecorator.STATUS_STAGE_TWO;
                update caseRecord;
            }catch(Exception exp){
                actualErrorMsg = exp.getMessage();
            }
        }
        Test.stopTest();
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Expected exception when editing case');
    }
    @isTest
    static void testInsertCustomerFeedbackCasePermission_Success(){
        
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CUSTOMER_FEEDBACK_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        Contact contact = UthContact.getAll().get(0);
        UthPermissionAssigner.assignPermissionSet(currentUserId, permissionSetId);
        Test.startTest();
        Case caseRecord;
        System.runAs(new User(Id = currentUserId)) {
            caseRecord = UthCase.buildCustomerFeedbackCase(contact.Id);
            insert caseRecord;
        }
        Test.stopTest();
        System.assert(caseRecord.Id != null, 'Case should be successfully created');
    }

    @isTest
    static void testInsertCustomerFeedbackCasePermission_Failure(){
        Id currentUserId = UserInfo.getUserId();
        Contact contact = UthContact.getAll().get(0);
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg;
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
                Case caseRecord = UthCase.buildCustomerFeedbackCase(contact.Id);
                insert caseRecord;
            }catch(Exception exp){
                actualErrorMsg = exp.getMessage();
            }
        }
        Test.stopTest();
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg),  'Expected exception when inserting case' );
    
    }
    @isTest
    static void testUpdateCustomerFeedbackCasePermission_Success(){
        
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CUSTOMER_FEEDBACK_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CUSTOMER_FEEDBACK_CASE_UPDATE).Id;
        
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        Case caseRecord;
        Test.startTest();
        Contact contact = UthContact.getAll().get(0);
        System.runAs(new User(Id = currentUserId)) {
            caseRecord = UthCase.buildCustomerFeedbackCase(contact.Id);
            insert caseRecord;
            caseRecord.status = CaseDecorator.STATUS_STAGE_CLOSED;
            update caseRecord;
        }
        Test.stopTest();
        caseRecord = [SELECT Id, Status FROM Case WHERE Id = :caseRecord.Id LIMIT 1];
        Assert.areEqual( CaseDecorator.STATUS_STAGE_CLOSED, caseRecord.Status,'Status should be updated');
    }
    @isTest
    static void testUpdateCustomerFeedbackCasePermission_failure(){
        
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CUSTOMER_FEEDBACK_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg;
        Case caseRecord;
        Test.startTest();
        Contact contact = UthContact.getAll().get(0);
        System.runAs(new User(Id = currentUserId)) {
            caseRecord = UthCase.buildCustomerFeedbackCase(contact.Id);
            insert caseRecord;
            try {
                caseRecord.status = CaseDecorator.STATUS_STAGE_CLOSED;
                update caseRecord;
            }
            catch(Exception exp){
                actualErrorMsg = exp.getMessage();
            }
            
            
        }
        Test.stopTest();
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg),  'Expected exception when updating case' );
    }

    @isTest
    static void test_TenancyCoachingCreateSuccess(){
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        Contact contact = UthContact.getAll().get(0);
        Exception ex;
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
               Case tenancyCoachingCaseRecord = UthCase.buildTenancyCoachingCase(contact.Id);
               insert tenancyCoachingCaseRecord;
            }catch(Exception exp){
                ex = exp;
            }
        }
        Test.stopTest(); 
        Assert.areEqual(null, ex, 'Should not throw an error when creating a case');
    }

    @isTest
    static void test_TenancyCoachingCreateFailure(){
        Id currentUserId = UserInfo.getUserId();
        Contact contact = UthContact.getAll().get(0);
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
               Case tenancyCoachingCaseRecord = UthCase.buildTenancyCoachingCase(contact.Id);
               insert tenancyCoachingCaseRecord;
            }catch(Exception exp){
                actualErrorMsg = exp.getMessage();
            }
        }
        Test.stopTest();
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when creating a case');
    }

    @isTest
    static void test_TenancyCoachingUpdateSuccess(){
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        Contact contact = UthContact.getAll().get(0);
        Exception ex;
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
               Case tenancyCoachingCaseRecord = UthCase.buildTenancyCoachingCase(contact.Id);
               insert tenancyCoachingCaseRecord;
               update tenancyCoachingCaseRecord;
            }catch(Exception exp){
                ex = exp;
            }
        }
        Test.stopTest(); 
        Assert.areEqual(null, ex, 'Should not throw an error when updating a case');
    }

    @isTest
    static void test_TenancyCoachingUpdateFailure(){
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        Contact contact = UthContact.getAll().get(0);
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
               Case tenancyCoachingCaseRecord = UthCase.buildTenancyCoachingCase(contact.Id);
               insert tenancyCoachingCaseRecord;
               update tenancyCoachingCaseRecord;
            }catch(Exception exp){
                actualErrorMsg = exp.getMessage();
            }
        }
        Test.stopTest();
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when creating a case');
    }

    @isTest
    static void test_CustomerCaseCreateSuccess(){
        UthFeatureSwitches.enableCustomerRT();
        Exception ex;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CEC_RT_CREATE).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }

            Contact contact = UthContact.getAll().get(0);
            Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                try {
                Case caseRecord  = UthCase.buildCustomerCase(contact.Id);
                insert caseRecord;
                }catch(Exception exp){
                    ex = exp;
                }
            }
            Test.stopTest(); 
        }
        Assert.areEqual(null, ex, 'Should not throw an error when creating a case');
    }

    @isTest
    static void test_CECCaseCreateFailure(){
        UthFeatureSwitches.enableCustomerRT();
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg = '';
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);     
            Contact contact = UthContact.getAll().get(0);
            Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                try {
                Case caseRecord = UthCase.buildCustomerCase(contact.Id);
                insert caseRecord;
                }catch(Exception exp){
                    actualErrorMsg = exp.getMessage();
                }
            }
            Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when creating a case');
    }

    @isTest
    static void test_CECCaseUpdateSuccess(){
        UthFeatureSwitches.enableCustomerRT();
        Exception ex;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CEC_RT_CREATE).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);        
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }

            permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CEC_RT_UPDATE).Id;
            permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }

            Contact contact = UthContact.getAll().get(0);
            Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                try {
                Case caseRecord = UthCase.buildCustomerCase(contact.Id);
                insert caseRecord;
                update caseRecord;
                }catch(Exception exp){
                    ex = exp;
                }
            }

            Test.stopTest(); 
        }
        Assert.areEqual(null, ex, 'Should not throw an error when updating a case');
    }

    @isTest
    static void test_CECCaseUpdateFailure(){
        UthFeatureSwitches.enableCustomerRT();
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg = '';
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Contact contact = UthContact.getAll().get(0);
            TriggerBase.bypass('Case');
            Case caseRecord = UthCase.buildCustomerCase(contact.Id);
            insert caseRecord;
            UthCase.createCaseShareRecords(caseRecord.Id, currentUserId, 'Edit','Manual');
            TriggerBase.clearBypass('Case');
            Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                try {
                    update caseRecord;
                }catch(Exception exp){
                    actualErrorMsg = exp.getMessage();
                }
            }
            Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when updating a case');
    }

    @isTest
    static void test_CECCaseUpdateAtNewSuccess(){
        UthFeatureSwitches.enableCustomerRT();
        Exception ex;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CEC_RT_UPDATE_AT_NEW).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            Contact contact = UthContact.getAll().get(0);
            Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                try {
                    TriggerBase.bypass('Case');
                    Case caseRecord = UthCase.buildCustomerCase(contact.Id);
                    insert caseRecord;
                    TriggerBase.clearBypass('Case');
                    update caseRecord;
                }catch(Exception exp){
                    ex = exp;
                }
            }
           
            Test.stopTest(); 
        }
        Assert.areEqual(null, ex, 'Should not throw an error when updating a case');
    }

    @isTest
    static void test_CECCaseUpdateAtNewFailure(){
        UthFeatureSwitches.enableCustomerRT();
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg = '';
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Contact contact = UthContact.getAll().get(0);
            TriggerBase.bypass('Case');
            Case caseRecord = UthCase.buildCustomerCase(contact.Id);
            caseRecord.Status = CaseDecorator.STATUS_AWAITING_DOCUMENTATION;
            insert caseRecord;
            UthCase.createCaseShareRecords(caseRecord.Id, currentUserId, 'Edit','Manual');
            TriggerBase.clearBypass('Case');
            Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                try {
                update caseRecord;
                }catch(Exception exp){
                    actualErrorMsg = exp.getMessage();
                }
            } 
            Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when creating a case');
    }
    
    @isTest
    static void test_CECCaseCreateAtNewFailure(){
        UthFeatureSwitches.enableCustomerRT();
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg = '';
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Contact contact = UthContact.getAll().get(0);
            Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                try {
                    Case caseRecord = UthCase.buildCustomerCase(contact.Id);
                    caseRecord.Status = CaseDecorator.STATUS_AWAITING_DOCUMENTATION;
                    insert caseRecord;
                }catch(Exception exp){
                    actualErrorMsg = exp.getMessage();
                }
            } 
            Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when creating a case');
    }  
    
    @isTest
    static void test_CECCaseCreateAtNewSuccess(){
        UthFeatureSwitches.enableCustomerRT();
        Exception ex;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CEC_RT_CREATE_AT_NEW).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            Contact contact = UthContact.getAll().get(0);
            Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                try {
                    Case caseRecord = UthCase.buildCustomerCase(contact.Id);
                    insert caseRecord;
                }catch(Exception exp){
                    ex = exp;
                }
            }
           
            Test.stopTest(); 
        }
        Assert.areEqual(null, ex, 'Should not throw an error when creating a case');
    }
    
    @isTest
    static void test_PlaceCreateSuccess(){
        UthFeatureSwitches.enableCasePlaceRT();
        Exception ex;
        System.runAs(new User(Id = UserInfo.getUserId())){
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_CREATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        Contact contact = UthContact.getAll().get(0);
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
               Case placeCaseRecord = UthCase.buildPlaceCase(contact.Id);
               insert placeCaseRecord;
            }catch(Exception exp){
                    ex = exp;
            }
        }
        Test.stopTest(); 
        }
        Assert.areEqual(null, ex, 'Should not throw an error when creating a case');
    }

    @isTest
    static void test_PlaceCreateFailure(){
        UthFeatureSwitches.enableCasePlaceRT();
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg = '';
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Contact contact = UthContact.getAll().get(0);
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
               Case placeCaseRecord = UthCase.buildPlaceCase(contact.Id);
               insert placeCaseRecord;
            }catch(Exception exp){
                actualErrorMsg = exp.getMessage();
            }
        }
        Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when creating a case');
    }

    @isTest
    static void test_PlaceUpdateSuccess(){
        UthFeatureSwitches.enableCasePlaceRT();
        Exception ex;
        System.runAs(new User(Id = UserInfo.getUserId())){
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_CREATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        Contact contact = UthContact.getAll().get(0);
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
               Case placeCaseRecord = UthCase.buildPlaceCase(contact.Id);
               insert placeCaseRecord;
               update placeCaseRecord;
            }catch(Exception exp){
                    ex = exp;
            }
        }
        Test.stopTest(); 
        }
        Assert.areEqual(null, ex, 'Should not throw an error when updating a case');
    }

    @isTest
    static void test_PlaceUpdateFailure(){
        UthFeatureSwitches.enableCasePlaceRT();
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg = '';
        System.runAs(new User(Id = UserInfo.getUserId())){
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_CREATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        Contact contact = UthContact.getAll().get(0);
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
               Case placeCaseRecord = UthCase.buildPlaceCase(contact.Id);
               insert placeCaseRecord;
               update placeCaseRecord;
            }catch(Exception exp){
                actualErrorMsg = exp.getMessage();
            }
        }
        Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when creating a case');
    }

    @isTest
    static void test_BreachCreateSuccess(){
        UthFeatureSwitches.enableCaseBreachAntiSocialBehaviourRT();
        Exception ex;
        System.runAs(new User(Id = UserInfo.getUserId())){
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_CREATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_SAFEGUARDING_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        Contact contact = UthContact.getAll().get(0);
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
               Case breachCaseRecord = UthCase.buildBreachAndASBCase(contact.Id);
               insert breachCaseRecord;
            }catch(Exception exp){
                    ex = exp;
            }
        }
        Test.stopTest(); 
        }
        Assert.areEqual(null, ex, 'Should not throw an error when creating a breach case');
    }

    @isTest
    static void test_BreachCreateFailure(){
        UthFeatureSwitches.enableCaseBreachAntiSocialBehaviourRT();
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg = '';
        Contact contact = UthContact.getAll().get(0);
        Test.startTest();
        try {
            Case breachCaseRecord = UthCase.buildBreachAndASBCase(contact.Id);
            insert breachCaseRecord;
        }catch(Exception exp){
            actualErrorMsg = exp.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when creating a case');
    }

    @isTest
    static void test_BreachUpdateSuccess(){
        UthFeatureSwitches.enableCaseBreachAntiSocialBehaviourRT();
        Exception ex;
        Id currentUserId;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_CREATE_AT_NEW).Id;
            currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_SAFEGUARDING_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }

            permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_UPDATE).Id;
            permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
        }

        Contact contact = UthContact.getAll().get(0);
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
               Case breachCaseRecord = UthCase.buildBreachAndASBCase(contact.Id);
               insert breachCaseRecord;
               update breachCaseRecord;
            }catch(Exception exp){
                    ex = exp;
            }
        }
        Test.stopTest(); 
        Assert.areEqual(null, ex, 'Should not throw an error when updating a case');
    }

    @isTest
    static void test_BreachUpdateFailure(){
        UthFeatureSwitches.enableCaseBreachAntiSocialBehaviourRT();
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg = '';
        Id currentUserId;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_UPDATE).Id;
            currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
        }

        Case breachCaseRecord;
        Contact contact = UthContact.getAll().get(0);
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            breachCaseRecord = UthCase.buildBreachAndASBCase(contact.Id);
            try {
                insert breachCaseRecord;
                update breachCaseRecord;
             }catch(Exception exp){
                 actualErrorMsg = exp.getMessage();
             }
        }        
        Test.stopTest();
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when creating a case');
    }


    @isTest
    static void test_PermissionCreateSuccess(){
        UthFeatureSwitches.enableCasePermissionRT();
        Exception ex;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PERMISSION_CASE_CREATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            
            Contact contact = UthContact.getAll().get(0);
            YH_Tenancy__c tenancy = UthTenancy.getAll().get(0);
            Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                try {
                    Case permissionCaseRecord = UthCase.buildPermissionCase(contact.Id, tenancy.Id);
                    insert permissionCaseRecord;
                }catch(Exception exp){
                    ex = exp;
                }
            }
            Test.stopTest(); 
        }
        Assert.areEqual(null, ex, 'Should not throw an error when creating a case');
    }
    
    @isTest
    static void test_PermissionCreateFailure(){
        UthFeatureSwitches.enableCasePermissionRT();
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg = '';
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Contact contact = UthContact.getAll().get(0);
            YH_Tenancy__c tenancy = UthTenancy.getAll().get(0);
            Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                try {
                    Case permissionCaseRecord = UthCase.buildPermissionCase(contact.Id, tenancy.Id);
                    insert permissionCaseRecord;
                }catch(Exception exp){
                    actualErrorMsg = exp.getMessage();
                }
            }
            Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when creating a case');
    }
    
    @isTest
    static void test_PermissionUpdateSuccess(){
        UthFeatureSwitches.enableCasePermissionRT();
        Exception ex;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PERMISSION_CASE_CREATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            
            permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PERMISSION_CASE_UPDATE).Id;
            permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            
            Contact contact = UthContact.getAll().get(0);
            YH_Tenancy__c tenancy = UthTenancy.getAll().get(0);
            Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                try {
                    Case permissionCaseRecord = UthCase.buildPermissionCase(contact.Id, tenancy.Id);
                    insert permissionCaseRecord;
                    update permissionCaseRecord;
                }catch(Exception exp){
                    ex = exp;
                }
            }
            Test.stopTest(); 
        }
        Assert.areEqual(null, ex, 'Should not throw an error when updating a case');
    }
    
    @isTest
    static void test_PermissionUpdateFailure(){
        UthFeatureSwitches.enableCasePermissionRT();
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg = '';
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PERMISSION_CASE_CREATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            Contact contact = UthContact.getAll().get(0);
            YH_Tenancy__c tenancy = UthTenancy.getAll().get(0);
            Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                try {
                    Case permissionCaseRecord = UthCase.buildPermissionCase(contact.Id, tenancy.Id);
                    insert permissionCaseRecord;
                    update permissionCaseRecord;
                }catch(Exception exp){
                    actualErrorMsg = exp.getMessage();
                }
            }
            Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when creating a case');
    }
    

    @isTest
    static void test_TenancyCreateSuccess(){
        UthFeatureSwitches.enableCaseTenancyRT();
        Exception ex;
        System.runAs(new User(Id = UserInfo.getUserId())){
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        Contact contact = UthContact.getAll().get(0);
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
               Case tenancyCaseRecord = UthCase.buildTenancyCase(contact.Id);
               insert tenancyCaseRecord;
            }catch(Exception exp){
                    ex = exp;
            }
        }
        Test.stopTest(); 
        }
        Assert.areEqual(null, ex, 'Should not throw an error when creating a case');
    }

    @isTest
    static void test_TenancyCreateFailure(){
        UthFeatureSwitches.enableCaseTenancyRT();
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg = '';
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Contact contact = UthContact.getAll().get(0);
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
               Case tenancyCaseRecord = UthCase.buildTenancyCase(contact.Id);
               insert tenancyCaseRecord;
            }catch(Exception exp){
                actualErrorMsg = exp.getMessage();
            }
        }
        Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when creating a case');
    }

    @isTest
    static void test_TenancyUpdateSuccess(){
        UthFeatureSwitches.enableCaseTenancyRT();
        Exception ex;
        System.runAs(new User(Id = UserInfo.getUserId())){
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        Contact contact = UthContact.getAll().get(0);
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
               Case tenancyCaseRecord = UthCase.buildTenancyCase(contact.Id);
               insert tenancyCaseRecord;
               update tenancyCaseRecord;
            }catch(Exception exp){
                    ex = exp;
            }
        }
        Test.stopTest(); 
        }
        Assert.areEqual(null, ex, 'Should not throw an error when updating a case');
    }

    @isTest
    static void test_TenancyUpdateFailure(){
        UthFeatureSwitches.enableCaseTenancyRT();
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg = '';
        System.runAs(new User(Id = UserInfo.getUserId())){
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        Contact contact = UthContact.getAll().get(0);
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            try {
               Case tenancyCaseRecord = UthCase.buildTenancyCase(contact.Id);
               insert tenancyCaseRecord;
               update tenancyCaseRecord;
            }catch(Exception exp){
                actualErrorMsg = exp.getMessage();
            }
        }
        Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when creating a case');
    }
    @isTest
    static void test_ChangesCreateSuccess(){
        UthFeatureSwitches.enableCaseChangesRT();
        Exception ex;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_CREATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            
            Contact contact = UthContact.getAll().get(0);
            Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                try {
                    Case changesCaseRecord = UthCase.buildChangesCase(contact.Id);
                    insert changesCaseRecord;
                }catch(Exception exp){
                    ex = exp;
                }
            }
            Test.stopTest(); 
        }
        Assert.areEqual(null, ex, 'Should not throw an error when creating a case');
    }
    
    @isTest
    static void test_ChangesCreateFailure(){
        UthFeatureSwitches.enableCaseChangesRT();
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg = '';
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Contact contact = UthContact.getAll().get(0);
            Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                try {
                    Case changesCaseRecord = UthCase.buildChangesCase(contact.Id);
                    insert changesCaseRecord;
                }catch(Exception exp){
                    actualErrorMsg = exp.getMessage();
                }
            }
            Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when creating a case');
    }
    
    @isTest
    static void test_ChangesUpdateSuccess(){
        UthFeatureSwitches.enableCaseChangesRT();
        Exception ex;
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_CREATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            
            permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_UPDATE).Id;
            permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            
            Contact contact = UthContact.getAll().get(0);
            Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                try {
                    Case changesCaseRecord = UthCase.buildChangesCase(contact.Id);
                    insert changesCaseRecord;
                    update changesCaseRecord;
                }catch(Exception exp){
                    ex = exp;
                }
            }
            Test.stopTest(); 
        }
        Assert.areEqual(null, ex, 'Should not throw an error when updating a case');
    }
    
    @isTest
    static void test_ChangesUpdateFailure(){
        UthFeatureSwitches.enableCaseChangesRT();
        String expectedErrorMsg = Label.CasePermissionValidationError;
        String actualErrorMsg = '';
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_CREATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_PLACE_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            Contact contact = UthContact.getAll().get(0);
            Test.startTest();
            System.runAs(new User(Id = currentUserId)) {
                try {
                    Case changesCaseRecord = UthCase.buildChangesCase(contact.Id);
                    insert changesCaseRecord;
                    update changesCaseRecord;
                }catch(Exception exp){
                    actualErrorMsg = exp.getMessage();
                }
            }
            Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when creating a case');
    }
}