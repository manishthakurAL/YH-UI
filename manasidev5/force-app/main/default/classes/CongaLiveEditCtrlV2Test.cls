@isTest
public class CongaLiveEditCtrlV2Test {
    
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
        CongaLetterTemplateBaseService.GetCongaLettersResult caseCongaSetting = CongaLiveEditCtrlV2.getCongaLetters(casesList[0].Id);
        Assert.areEqual(false, caseCongaSetting.result.isEmpty(),'There should be Conga Letter');
        Test.stopTest();
        
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
        CongaLetterTemplateBaseService.GetCongaLettersResult caseCongaSetting = CongaLiveEditCtrlV2.getCongaLetters(casesList[0].Id);
        Map<String, List<CongaLetterTemplateBaseService.CongaLetterTemplate>> caseCongaSettingsList = caseCongaSetting.result;
        Test.startTest();
        String category = CongaLetterTemplateBaseService.GLOBAL_CATEGORY;
        Assert.isTrue(CongaLiveEditCtrlV2.getCongaUrl(casesList[0].Id, caseCongaSettingsList.get(category)[0].urlParamSettingsId, 'CONGA_POST_ACTION').contains(caseCongaSettingsList.get(category)[0].templateKey),'This should have the template key from custom metadata');
        Assert.isTrue(CongaLiveEditCtrlV2.getCongaUrl(casesList[0].Id, caseCongaSettingsList.get(category)[0].urlParamSettingsId, 'CONGA_POST_ACTION').contains(casesList[0].Id),'This should have the current case record id');
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
        CongaLiveEditCtrlV2.saveLetterDraftContent(casesList[0].Id, templateKey, LetterContentExpected);
        actualContent = CongaLiveEditCtrlV2.getLetterDraftContent(casesList[0].Id, templateKey);
        
        Test.stopTest();
        Assert.areEqual(LetterContentExpected,actualContent,'Letter Content draft must be save to the case');
    }


    @isTest
    static void testSaveLetterContent(){
        String templateKey = '0T_122UAMAA1194';
        String LetterContentExpected = '<p>Test Letter Content</p>';
                                
        List<Case> casesList = UthCase.getAll();
        Test.startTest();
        CongaLiveEditCtrlV2.saveLetterContent(casesList[0].Id, templateKey, LetterContentExpected);
        Test.stopTest();
        casesList = UthCase.getAll();
        Assert.areEqual(LetterContentExpected,casesList[0].LetterContent__c,'Letter Content must be save to the case');
    }

    @isTest
    static void negativeTestWithContactId(){
        String expectedError = 'Script-thrown exception';
        String actualError;
        try {
            CongaLetterTemplateBaseService.GetCongaLettersResult caseCongaSetting = CongaLiveEditCtrlV2.getCongaLetters(UthContact.getAll().get(0).Id);

        } catch(AuraHandledException exp) {
            actualError = exp.getMessage();
        }
        Assert.isTrue(actualError.contains(expectedError), 'This should be the error message. ');
        actualError = null;

        try {
            String url = CongaLiveEditCtrlV2.getCongaUrl(UthContact.getAll().get(0).Id, null, null);

        }catch(AuraHandledException exp) {
            actualError = exp.getMessage();
        }
        Assert.isTrue(actualError.contains(expectedError), 'This should be the error message. ');
        actualError = null;

        try {
            String url = CongaLiveEditCtrlV2.getCongaUrl(UthContact.getAll().get(0).Id, null, null);

        }catch(AuraHandledException exp) {
            actualError = exp.getMessage();
        }
        Assert.isTrue(actualError.contains(expectedError), 'This should be the error message. ');
        actualError = null;

        try {
            String url = CongaLiveEditCtrlV2.getLetterDraftContent(UthContact.getAll().get(0).Id, null);

        }catch(AuraHandledException exp) {
            actualError = exp.getMessage();
        }
        Assert.isTrue(actualError.contains(expectedError), 'This should be the error message. ');
        actualError = null;

        try {
            CongaLiveEditCtrlV2.saveLetterDraftContent(UthContact.getAll().get(0).Id, null, null);

        }catch(AuraHandledException exp) {
            actualError = exp.getMessage();
        }
        Assert.isTrue(actualError.contains(expectedError), 'This should be the error message. ');
        actualError = null;
        
        try {
            CongaLiveEditCtrlV2.saveLetterContent(UthContact.getAll().get(0).Id, null, null);

        }catch(AuraHandledException exp) {
            actualError = exp.getMessage();
        }
        Assert.isTrue(actualError.contains(expectedError), 'This should be the error message. ');
    }

}