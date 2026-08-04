@isTest
public with sharing class TA_Case_BU_SystemOriginValidationTest {
    @testSetup
    static void setUpTestData(){
        UthFeatureSwitches.enableCaseMoneyCoachingRT();
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact;

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
    }

    @isTest
    static void testCaseSystemOriginFailure(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_SocialValue_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_Triage_BI_CheckPermission.class.getName());
          
            System.runAs(new User(Id = currentUserId)) {
                try {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildMoneyCoachingCase(contactList[0].Id);
                    insert caseRec; 
                    MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
                    MetadataTriggerHandler.clearBypass(TA_SocialValue_BI_CheckPermission.class.getName());
                    MetadataTriggerHandler.clearBypass(TA_Triage_BI_CheckPermission.class.getName());
                    MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
                    MetadataTriggerHandler.bypass(TA_SocialValue_BU_CheckPermission.class.getName());
                    MetadataTriggerHandler.bypass(TA_Triage_BU_CheckPermission.class.getName());
                    caseRec.Origin = CaseDecorator.ORIGIN_SYSTEM;
                    update caseRec;
                }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Origin')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
          
            MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_SocialValue_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Triage_BU_CheckPermission.class.getName());
            Test.stopTest();
        }
        Assert.areNotEqual(CaseDecorator.ORIGIN_SYSTEM, UthCase.getAll()[0].Origin);
        Assert.areEqual(true, actualErrorMsg.contains('Origin'), 'Origin can be set as system only by Admin user');
    }

    @isTest
    static void testCaseSystemOriginSuccess(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_SocialValue_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_Triage_BI_CheckPermission.class.getName());
           
            try {
                List<Contact> contactList = UthContact.getAll();
                Case caseRec = UthCase.buildMoneyCoachingCase(contactList[0].Id);
                insert caseRec; 
                MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
                MetadataTriggerHandler.clearBypass(TA_SocialValue_BI_CheckPermission.class.getName());
                MetadataTriggerHandler.clearBypass(TA_Triage_BI_CheckPermission.class.getName());
                MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
                MetadataTriggerHandler.bypass(TA_SocialValue_BU_CheckPermission.class.getName());
                MetadataTriggerHandler.bypass(TA_Triage_BU_CheckPermission.class.getName());
                caseRec.Origin = CaseDecorator.ORIGIN_SYSTEM;
                update caseRec;
            }catch (Exception exp){
                actualErrorMsg = exp.getMessage();
                if(!actualErrorMsg.contains('Origin')){
                    throw new StringException(exp.getMessage());
                }
            }    
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_SocialValue_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Triage_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_SocialValue_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Triage_BU_CheckPermission.class.getName());
            
            Test.stopTest();
        }
        Assert.areEqual(CaseDecorator.ORIGIN_SYSTEM, UthCase.getAll()[0].Origin);
        Assert.areEqual(false, actualErrorMsg.contains('Origin'), 'Origin can be set as system only by Admin user');
    }
}