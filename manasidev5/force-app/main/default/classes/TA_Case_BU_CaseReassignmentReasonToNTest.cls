@isTest
private class TA_Case_BU_CaseReassignmentReasonToNTest {

    @testSetup
    static void setUpTestData(){

        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName()); 

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact; 

        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        insert tenancy;

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName()); 
        
    }

	@isTest
    static void ownerChangeWithoutReason(){
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        UthFeatureSwitches.EnableCaseGeneralEnquiryRT();
        list<Contact> conList = UthContact.getAll();
        list<YH_Tenancy__c> tenancyList = UthTenancy.getAll();
        Exception myException;
        String expectedErrorMsg = system.Label.GeneralEnquiryCaseOwnerChangeReassignmentReaosnRequired;
        String actualErrorMsg = '';

        System.runAs(new User(Id = UserInfo.getUserId())){
            Id newUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Case caseRec = UthCase.buildGeneralEnquiryCase(conList[0].Id, tenancyList[0].Id);
                insert caseRec;
                Test.startTest();
                try {
                    case caseRecord = new case(Id=caseRec.Id, OwnerId=newUserId, status = CaseDecorator.STATUS_IN_PROGRESS);
                    update caseRecord;
                    }catch(Exception exp){
                        actualErrorMsg = exp.getMessage();
                    }
                Test.stopTest();
        }
        MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName()); 
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when owner assignment');
    }

	@isTest
    static void ownerChangeWithReason(){
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        UthFeatureSwitches.EnableCaseGeneralEnquiryRT();
        list<Contact> conList = UthContact.getAll();
        list<YH_Tenancy__c> tenancyList = UthTenancy.getAll();

        System.runAs(new User(Id = UserInfo.getUserId())){
            Id newUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Case caseRec = UthCase.buildGeneralEnquiryCase(conList[0].Id, tenancyList[0].Id);
            caseRec.CaseReAssignmentReason__c = 'Test';
                insert caseRec;
                Test.startTest();
                case caseRecord = new case(Id=caseRec.Id, OwnerId=newUserId, status = CaseDecorator.STATUS_IN_PROGRESS);
                update caseRecord;
                Test.stopTest();
        }
        MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName()); 
        Assert.areEqual(null, UthCase.getAll()[0].CaseReAssignmentReason__c, 'Should be null after owner reasignment');
        String body = CaseDecorator.CASE_GENERAL_ENQUIRY_OWNER_FEED_MSG + 'Test';
        Integer feedCount = 0;
        for(FeedItem f : UthFeedItem.getAll(UthCase.getAll()[0].Id)){
            if(f.body.contains(CaseDecorator.CASE_GENERAL_ENQUIRY_OWNER_FEED_MSG)){
                Assert.areEqual(body, f.body, 'Feed should be posted with the reason');
                feedCount++;
            }
        }
        Assert.areEqual(1, feedCount, 'Feed Should be posted on the case with the reason');
    }

	@isTest
    static void ownerChangeWithoutReasonNewStatus(){
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        UthFeatureSwitches.EnableCaseGeneralEnquiryRT();
        list<Contact> conList = UthContact.getAll();
        list<YH_Tenancy__c> tenancyList = UthTenancy.getAll();
        Exception myException;
        String expectedErrorMsg = system.Label.GeneralEnquiryCaseOwnerChangeReassignmentReaosnRequired;
        String actualErrorMsg = '';

        System.runAs(new User(Id = UserInfo.getUserId())){
            Id newUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Case caseRec = UthCase.buildGeneralEnquiryCase(conList[0].Id, tenancyList[0].Id);
                insert caseRec;
                Test.startTest();
                try {
                    case caseRecord = new case(Id=caseRec.Id, OwnerId=newUserId);
                    update caseRecord;
                    }catch(Exception exp){
                        actualErrorMsg = exp.getMessage();
                    }
                Test.stopTest();
        }
        MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName()); 
        Assert.areEqual('', actualErrorMsg, 'Should not throw an error when owner assignment in New status');
    }

	@isTest
    static void ownerChangeWithReasonNewStatus(){
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        UthFeatureSwitches.EnableCaseGeneralEnquiryRT();
        list<Contact> conList = UthContact.getAll();
        list<YH_Tenancy__c> tenancyList = UthTenancy.getAll();

        System.runAs(new User(Id = UserInfo.getUserId())){
            Id newUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Case caseRec = UthCase.buildGeneralEnquiryCase(conList[0].Id, tenancyList[0].Id);
            caseRec.CaseReAssignmentReason__c = 'Test';
                insert caseRec;
                Test.startTest();
                case caseRecord = new case(Id=caseRec.Id, OwnerId=newUserId);
                update caseRecord;
                Test.stopTest();
        }
        MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName()); 
        Assert.areEqual('Test', UthCase.getAll()[0].CaseReAssignmentReason__c, 'Should not be null after owner reasignment in New status');    
    }
    
}