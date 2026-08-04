@isTest
public with sharing class CongaServiceTest {

    static final string CONGA_TENANT_QUERY = 'SELECT Name FROM Contact WHERE Id in (SELECT Contact__c FROM CaseRole__c WHERE Case__c = :recordId AND Role__c = \'Accused Party\' ) LIMIT 1 OFFSET 0';
    static final string CONGA_QUERY_NAME = 'Test Tenant Query';
    static final string CONGA_QUERY_KEY = '0Q_067MA0340890';
    static final string CONGA_QUERY2_KEY = '0Q_041UAU238195';

    @TestSetup
    static void makeData(){
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        TriggerBase.bypass('Case');
        TriggerBase.bypass('CaseRole__c');

        OrgSetting__c settings = UthOrgSetting.build();
        settings.ContentWorkspaceId__c = 'XXXXXXXXXX';
        insert settings;

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact;

        Case caseRecord = UthCase.buildComplaintCase(contact.Id);
        insert caseRecord;

        CaseRole__c aCaseRole = UthCaseRole.build(caseRecord.Id,contact.Id,CaseRoleDecorator.TENANT_ROLE);
        insert aCaseRole;

        CaseRole__c aCaseRole2 = UthCaseRole.build(caseRecord.Id,contact.Id,CaseRoleDecorator.ACCUSED_PARTY_ROLE);
        insert aCaseRole2;
        
        APXTConga4__Conga_Merge_Query__c query = UthCongaMergeQuery.build(CONGA_QUERY_NAME, CONGA_QUERY_KEY, CONGA_TENANT_QUERY);
        insert query;

        APXTConga4__Conga_Merge_Query__c query2 = UthCongaMergeQuery.build(CONGA_QUERY_NAME, CONGA_QUERY2_KEY, CONGA_TENANT_QUERY);
        insert query2;

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        TriggerBase.clearBypass('Case');
        TriggerBase.clearBypass('CaseRole__c');
    }


    @isTest 
    static void test_congaSaveDocumentOnMasterObjectUrl() {
        Case caseRecord = UthCase.getAll().get(0);

        Test.startTest();

        String congaUrl = CongaService.get().getCongaUrl(caseRecord.Id, 'COM_Ombudsman_Evidence_Request_Letter', CongaService.ActionType.CONGA_SAVE_ACTION);

        Assert.areEqual(true, congaUrl.containsIgnoreCase('DS7=11'), 'Conga Url must have background url with DS7=11');

        Test.stopTest();
    }

    @isTest 
    static void test_congaSaveAndPostDocumentOnMasterObjectUrl() {
        Case caseRecord = UthCase.getAll().get(0);

        Test.startTest();

        String congaUrl = CongaService.get().getCongaUrl(caseRecord.Id, 'COM_Ombudsman_Evidence_Request_Letter', CongaService.ActionType.CONGA_POST_ACTION);

        Assert.areEqual(true, congaUrl.containsIgnoreCase('DS7=11'), 'Conga Url must have background url with DS7=11');

        Test.stopTest();
    }

    @isTest 
    static void test_congaEmailDocumentOnMasterObjectUrl() {
        Case caseRecord = UthCase.getAll().get(0);

        Test.startTest();

        String congaUrl = CongaService.get().getCongaUrl(caseRecord.Id, 'COM_Ombudsman_Evidence_Request_Letter', CongaService.ActionType.CONGA_EMAIL_ACTION);

        Assert.areEqual(true, congaUrl.containsIgnoreCase('DS7=12'), 'Conga Url must have background url with DS7=11');

        Test.stopTest();
    }


    @isTest 
    static void test_congaEmailAndPostDocumentOnMasterObjectUrl() {
        Case caseRecord = UthCase.getAll().get(0);

        Test.startTest();

        String congaUrl = CongaService.get().getCongaUrl(caseRecord.Id, 'COM_Ombudsman_Evidence_Request_Letter', CongaService.ActionType.CONGA_EMAIL_AND_POST_ACTION);

        Assert.areEqual(true, congaUrl.containsIgnoreCase('DS7=12'), 'Conga Url must have background url with DS7=11');

        Test.stopTest();
    }

    @isTest 
    static void test_congaUnknowRequest() {
        Case caseRecord = UthCase.getAll().get(0);
        String actualErrorMessage;
        String expectedErrorMessage = 'No enum value found called UNKNOW_ACTION_TYPE';

        Test.startTest();
        try {

            String congaUrl = CongaService.get().getCongaUrl(caseRecord.Id, 'COM_Ombudsman_Evidence_Request_Letter', CongaService.ActionType.valueOf('UNKNOW_ACTION_TYPE'));

        } catch(Exception exp) {
            actualErrorMessage = exp.getMessage();
        }

        Assert.areEqual(true, actualErrorMessage.containsIgnoreCase(expectedErrorMessage), 'Exception must be generated');

        Test.stopTest();
    }

    @isTest 
    static void test_congaDocusignInPerson() {
        Case caseRecord = UthCase.getAll().get(0);
        String actualErrorMessage;
        String expectedErrorMessage = 'No enum value found called UNKNOW_ACTION_TYPE';

        Test.startTest();

        String congaUrl = CongaService.get().getCongaUrl(caseRecord.Id, 'Acceptable_Behaviour_Contract', CongaService.ActionType.valueOf('CONGA_DOCU_SIGN_INPERSON_ACTION'));

        Assert.areEqual(true, congaUrl.containsIgnoreCase('DocuSignR1SignNow=1'), 'Conga Url must have in-person param in url with DocuSignR1SignNow=1');

        Assert.areEqual(true, congaUrl.containsIgnoreCase('DocusignR1SIPName=Test'), 'Conga Url must have in-person param in url with DocusignR1SIPName=Test');

        Test.stopTest();
    }
}