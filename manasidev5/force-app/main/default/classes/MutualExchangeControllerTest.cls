@isTest
public with sharing class MutualExchangeControllerTest {
    @TestSetup
    static void makeData(){
        System.runAs(UthUser.getSchemeUserForManagedMove(UserInfo.getUserId())) {
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
        }
    }

    @isTest
    static void test_saveMutualExchanges() {
        MutualExchangeController.PropertyWrapper internalProperty = new MutualExchangeController.PropertyWrapper(
            JSON.serialize(new Map<String, Object>{
                'propertyId' => UthProperty.getAll()[0].Id,
                'propertyType' => PropertyDecorator.PROPERTY_TYPE_INTERNAL
            })
        );

        MutualExchangeController.PropertyWrapper externalProperty = new MutualExchangeController.PropertyWrapper(
            JSON.serialize(new Map<String, Object>{
                'propertyType' => PropertyDecorator.PROPERTY_TYPE_EXTERNAL,
                'propertyStreet' => 'Street',
                'propertyCity' => 'city',
                'propertyPostalCode' => 'cr05jq',
                'propertyCountry' => 'GB',
                'propertyLandlord' => 'Test Landlord'
            })
        );

        MutualExchangeController.ApplicantWrapper appl = new MutualExchangeController.ApplicantWrapper(
            JSON.serialize(new Map<String, Object>{
                'applicantId' => UthContact.getAll()[0].Id,
                'tenantType' => MemberDecorator.TYPE_SOLO
            })
        );

        MutualExchangeController.MEXWrapper internalWrapper = new MutualExchangeController.MEXWrapper(
            internalProperty,
            new List<MutualExchangeController.ApplicantWrapper>{}
        );
        
        MutualExchangeController.MEXWrapper externalWrapper = new MutualExchangeController.MEXWrapper(
            externalProperty,
            new List<MutualExchangeController.ApplicantWrapper>{appl}
        );
       
        List<MutualExchangeController.MEXWrapper> wrapperList = new List<MutualExchangeController.MEXWrapper>{internalWrapper, externalWrapper};
        SObject[] props = MutualExchangeController.getPropertyMembers(UthProperty.getAll()[0].Id);
        Test.startTest();
            MutualExchangeController.saveMutualExchanges(UthCase.getAll()[0].Id, JSON.serialize(wrapperList));
        Test.stopTest();
        Assert.areEqual(2, UthMutualExchange.getAll().size(), 'Two MEX record must be created');
        YH_Mutual_Exchange__c externalProp = UthMutualExchange.getAllExternalPropertyType()[0];
        Assert.areEqual('Street', externalProp.ExternalAddress2__Street__s, 'EXternal MEX record must be created');
        Assert.areEqual('city', externalProp.ExternalAddress2__City__s, 'EXternal MEX record must be created');
        Assert.areEqual('cr05jq', externalProp.ExternalAddress2__PostalCode__s, 'EXternal MEX record must be created');

    } 
}