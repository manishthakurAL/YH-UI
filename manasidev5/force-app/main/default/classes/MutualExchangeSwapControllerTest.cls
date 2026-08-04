@isTest
public class MutualExchangeSwapControllerTest {
    
    @TestSetup
    static void makeData(){

        System.runAs(UthUser.getSchemeUserForManagedMoveAndSchemes(UserInfo.getUserId())) {
            UthFeatureSwitches.enableManagedMoveRT();
            Account pAccount = UthAccount.build();
            insert pAccount;

            Contact pContact = UthContact.build(pAccount.Id);
            insert pContact;

            Case testCase = UthCase.buildManagedMoveCase(pContact.Id);
            insert testCase;
            
            YH_Property__c property = UthProperty.buildHousingPurposeProperty(
                    PropertyDecorator.AUTHORITY_BARNSLEY,
                    PropertyDecorator.AUTHCODE_E08000038,
                    null);
            insert property; 

            YH_Tenancy__c tenancy = UthTenancy.build(property.Id, false, null);
            insert tenancy;

            YH_Mutual_Exchange__c internalExchange = UthMutualExchange.buildInternalProperty(testCase.Id, '1234',property.id);
            insert internalExchange;

            YH_Mutual_Exchange__c externalExchange = UthMutualExchange.buildExternalProperty(testCase.Id, '56789');
            insert externalExchange;
        }
    }

    @isTest  
    static void test_mutualExchangeCtrl(){
        Test.startTest();   
            Id caseId = UthCase.getAll()[0].Id;
            SObject[] exchangeswaps = MutualExchangeSwapController.getMutualExchange(caseId);
            MutualExchangeSwapController.saveNewMapping(JSON.serialize(exchangeswaps));
            Assert.areEqual(2, exchangeswaps.size(), 'Must return 2 exchange records.');
        Test.stopTest();
    }
}