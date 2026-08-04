@isTest(seeAllData=false)
public with sharing class CaseDupeCheckBasedOnTenancyImplTest {

    @testSetup
    static void setUpTestData() {
        UthFeatureSwitches.enableAllRT();

        TriggerBase.bypass('Account');
        TriggerBase.bypass('Case');

        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccount('fNameOne', 'lNameOne'));
        insert accountList;

        Contact contactOne = UthContact.getAll().get(0);

        YH_Property__c property = uthProperty.buildPropertyWithDesignAssumptions(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE,
            PropertyDecorator.AUTHCODE_E08000038,
            PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
            PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE
        );
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT);
        insert tenancy;

        Member__c member = UthMember.build(contactOne.Id, tenancy.Id, MemberDecorator.TYPE_SOLO);
        insert member;

        Case terminationCase = UthCase.buildTerminationCase(contactOne.Id, tenancy.Id);
        insert terminationCase;

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Case');
    }

    @isTest
    static void testCaseDupeCheckBasedOnTenancyImpl() {
        List<Case> existingCases = [SELECT Id, Tenancy__c, ContactId FROM Case WHERE CaseType__c = :CaseDecorator.TYPE_TERMINATION LIMIT 1];
        Id tenancyId = existingCases[0].Tenancy__c;

        Case duplicateCase = UthCase.buildTerminationCase(existingCases[0].ContactId, tenancyId);

        List<Case> caseCreationCases = new List<Case>(); 
        caseCreationCases.add(duplicateCase); 

        Test.startTest();
            CaseDupeCheckBasedOnTenancyImpl impl = new CaseDupeCheckBasedOnTenancyImpl();
            Map<Id, List<Case>> caseDupes = impl.getDuplicate(
                caseCreationCases,
                CaseDecorator.RECORD_TYPE_ID_TERMINATION,
                CaseDecorator.TYPE_TERMINATION
            );
        Test.stopTest();

        Boolean foundDupe = false;
        for (Case c : caseDupes.get(null)) {
            if (c.Tenancy__c == tenancyId) {
                foundDupe = true;
                break;
            }
        }
        System.assert(foundDupe, 'Expected at least one case with matching Tenancy__c');    
    }

    @isTest
    static void testCaseDupeCheckBasedOnTenancyImpl_NoDuplicatesWithDifferentTenancy() {

    Case existingCase = [SELECT Id, Tenancy__c, ContactId FROM Case WHERE CaseType__c = :CaseDecorator.TYPE_TERMINATION LIMIT 1];

    YH_Property__c property = uthProperty.buildPropertyWithDesignAssumptions(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE,
            PropertyDecorator.AUTHCODE_E08000038,
            PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
            PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE
        );
    insert property;

    YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
    insert tenancy;

    Member__c newMember = UthMember.build(existingCase.ContactId, tenancy.Id, MemberDecorator.TYPE_SOLO);
    insert newMember;

    Case newCase = UthCase.buildTerminationCase(existingCase.ContactId, tenancy.Id);

    List<Case> caseCreationCases = new List<Case> {newCase};

    Test.startTest();
        CaseDupeCheckBasedOnTenancyImpl impl = new CaseDupeCheckBasedOnTenancyImpl();
        Map<Id, List<Case>> caseDupes = impl.getDuplicate(
            caseCreationCases,
            CaseDecorator.RECORD_TYPE_ID_TERMINATION,
            CaseDecorator.TYPE_TERMINATION
        );
    Test.stopTest();
    System.assert(caseDupes.get(null).isEmpty(), 'Expected no duplicate cases for different tenancy');
    }
}