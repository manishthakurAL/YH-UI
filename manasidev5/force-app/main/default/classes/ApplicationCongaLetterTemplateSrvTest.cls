@isTest
public with sharing class ApplicationCongaLetterTemplateSrvTest {
    @testSetup
    static void setUpTestData(){

        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        TriggerBase.bypass('Case');

        OrgSetting__c settings = UthOrgSetting.build();
        settings.ContentWorkspaceId__c = 'XXXXXXXXXX';
        insert settings;

        APXTConga4__Conga_Template__c template = UthCongaTemplate.build('0T_122UAMAA1194');
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

        Case caseRecord = UthCase.buildLettingsCase(contact.Id);
        caseRecord.Property__c = property.Id;
        insert caseRecord;

        YH_Application__c application = UthApplication.buildApplication(caseRecord.Id, property.Id, ApplicationDecorator.STARTER_TENANCY, System.now().addDays(1).date());
        insert application;

        Applicant__c applicant = UthApplicant.buildApplicant(contact.Id, application.Id);
        insert applicant;
        

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        TriggerBase.clearBypass('Case');
    }

    @isTest
    static void testGetCongaSettingsWithValidApplicationId(){
        Test.startTest();
        CongaLetterTemplateBaseService.GetCongaLettersResult caseCongaSetting = CongaLiveEditCtrlV2.getCongaLetters(UthApplication.getAll().get(0).Id);
        Assert.areEqual(false, caseCongaSetting.result.isEmpty(),'There should be Conga Letter');
        Test.stopTest();
    }
    @isTest
    static void testGetCongaSettingsWithAgreementSigned(){
        
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_LETTINGS_CASE_UPDATE).Id;
        Id currentUserId = UserInfo.getUserId();
        UthPermissionAssigner.assignPermissionSet(currentUserId, permissionSetId);
        Test.startTest();
        System.runAs(new User(Id = currentUserId)) {
            YH_Application__c application = UthApplication.getAll().get(0);
            CongaLetterTemplateBaseService.GetCongaLettersResult caseCongaSetting = CongaLiveEditCtrlV2.getCongaLetters(application.Id);
            Boolean templateContainsAgreement = false;
            for(CongaLetterTemplateBaseService.CongaLetterTemplate congaTemplate : caseCongaSetting.result.get(CongaLetterTemplateBaseService.GLOBAL_CATEGORY)){
                if(congaTemplate.letterTitle.contains('Tenancy Agreement')){
                    templateContainsAgreement = true;
                }
            }
            Assert.areEqual(true, templateContainsAgreement,'There should be Tenancy Agreement Conga Letter');
            
            application = UthApplication.signApplication(application);
            update application;
            caseCongaSetting = CongaLiveEditCtrlV2.getCongaLetters(application.Id);
            Boolean templateDonotContainsAgreement = true;
            for(CongaLetterTemplateBaseService.CongaLetterTemplate congaTemplate : caseCongaSetting.result.get(CongaLetterTemplateBaseService.GLOBAL_CATEGORY)){
                if(congaTemplate.letterTitle.contains('Tenancy Agreement')){
                    templateDonotContainsAgreement = false;
                }
            }
            Assert.areEqual(true, templateDonotContainsAgreement,'There should not be Agreement Conga Letter');
        }
        Test.stopTest();
    }
    @isTest
    static void testGetCongaUrlWithValidApplicationId(){
    
        CongaLetterTemplateBaseService.GetCongaLettersResult caseCongaSetting = CongaLiveEditCtrlV2.getCongaLetters(UthApplication.getAll().get(0).Id);
        Map<String, List<CongaLetterTemplateBaseService.CongaLetterTemplate>> caseCongaSettingsList = caseCongaSetting.result;
        Test.startTest();
        String category = CongaLetterTemplateBaseService.GLOBAL_CATEGORY;
        Assert.isTrue(CongaLiveEditCtrlV2.getCongaUrl(UthApplication.getAll().get(0).Id, caseCongaSettingsList.get(category)[0].urlParamSettingsId, 'CONGA_POST_ACTION').contains(caseCongaSettingsList.get(category)[0].templateKey),'This should have the template key from custom metadata');
        Assert.isTrue(CongaLiveEditCtrlV2.getCongaUrl(UthApplication.getAll().get(0).Id, caseCongaSettingsList.get(category)[0].urlParamSettingsId, 'CONGA_POST_ACTION').contains(UthApplication.getAll().get(0).Id),'This should have the current case record id');
        Test.stopTest();
    }

    @isTest
    static void testSaveDraftLetterContent(){

        String LetterContentExpected = '<p>Test Letter Content</p>';
        String templateKey = '0T_122UAMAA1194';
        String actualContent;
                                
        List<Case> casesList = UthCase.getAll();
        Test.startTest();
        String category = CongaLetterTemplateBaseService.GLOBAL_CATEGORY;
        SObject settings = CongaLiveEditCtrlV2.getCongaTemplateByKey(templateKey);
        CongaLiveEditCtrlV2.saveLetterDraftContent(UthApplication.getAll().get(0).Id, templateKey, LetterContentExpected);
        actualContent = CongaLiveEditCtrlV2.getLetterDraftContent(UthApplication.getAll().get(0).Id, templateKey);
        
        Test.stopTest();
        Assert.areEqual(LetterContentExpected,actualContent,'Letter Content draft must be save to the case');
    }


    @isTest
    static void testSaveLetterContent(){
        String templateKey = '0T_122UAMAA1194';
        String LetterContentExpected = '<p>Test Letter Content</p>';
                                
        List<Case> casesList = UthCase.getAll();
        Test.startTest();
        CongaLiveEditCtrlV2.saveLetterContent(UthApplication.getAll().get(0).Id, templateKey, LetterContentExpected);
        Test.stopTest();
        casesList = UthCase.getAll();
        Assert.areEqual(LetterContentExpected,UthApplication.getAll().get(0).LetterContent__c,'Letter Content must be save to the case');
    }
}