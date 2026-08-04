@IsTest
public class ManageCustomerCaseSharingImplTest {
    @TestSetup
    static void setUpTestData(){
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.buildUser(roleId,adminProfileId,'fname1','lname1');
        insert adminUser;

        System.runAs(adminUser){
            TriggerBase.bypass('Account');
            TriggerBase.bypass('YH_Tenancy__c');
                insert new List<Account>{
                    UthAccount.buildPersonAccount('JohnOne', 'DoeOne','123 Test St','London','AB123CD'),
                    UthAccount.buildPersonAccount('JohnTwo', 'DoeTwo','123 Test St','London','AB123CD'),
                    UthAccount.buildPersonAccount('JohnThree', 'DoeThree','123 Test St','London','AB123CD')
                };
                
                YH_Property__c property = UthProperty.buildPropertyWithAssetClass('Leeds',
                        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
                        PropertyDecorator.RENT_TYPE_MARKET_RENT, PropertyDecorator.PRODUCT_TYPE_MARKETRENTAL,
                        '123 Test St', 'London', 'AB123CD',PropertyDecorator.FLAT_ASSET_CLASS);
                insert property;

                YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT);
        	    insert tenancy;

                YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];

                List<Contact> contacts = UthContact.getAll();

                List<User> userList = new List<User>{
                    UthUser.buildCommunityUser(contacts[0].Id,null),
                    UthUser.buildCommunityUser(contacts[1].Id,null),
                    UthUser.buildCommunityUser(contacts[2].Id,null)
                };
                insert userList;
            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('YH_Tenancy__c');
        }
    }

    @isTest
    static void testInsertPermissioCase(){
        YH_Tenancy__c tenancy = UthTenancy.getAll()[0];
        List<Contact> contacts = UthContact.getAll();
        Contact contactOne = contacts[0];

        Case caseRecord = UthCase.buildPermissionCaseWithTypeAndTenancyAndReporter(
                contactOne.Id, 
                tenancy.Id, 
                contactOne.Id, 
                CaseDecorator.CASE_TYPE_PERMISSION_FOR_A_LoDGER_OR_SUBLET);
        
        System.runAs(UthUser.getPermissionUser(UserInfo.getUserId())) {
            Test.startTest();
                insert caseRecord;
            Test.stopTest();
        }

        List<CaseShare> caseShares = UthCaseShare.getAllUsingCaseId(new List<Id>{caseRecord.Id});
        System.Assert.areEqual(1, caseShares.size());
    }

    @isTest
    static void testInsertBulkPermissioCase(){
        YH_Tenancy__c tenancy = UthTenancy.getAll()[0];
        List<Contact> contacts = UthContact.getAll();
        Contact contactOne = contacts[0];
        Contact contactTwo = contacts[1];
        Contact contactThree = contacts[2];

        List<Case> caseRecords = new List<Case>();
        for(Integer i = 0; i < contacts.size(); i++){
            Case caseRecord = UthCase.buildPermissionCaseWithTypeAndTenancyAndReporter(
                contacts[i].Id, 
                tenancy.Id, 
                contacts[i].Id, 
                CaseDecorator.CASE_TYPE_PERMISSION_FOR_A_LoDGER_OR_SUBLET);
            caseRecords.add(caseRecord);
        }
        
        System.runAs(UthUser.getPermissionUser(UserInfo.getUserId())) {
            Test.startTest();
                insert caseRecords;
            Test.stopTest();
        }

        List<CaseShare> caseShares = UthCaseShare.getAllUsingCaseId(new List<Id>{caseRecords[0].Id,caseRecords[1].Id, caseRecords[2].Id});
        System.Assert.areEqual(3, caseShares.size());
    }

    @isTest
    static void testInsertPermissioCaseWithContactChanges(){
        YH_Tenancy__c tenancy = UthTenancy.getAll()[0];
        List<Contact> contacts = UthContact.getAll();
        Contact contactOne = contacts[0];
        Contact contactTwo = contacts[1];

        Case caseRecord = UthCase.buildPermissionCaseWithTypeAndTenancyAndReporter(
                contactOne.Id, 
                tenancy.Id, 
                contactOne.Id, 
                CaseDecorator.CASE_TYPE_PERMISSION_FOR_A_LoDGER_OR_SUBLET);

        System.runAs(UthUser.getPermissionUser(UserInfo.getUserId())) {
            insert caseRecord;
            User user = UthUser.getUserUsingContactId(new List<Id>{contactOne.Id})[0];
            CaseShare caseShareToInsert = UthCaseShare.build(caseRecord.Id, user.Id);
            insert caseShareToInsert;

            List<CaseShare> caseShares = UthCaseShare.getAllUsingCaseId(new List<Id>{caseRecord.Id});
            System.Assert.areEqual(1, caseShares.size());

            Test.startTest();
                caseRecord.ContactID = contactTwo.Id;
                update caseRecord;
            Test.stopTest();
        }
        
        List<CaseShare> caseShares1 = UthCaseShare.getAllUsingCaseId(new List<Id>{caseRecord.Id});
        System.Assert.areEqual(1, caseShares1.size());
    }

    @isTest
    static void testInsertPermissioCaseWithoutPortalUser(){
        Case caseRecord;
        System.runAs(UthUser.getPermissionUser(UserInfo.getUserId())) {
            Account account = UthAccount.buildPersonAccount('JohnFour', 'DoeFour','123 Test St','London','AB123CD');
            insert account;
            YH_Tenancy__c tenancy = UthTenancy.getAll()[0];
            Contact contactOne = [SELECT Id FROM Contact WHERE AccountId = :account.Id LIMIT 1];

            caseRecord = UthCase.buildPermissionCaseWithTypeAndTenancyAndReporter(
                    contactOne.Id, 
                    tenancy.Id, 
                    contactOne.Id, 
                    CaseDecorator.CASE_TYPE_PERMISSION_FOR_A_LoDGER_OR_SUBLET);
        
        
            Test.startTest();
                insert caseRecord;
            Test.stopTest();
        }

        List<CaseShare> caseShares = UthCaseShare.getAllUsingCaseId(new List<Id>{caseRecord.Id});
        System.Assert.areEqual(0, caseShares.size());
    }
}