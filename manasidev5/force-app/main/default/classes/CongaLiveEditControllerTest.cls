@isTest(seeAllData=false)
public with sharing class CongaLiveEditControllerTest {
    
    @testSetup
    static void setUpTestData(){
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        TriggerBase.bypass('Case');

        OrgSetting__c settings = UthOrgSetting.build();
        settings.ContentWorkspaceId__c = 'XXXXXXXXXX';
        insert settings;

        APXTConga4__Conga_Template__c template = UthCongaTemplate.build('0T_022UAM464594');
        insert template;

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact;
        
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions(
            'Leeds', 
            PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS,
            'E08000035', 
            PropertyDecorator.RENT_TYPE_SOCIAL_RENT,
            PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL
        );
        insert property;

        Case caseRecord = UthCase.buildComplaintCase(contact.Id);
        caseRecord.StageOneEscalatedDate__c = System.now().addDays(-1);
        insert caseRecord;
        caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
        update caseRecord;
        
        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        TriggerBase.clearBypass('Case');
    }

    @isTest
    static void testGetCongaSettingsWithValidCaseId(){
                               
        List<Case> casesList = UthCase.getAll();
        for (Case caseRecord : casesList) {
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.ownerId = UserInfo.getUserId();
        }
        TriggerBase.bypass('Case');
        update casesList;
        TriggerBase.clearBypass('Case');
        Test.startTest();
        String category = CongaLiveEditController.UNCATEGORIZED_CATEGORY;
        CongaLiveEditController.CaseCongaSetting caseCongaSetting = CongaLiveEditController.getCongaSettings(casesList[0].Id);
        Assert.areEqual(true, caseCongaSetting.letterTemplates.get(category).size() > 0,'Size should be 7 including a default one');
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetCongaSettingsWithRentTags(){
        
        List<Contact> ContactList = UthContact.getAll();
        List<YH_Property__c> properties = UthProperty.getAll();
        Case managedMoveCaseRecord = UthCase.buildManagedMoveCase(ContactList[0].Id);
        managedMoveCaseRecord.Property__c = properties[0].Id;
        System.runAs(UthUser.getSchemeUserForManagedMove(UserInfo.getUserId())) {
            Test.startTest();
            	insert managedMoveCaseRecord;
            Test.stopTest();
        }
        String category = CongaLiveEditController.UNCATEGORIZED_CATEGORY;
        CongaLiveEditController.CaseCongaSetting caseCongaSetting = CongaLiveEditController.getCongaSettings(managedMoveCaseRecord.Id);
        Assert.areEqual(true, caseCongaSetting.letterTemplates.get(category).size() > 1,'Size should be 2 including a default one');
       
        
    }

    @isTest
    static void testGetCongaSettingsWithRentTagsTerminations(){
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_Termination_BU_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_InspectionCheck_BU_CheckPermission.class.getName());
        List<Contact> ContactList = UthContact.getAll();
        List<YH_Property__c> properties = UthProperty.getAll();
        YH_Tenancy__c atenancy = UthTenancy.build(properties[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        insert atenancy;
        Case terminationCase = UthCase.buildTerminationCase(ContactList[0].Id,atenancy.id);
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            	insert terminationCase;
            Test.stopTest();
        }
        String category = CongaLiveEditController.UNCATEGORIZED_CATEGORY;
        CongaLiveEditController.CaseCongaSetting caseCongaSetting = CongaLiveEditController.getCongaSettings(terminationCase.Id);
        MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.clearBypass(TA_Termination_BU_CheckPermission.class.getName());
        MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BU_CheckPermission.class.getName());
        Assert.areEqual(true, caseCongaSetting.letterTemplates.get(category).size() > 1,'Size should be 2 including a default one');
       
        
    }
    
    @isTest
    static void testGetCongaUrlWithValidCaseId(){
    
        List<Case> casesList = UthCase.getAll();
        for (Case caseRecord : casesList) {
            caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
            caseRecord.ownerId = UserInfo.getUserId();
        }
        TriggerBase.bypass('Case');
        update casesList;
        TriggerBase.clearBypass('Case');
        CongaLiveEditController.CaseCongaSetting caseCongaSetting = CongaLiveEditController.getCongaSettings(casesList[0].Id);
        Map<String, List<CaseCongaSetting__mdt>> caseCongaSettingsList = caseCongaSetting.letterTemplates;
        Test.startTest();
        String category = CongaLiveEditController.UNCATEGORIZED_CATEGORY;
        Assert.isTrue(CongaLiveEditController.getCongaUrl(casesList[0].Id, caseCongaSettingsList.get(category)[0].Id, 'CONGA_POST_ACTION').contains(caseCongaSettingsList.get(category)[0].CongaDocumentGenerationSetting__r.TemplateId__c),'This should have the template key from custom metadata');
        Assert.isTrue(CongaLiveEditController.getCongaUrl(casesList[0].Id, caseCongaSettingsList.get(category)[0].Id, 'CONGA_POST_ACTION').contains(casesList[0].Id),'This should have the current case record id');
        Test.stopTest();
    }

    @isTest
    static void testSaveDraftLetterContent(){

        String LetterContentExpected = '<p>Test Letter Content</p>';
        String templateKey = '0T_022UAM464594';
        String actualContent;
                                
        List<Case> casesList = UthCase.getAll();
        Test.startTest();
        String category = CongaLiveEditController.UNCATEGORIZED_CATEGORY;
        SObject settings = CongaLiveEditController.getCongaTemplateByKey(templateKey);
        CongaLiveEditController.saveLetterDraftContent(casesList[0].Id, templateKey, LetterContentExpected);
        actualContent = CongaLiveEditController.getLetterDraftContent(casesList[0].Id, templateKey);
        
        Test.stopTest();
        Assert.areEqual(LetterContentExpected,actualContent,'Letter Content draft must be save to the case');
    }


    @isTest
    static void testSaveLetterContent(){
        String templateKey = '0T_022UAM464594';
        String LetterContentExpected = '<p>Test Letter Content</p>';
                                
        List<Case> casesList = UthCase.getAll();
        Test.startTest();
        CongaLiveEditController.saveCase(casesList[0].Id, templateKey, LetterContentExpected);
        Test.stopTest();
        casesList = UthCase.getAll();
        Assert.areEqual(LetterContentExpected,casesList[0].LetterContent__c,'Letter Content must be save to the case');
    }
}