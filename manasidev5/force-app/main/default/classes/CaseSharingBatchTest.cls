@IsTest
public class CaseSharingBatchTest {
    /*  Test Methods implemented as part of US-34683.
     *  Commented as part of US-37607
     * 	Reason for Commenting : This code is intentially commented out as future enhancements may require Breach and ASB Cases to be shared. 
    @TestSetup
    static void setUpTestData(){
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.buildUser(roleId,adminProfileId,'fname1','lname1');
        insert adminUser;

        System.runAs(adminUser){
            OrgSetting__c orgSetting = OrgSetting__c.getOrgDefaults();
            orgSetting.CaseSharingOffsetDays__c  = -6;
            upsert orgSetting;
            
            TriggerBase.bypass('Account');
            TriggerBase.bypass('YH_Tenancy__c');
            TriggerBase.bypass('Case');
                insert new List<Account>{
                    UthAccount.buildPersonAccount('JohnOne', 'DoeOne','123 Test St','London','AB123CD'),
                    UthAccount.buildPersonAccount('JohnTwo', 'DoeTwo','123 Test St','London','AB123CD'),
                    UthAccount.buildPersonAccount('JohnThree', 'DoeThree','123 Test St','London','AB123CD'),
                    UthAccount.buildPersonAccount('JohnFour', 'DoeGour','123 Test St','London','AB123CD')
                };
                
                YH_Property__c property = UthProperty.buildPropertyWithAssetClass('Leeds',
                        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
                        PropertyDecorator.RENT_TYPE_MARKET_RENT, PropertyDecorator.PRODUCT_TYPE_MARKETRENTAL,
                        '123 Test St', 'London', 'AB123CD',PropertyDecorator.FLAT_ASSET_CLASS);
                insert property;

                YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT);
        	    insert tenancy;

                List<Contact> contacts = UthContact.getAll();
                List<Case> caseRecords = new List<Case>();
                for(Integer i = 0; i < contacts.size(); i++){
                    Case caseRecord = UthCase.buildBreachAndASBCase(contacts[i].Id);
                    caseRecords.add(caseRecord);
                }
                insert caseRecords;
                
            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('YH_Tenancy__c');
            TriggerBase.clearBypass('Case');
        }
    }

    @isTest
    static void testCaseSharingBatchCreatedDateGreaterThanSix(){
        Datetime sevenDaysAgo = Datetime.now().addDays(-7);
        List<Case> Cases = UthCase.getAll();

        for(Case caseRecord : cases){
            Test.setCreatedDate(caseRecord.Id, sevenDaysAgo);
        }

        System.runAs((new User(Id = UserInfo.getUserId()))){
            Test.startTest();
                CaseSharingBatch batch = new CaseSharingBatch(10);
                batch.chatterImpl = new MockChatterPoster();
                Database.executeBatch(batch);
            Test.stopTest();
        }

        List<Case> resultCases = UthCase.getAll();
        Assert.areEqual(CaseDecorator.RECORD_TYPE_BREACH, resultCases[0].CaseReadyForSharing__c, 'CaseBreachAntiSocialBehaviourRT should be populated');
        Assert.areEqual(CaseDecorator.RECORD_TYPE_BREACH, resultCases[1].CaseReadyForSharing__c, 'CaseBreachAntiSocialBehaviourRT should be populated');
        Assert.areEqual(CaseDecorator.RECORD_TYPE_BREACH, resultCases[2].CaseReadyForSharing__c, 'CaseBreachAntiSocialBehaviourRT should be populated');
        Assert.areEqual(CaseDecorator.RECORD_TYPE_BREACH, resultCases[3].CaseReadyForSharing__c, 'CaseBreachAntiSocialBehaviourRT should be populated');
        Assert.areEqual(true, resultCases[0].CustomerSharingReasons__c.contains('Accused Party'), 'Customer sharing reason should be populated');
        Assert.areEqual(true, resultCases[1].CustomerSharingReasons__c.contains('Accused Party'), 'Customer sharing reason should be populated');
        Assert.areEqual(true, resultCases[2].CustomerSharingReasons__c.contains('Accused Party'), 'Customer sharing reason should be populated');
        Assert.areEqual(true, resultCases[3].CustomerSharingReasons__c.contains('Accused Party'), 'Customer sharing reason should be populated');
    }

    @isTest
    static void testCaseSharingBatchCreatedDateSix(){
        Datetime sixDaysAgo = Datetime.now().addDays(-6);
        List<Case> Cases = UthCase.getAll();

        for(Case caseRecord : cases){
            Test.setCreatedDate(caseRecord.Id, sixDaysAgo);
        }

        System.runAs((new User(Id = UserInfo.getUserId()))){
            Test.startTest();
                CaseSharingBatch batch = new CaseSharingBatch(10);
                batch.chatterImpl = new MockChatterPoster();
                Database.executeBatch(batch);
            Test.stopTest();
        }

        List<Case> resultCases = UthCase.getAll();
        Assert.areEqual(null, resultCases[0].CaseReadyForSharing__c, 'CaseBreachAntiSocialBehaviourRT should be not populated');
        Assert.areEqual(null, resultCases[1].CaseReadyForSharing__c, 'CaseBreachAntiSocialBehaviourRT should be not populated');
        Assert.areEqual(null, resultCases[2].CaseReadyForSharing__c, 'CaseBreachAntiSocialBehaviourRT should be not populated');
        Assert.areEqual(null, resultCases[3].CaseReadyForSharing__c, 'CaseBreachAntiSocialBehaviourRT should be not populated');
        Assert.isNull(resultCases[0].CustomerSharingReasons__c, 'Customer sharing reason should not be populated');
        Assert.isNull(resultCases[1].CustomerSharingReasons__c, 'Customer sharing reason should not be populated');
        Assert.isNull(resultCases[2].CustomerSharingReasons__c, 'Customer sharing reason should not be populated');
        Assert.isNull(resultCases[3].CustomerSharingReasons__c, 'Customer sharing reason should not be populated');
    }

     @isTest
    static void testCaseSharingBatchMixedScenario(){
        Datetime sevenDaysAgo = Datetime.now().addDays(-7);
        Datetime sixDaysAgo = Datetime.now().addDays(-6);
        Datetime today = Datetime.now();
        List<Case> Cases = UthCase.getAll();

        Test.setCreatedDate(Cases[0].Id, sevenDaysAgo);
        Test.setCreatedDate(Cases[1].Id, sevenDaysAgo);
        Test.setCreatedDate(Cases[2].Id, sixDaysAgo);
        Test.setCreatedDate(Cases[3].Id, today);

        System.runAs((new User(Id = UserInfo.getUserId()))){
            Test.startTest();
                CaseSharingBatch batch = new CaseSharingBatch(10);
                batch.chatterImpl = new MockChatterPoster();
                Database.executeBatch(batch);
            Test.stopTest();
        }

        List<Case> resultCases = UthCase.getAll();
        Assert.areEqual(CaseDecorator.RECORD_TYPE_BREACH, resultCases[0].CaseReadyForSharing__c, 'CaseBreachAntiSocialBehaviourRT should be populated');
        Assert.areEqual(CaseDecorator.RECORD_TYPE_BREACH, resultCases[1].CaseReadyForSharing__c, 'CaseBreachAntiSocialBehaviourRT should be populated');
        Assert.areEqual(null, resultCases[2].CaseReadyForSharing__c, 'CaseBreachAntiSocialBehaviourRT should be not populated');
        Assert.areEqual(null, resultCases[3].CaseReadyForSharing__c, 'CaseBreachAntiSocialBehaviourRT should be not populated');
        Assert.areEqual(true, resultCases[0].CustomerSharingReasons__c.contains('Accused Party'), 'Customer sharing reason should be populated');
        Assert.areEqual(true, resultCases[1].CustomerSharingReasons__c.contains('Accused Party'), 'Customer sharing reason should be populated');
        Assert.isNull(resultCases[2].CustomerSharingReasons__c, 'Customer sharing reason should be not populated');
        Assert.isNull(resultCases[3].CustomerSharingReasons__c, 'Customer sharing reason should be not populated');
    }

    private class MockChatterPoster implements ChatterInterface { 
        public ConnectApi.BatchResult[] postToChatterFeedBatchResults(Id subjectId, List<String> messages) {  
           return new List<ConnectApi.BatchResult>();
        }  
    }
	*/
}