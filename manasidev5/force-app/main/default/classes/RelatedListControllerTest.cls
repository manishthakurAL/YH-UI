@isTest(seeAllData=false)
public with sharing class RelatedListControllerTest {
    
    @testSetup
    static void setUpTestData(){

        
        System.runAs(UthUser.getSchemeUserForManagedMoveAndSchemes(UserInfo.getUserId())) {

            UthFeatureSwitches.enableAllRT();
            TriggerBase.bypass('Account');
            TriggerBase.bypass('Contact');

            Account account = UthAccount.buildPersonAccount();
            insert account;
            List<Account> accountsList = UthAccount.getAll();

            Case safeGaurdingCaseRecord = UthCase.buildSafeguardingCase(accountsList[0].PersonContactId);
            insert safeGaurdingCaseRecord;

            CaseRole__c personAtRiskCaseRole = UthCaseRole.build(safeGaurdingCaseRecord.Id, accountsList[0].PersonContactId, CaseRoleDecorator.PERSONATRISK_ROLE);
            insert personAtRiskCaseRole;

            safeGaurdingCaseRecord = UthCase.buildSafeguardingCase(accountsList[0].PersonContactId);
            safeGaurdingCaseRecord.ReporterType__c = CaseRoleDecorator.PERSONATRISK_ROLE;
            insert safeGaurdingCaseRecord;

            Case schemeCaseRecord = UthCase.buildSchemeCase(accountsList[0].PersonContactId);
            insert schemeCaseRecord;

            CaseRole__c tenantCaseRole = UthCaseRole.build(schemeCaseRecord.Id, accountsList[0].PersonContactId, CaseRoleDecorator.TENANT_ROLE);
            insert tenantCaseRole;

            Case ManagedMoveCaseRecord = UthCase.buildManagedMoveCase(accountsList[0].PersonContactId);
            insert ManagedMoveCaseRecord;

            CaseRole__c tenantRequiringMoveCaseRole = UthCaseRole.build(ManagedMoveCaseRecord.Id, accountsList[0].PersonContactId, CaseRoleDecorator.TENANT_REQUIRING_MOVE_ROLE);
            insert tenantRequiringMoveCaseRole;

            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('Contact');
        }

        
    }

    @isTest
    static void test_getCases(){     
        Test.startTest();
        List<Account> accountsList = UthAccount.getAll();
        String recordTypes = CaseDecorator.RECORD_TYPE_SAFEGUARDING+','+CaseDecorator.RECORD_TYPE_SCHEMES+','+CaseDecorator.RECORD_TYPE_MANAGED_MOVE;
        Map<String, Object> objectsMap = RelatedListController.getCases(recordTypes,accountsList[0].Id);
        List<Case> casesList = (List<Case>)objectsMap.get('data');
        Test.stopTest();
        Assert.areEqual(4,casesList.size(),'size should be 4');
    }
}