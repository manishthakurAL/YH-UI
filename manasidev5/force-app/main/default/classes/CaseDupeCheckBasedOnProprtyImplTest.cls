@isTest(seeAllData=false)
public with sharing class CaseDupeCheckBasedOnProprtyImplTest {
   
    @testSetup
    static void setUpTestData(){
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
        
        Case tenancyCase = UthCase.buildTenancyCase(contactOne.Id, property.Id, CaseDecorator.CASE_TYPE_ABANDONED_PROPERTIES);
        insert tenancyCase;

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Case');
    }

    @isTest
    static void testCaseDupeCheckBasedOnProperty(){
        Map<Id, List<Case>> caseDups;
        Test.startTest();
            CaseDupeCheckBasedOnProprtyImpl impl = new CaseDupeCheckBasedOnProprtyImpl();
            caseDups = impl.getDuplicate(UthCase.getAll(), CaseDecorator.RECORD_TYPE_ID_TENANCY, CaseDecorator.CASE_TYPE_ABANDONED_PROPERTIES);
        Test.stopTest();
        YH_Property__c property = UthProperty.getAll().get(0);
        Assert.areEqual(False, caseDups.get(UthCase.getAll().get(0).Id).isEmpty(), 'Duplicated Case must be returned');
    }

    @isTest
    static void testCaseDupeCheckBasedOnPropertyUsingDuplicateService(){
        Map<Id, List<Case>> caseDups;
        Test.startTest();
            CaseDuplicateCheckerService srv = new CaseDuplicateCheckerService();
            caseDups = srv.getDuplicate(UthCase.getAll());
        Test.stopTest();
        YH_Property__c property = UthProperty.getAll().get(0);
        Assert.areEqual(False, caseDups.get(UthCase.getAll().get(0).Id).isEmpty(), 'Duplicated Case must be returned');
    }




        
}