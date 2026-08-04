@isTest(seeAllData=false)
public class CaseProcessRecordManagerTest {
    @testSetup
    static void setUpTestData(){

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
    static void testAuthorityDetailsForCustomerRecord(){
        List<AuthorityAndDetail__c> AuthorityAndDetailList;
        Case caseRecord;
        UthFeatureSwitches.enableCustomerRT();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CEC_RT_CREATE).Id;
            UthPermissionAssigner.assignPermissionSet(currentUserId, createPermissionSetId);
            List<Contact> contactsList = UthContact.getAll();
            System.runAs(new User(Id = currentUserId)){
                Test.startTest();
                caseRecord = UthCase.buildCustomerCase(contactsList[0].Id);
                insert caseRecord;
                Test.stopTest();
                AuthorityAndDetailList = [SELECT Id,caseStatus__c FROM AuthorityAndDetail__c WHERE Case__c =: caseRecord.Id ];
            }
        }
        Assert.areEqual(1,AuthorityAndDetailList.size(), 'Process record - Authority and Details should be created');
        Assert.areEqual(caseRecord.Status,AuthorityAndDetailList.get(0).caseStatus__c,'Status should be same');
    }

    @isTest
    static void testTriageForMoneyCoaching(){
        System.runAs(getMoneyCoachingUser()) {
        	List<Contact> contactsList = UthContact.getAll();
        	Test.startTest();
        	Case caseRecord = UthCase.buildMoneyCoachingCase(contactsList[0].Id);
        	insert caseRecord;
        	Test.stopTest();
        	List<Triage__c> TriageList = UthTriage.getAll();
        	Assert.areEqual(1,TriageList.size(), 'Process record - Triage should be created');
            Assert.areEqual(caseRecord.Status,TriageList.get(0).caseStatus__c,'Status should be same');

       }
    }
    
    @isTest
    static void testProcessObjectForTenancyCoaching(){
        System.runAs(getTenancyCoachingUser()) {
        	List<Contact> contactsList = UthContact.getAll();
        	Test.startTest();
        	Case caseRecord = UthCase.buildTenancyCoachingCase(contactsList[0].Id);
        	insert caseRecord;
        	Test.stopTest();
        	List<Triage__c> TriageList = UthTriage.getAll();
        	List<SocialValue__c> SocialList = UthSocialValue.getAll();
        	Assert.areEqual(1,TriageList.size(), 'Process record - Triage should be created');
            Assert.areEqual(caseRecord.Status,TriageList.get(0).caseStatus__c,'Status should be same');
        	Assert.areEqual(1,SocialList.size(), 'Process record - Social value should be created');
            Assert.areEqual(caseRecord.Status,SocialList.get(0).caseStatus__c,'Status should be same');

       }
    }

    @isTest
    static void testUpdateCaseStatusCopiedToProcessTermination_Success(){
        Id userId = UserInfo.getUserId();
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        UthFeatureSwitches.enableCaseTerminationRT(); 
        UthFeatureSwitches.enableCaseLettingRT();
        TriggerBase.bypass('Account');
        Account account1 = UthAccount.buildPersonAccount();
        insert account1;
        TriggerBase.clearBypass('Account');    
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
        YH_Property__c aproperty = uthProperty.buildPropertyWithDesignAssumptions(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE,
            PropertyDecorator.AUTHCODE_E08000038,
            PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
            PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE
            );
        insert aproperty;

        YH_Tenancy__c tenancy = UthTenancy.build(aproperty.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        insert tenancy;
        
        String statusExpected = CaseDecorator.STATUS_ADMINISTRATION;
        String statusActual;
        Contact contact = UthContact.getAll().get(0);
        
        System.runAs(new User(Id = userId)) {
            List<Case> cases = new List<Case>();
            Test.startTest();
            for(Integer i = 0; i < 10;i++){
                Case caseRecord = UthCase.buildTerminationCase(contact.Id, tenancy.Id);
                cases.add(caseRecord);
            }
            insert cases;
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            Test.stopTest();            
        }
        
        for(Termination__c terminationrec: UthTermination.getAll()){
            Assert.isNotNull(terminationrec.Id);
        }
    }
    
    static User getMoneyCoachingUser() {
        Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MONEY_COACHING_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        UthPermissionAssigner.assignPermissionSet(currentUserId, createPermissionSetId);
        return (new User(Id = currentUserId));
    }
    
    static User getTenancyCoachingUser() {
        Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_COACHING_CASE_CREATE).Id;
        Id currentUserId = UserInfo.getUserId();
        UthPermissionAssigner.assignPermissionSet(currentUserId, createPermissionSetId);
        return (new User(Id = currentUserId));
    }
}