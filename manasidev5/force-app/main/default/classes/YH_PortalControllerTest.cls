@IsTest
public class YH_PortalControllerTest {

    @TestSetup
    static void setupTestData() {
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.buildUser(roleId, adminProfileId, 'fname1', 'lname1');
        insert adminUser;

        System.runAs(adminUser) {
            TriggerBase.bypass('Account');
            insert UthAccount.buildPersonAccount('Jane', 'Doe', 'janedoe9876543210@randomemail.random');
            TriggerBase.clearBypass('Account');

            Contact con = UthContact.getContactByName('Jane', 'Doe')[0];
            insert UthUser.buildCommunityUser(con.Id, con.Email);
        }
    }

    @IsTest
    static void getMyOpenCasesReturnsMostRecentOpenCasesTest() {
        Contact con = UthContact.getContactByName('Jane', 'Doe')[0];
        User portalUser = UthUser.getUserUsingContactId(new List<Id>{ con.Id })[0];

        Case oldestOpenCase = UthCase.build(con.Id);
        oldestOpenCase.ExternalCaseStatus__c = CaseDecorator.EXTERNAL_STATUS_INPROGRESS;
        oldestOpenCase.CaseType__c = CaseDecorator.CASE_TYPE_CUSTOMER_EXPERIENCE_CENTRE;

        Case middleOpenCase = UthCase.build(con.Id);
        middleOpenCase.ExternalCaseStatus__c = CaseDecorator.EXTERNAL_STATUS_INPROGRESS;
        middleOpenCase.CaseType__c = CaseDecorator.CASE_TYPE_CUSTOMER_EXPERIENCE_CENTRE;

        Case newestOpenCase = UthCase.build(con.Id);
        newestOpenCase.ExternalCaseStatus__c = CaseDecorator.EXTERNAL_STATUS_INPROGRESS;
        newestOpenCase.CaseType__c = CaseDecorator.CASE_TYPE_CUSTOMER_EXPERIENCE_CENTRE;
        newestOpenCase.Description = 'Leaking kitchen tap';

        Case closedCase = UthCase.build(con.Id);
        closedCase.ExternalCaseStatus__c = CaseDecorator.EXTERNAL_STATUS_CLOSED;
        closedCase.CaseType__c = CaseDecorator.CASE_TYPE_CUSTOMER_EXPERIENCE_CENTRE;

        TriggerBase.bypass('Case');
        insert new List<Case>{ oldestOpenCase, middleOpenCase, newestOpenCase, closedCase };
        TriggerBase.clearBypass('Case');

        Test.setCreatedDate(oldestOpenCase.Id, Datetime.now().addDays(-3));
        Test.setCreatedDate(middleOpenCase.Id, Datetime.now().addDays(-2));
        Test.setCreatedDate(newestOpenCase.Id, Datetime.now().addDays(-1));
        Test.setCreatedDate(closedCase.Id, Datetime.now());

        UthCase.createCaseShareRecords(oldestOpenCase.Id, portalUser.Id, 'Read', 'Manual');
        UthCase.createCaseShareRecords(middleOpenCase.Id, portalUser.Id, 'Read', 'Manual');
        UthCase.createCaseShareRecords(newestOpenCase.Id, portalUser.Id, 'Read', 'Manual');
        UthCase.createCaseShareRecords(closedCase.Id, portalUser.Id, 'Read', 'Manual');

        Map<Id, Case> insertedCasesById = new Map<Id, Case>([
            SELECT CaseNumber, CaseType__c
            FROM Case
            WHERE Id IN :new List<Case>{ oldestOpenCase, middleOpenCase, newestOpenCase, closedCase }
        ]);
        newestOpenCase = insertedCasesById.get(newestOpenCase.Id);
        middleOpenCase = insertedCasesById.get(middleOpenCase.Id);

        List<YH_PortalController.OpenCaseDisplay> result;
        System.runAs(portalUser) {
            Test.startTest();
            result = YH_PortalController.getMyOpenCases();
            Test.stopTest();
        }

        Assert.areEqual(2, result.size(), 'Should return at most 2 open cases');
        Assert.areEqual(newestOpenCase.CaseNumber, result[0].caseNumber, 'Most recently opened case should be first');
        Assert.areEqual(newestOpenCase.CaseType__c, result[0].caseType, 'Case type should be populated');
        Assert.areEqual('Leaking kitchen tap', result[0].description, 'Description should be populated');
        Assert.areEqual(CaseDecorator.EXTERNAL_STATUS_INPROGRESS, result[0].status, 'Status should be the external case status');
        Assert.areEqual(middleOpenCase.CaseNumber, result[1].caseNumber, 'Second most recently opened case should be second');
    }

    @IsTest
    static void getMyOpenCasesWithNoCasesReturnsEmptyListTest() {
        Contact con = UthContact.getContactByName('Jane', 'Doe')[0];
        User portalUser = UthUser.getUserUsingContactId(new List<Id>{ con.Id })[0];

        List<YH_PortalController.OpenCaseDisplay> result;
        System.runAs(portalUser) {
            Test.startTest();
            result = YH_PortalController.getMyOpenCases();
            Test.stopTest();
        }

        Assert.areEqual(0, result.size(), 'Should return an empty list when the user has no open cases');
    }

    @IsTest
    static void getMyOpenCasesWithoutContactReturnsEmptyListTest() {
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User userWithoutContact = UthUser.buildUser(roleId, adminProfileId, 'fname2', 'lname2');
        insert userWithoutContact;

        List<YH_PortalController.OpenCaseDisplay> result;
        System.runAs(userWithoutContact) {
            Test.startTest();
            result = YH_PortalController.getMyOpenCases();
            Test.stopTest();
        }

        Assert.areEqual(0, result.size(), 'Should return an empty list when the running user has no Contact');
    }
}
