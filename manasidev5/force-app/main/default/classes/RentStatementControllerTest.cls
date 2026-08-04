@IsTest

public class RentStatementControllerTest {
    @TestSetup
    static void makeData() {
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User accountOwner = UthUser.buildUser(roleId,adminProfileId,'fname1','lname1');
        insert accountOwner;
        System.runAs(accountOwner) {
            TriggerBase.bypass('Account');
            TriggerBase.bypass('YH_Tenancy__c');
            Account acc = UthAccount.buildPersonAccount('John', 'Test','123 Test St','London','AB123CD');
            acc.ownerId = accountOwner.Id;
            insert acc;
            YH_Property__c property = UthProperty.buildPropertyWithAssetClass('Leeds',
                    PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
                    PropertyDecorator.RENT_TYPE_MARKET_RENT, PropertyDecorator.PRODUCT_TYPE_MARKETRENTAL,
                    '123 Test St', 'London', 'AB123CD',PropertyDecorator.FLAT_ASSET_CLASS);
            insert property;
            YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO, '123456');
            insert tenancy;
            YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];
			Group tenancyGroup = UthGroup.build('TenancySharing' + resultTenancy.Name.replace('-', '_'));
            insert tenancyGroup;

            YH_Tenancy__Share tenancyShare = UthTenancyShare.build(resultTenancy.Id, tenancyGroup.Id);
            insert tenancyShare;
            Date occupancyStartDate = Date.newInstance(2024, 12, 01);
            insert UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('John','Test')[0].Id,tenancy.Id,MemberDecorator.TYPE_SOLO, occupancyStartDate);
            
            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('YH_Tenancy__c');
        }
    }
    
    @isTest
    static void testgetTenancies(){
        YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
        List<Contact> contactList = UthContact.getAll();
        User cUser = UthUser.buildPortalUser('fname','lname',contactList[0].Id);
        insert cUser;
        String tenancyName = new TenancyService().getGroupName(tenancy.Name);
        List<Group> resultGroup = UthGroup.getGroupUsingName(tenancyName);
        
        List<GroupMember> groupMembersToInsert = new List<GroupMember>{
            UthGroupMember.build(resultGroup[0].Id,cUser.Id)
        };
        insert groupMembersToInsert;
        System.runAs(cUser){
            Test.startTest();
                List<RentStatementController.TenancyWrapper> tenancyList = RentStatementController.getTenancies();
                System.assertEquals(1, tenancyList.size(), 'Size should be 1');
            	System.assertEquals('John Test', tenancyList[0].customerName, 'Customer name should be John Test');
           Test.stopTest();
        }
    }

    @IsTest
    static void testGetAccountsByTenancyNumber_Positive() {
        Test.setMock(HttpCalloutMock.class, new GetAccountsByTenancyNumberMock(200));
        YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
        List<Contact> contactList = UthContact.getAll();
        User cUser = UthUser.buildPortalUser('fname','lname',contactList[0].Id);
        insert cUser;
        String tenancyName = new TenancyService().getGroupName(tenancy.Name);
        List<Group> resultGroup = UthGroup.getGroupUsingName(tenancyName);
        
        List<GroupMember> groupMembersToInsert = new List<GroupMember>{
            UthGroupMember.build(resultGroup[0].Id,cUser.Id)
        };
        insert groupMembersToInsert;
        System.runAs(cUser){
            Test.startTest();
                List<RentStatementController.AccountWrapper> result =
                    RentStatementController.getAccountsByTenancyNumber('123456','1');
            Test.stopTest();
            System.assertNotEquals(null, result, 'Result should not be null');
            System.assertEquals(2, result.size(), 'Two accounts should be returned');
            RentStatementController.AccountWrapper acc = result[0];
            System.assertEquals('0', acc.id);
            System.assertEquals('Main Account', acc.accountDescription);
            System.assertEquals('2023-01-01', acc.occupancyCommenced);
            System.assertEquals('2023-01-02', acc.occupancyTerminated);
            System.assertEquals(100.0, acc.accountBalance);
        }
    }
    
    @IsTest
	static void testGetAccountsByTenancyNumberError() {
        Boolean exceptionThrown = false;
    	Test.setMock(HttpCalloutMock.class, new GetAccountsByTenancyNumberMock(404));
    	try {
            Test.startTest();
            List<RentStatementController.AccountWrapper> result =    
            	RentStatementController.getAccountsByTenancyNumber('12345','1');
            Test.stopTest();
    	} 
        catch (AuraHandledException ex) {
            exceptionThrown = true;
    	}
        System.assertEquals(true, exceptionThrown,
        		'AuraHandledException should be thrown on callout failure');
    }
    @IsTest
    static void testGetAccountsDetails_Positive() {
        Test.setMock(HttpCalloutMock.class, new GetTenancyAccountDetailsResponseMock(200, Date.newInstance(2023, 01, 01), Date.newInstance(2024, 01, 01)));
        YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
        List<Contact> contactList = UthContact.getAll();
        User cUser = UthUser.buildPortalUser('fname','lname',contactList[0].Id);
        insert cUser;
        String tenancyName = new TenancyService().getGroupName(tenancy.Name);
        List<Group> resultGroup = UthGroup.getGroupUsingName(tenancyName);
        
        List<GroupMember> groupMembersToInsert = new List<GroupMember>{
            UthGroupMember.build(resultGroup[0].Id,cUser.Id)
        };
        insert groupMembersToInsert;
        System.runAs(cUser){
            Test.startTest();
                String filter = '{"period":"all"}';
                String tenancyParm = '{"tenancyNumber":"123456","chargeFrequency":"Weekly","rentType":"Social Rent"}';
                RentStatementController.StatementsWrapper result =
                    RentStatementController.getStatements('0',tenancyParm,filter);
            Test.stopTest();
            System.assertEquals(1, result.totalCount);
            System.assertEquals(141.91, result.statements[0].balance);
            System.assertEquals('31 Jul 2025', result.statements[0].balanceDate);
            System.assertEquals(714.82, result.statements[0].rent.amount);
            System.assertEquals('10 Jul 2025', result.statements[0].rent.transactionDate);
            System.assertEquals(0.39, result.statements[0].charges.totalAmount);
            List<RentStatementController.TransactionWrapper> chargesTransactionList = result.statements[0].charges.chargesTransactions;
            System.assertEquals(2, chargesTransactionList.size());
            RentStatementController.TransactionWrapper charge1 ;
            RentStatementController.TransactionWrapper charge2 ;
            for(RentStatementController.TransactionWrapper chg : chargesTransactionList){
                if(chg.description == 'Administration'){
                    charge1 = chg;
                }
                else if(chg.description == 'Gardens & Grounds'){
                    charge2 = chg;
                }
            }
            System.assert(charge1 != null);
            System.assert(charge2 != null);
            System.assertEquals(0.09, charge1.amount);
            System.assertEquals('10 Jul 2025', charge1.transactionDate);
            System.assertEquals(0.3, charge2.amount);
            System.assertEquals('10 Jul 2025', charge2.transactionDate);
        }
    }
    @IsTest
	static void  testGetAccountsDetailsError() {
        Boolean exceptionThrown = false;
    	Test.setMock(HttpCalloutMock.class, new GetAccountsByTenancyNumberMock(404));
    	try {
            Test.startTest();
                String filter = '{"period":"all"}';
                RentStatementController.StatementsWrapper result =
                    RentStatementController.getStatements('123456','0',filter);
            Test.stopTest();
    	} 
        catch (AuraHandledException ex) {
            exceptionThrown = true;
    	}
        System.assertEquals(true, exceptionThrown,
        		'AuraHandledException should be thrown on callout failure');
    }

    @IsTest
    static void testGetAccountsDetail_PriorOccupancyDate() {
        Test.setMock(HttpCalloutMock.class, new GetTenancyAccountDetailsResponseMock(200, Date.newInstance(2023, 01, 01), Date.newInstance(2024, 01, 01)));
        YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
        List<Contact> contactList = UthContact.getAll();
        User customerUser = UthUser.buildPortalUser('fname','lname',contactList[0].Id);
        insert customerUser;
        String tenancyName = new TenancyService().getGroupName(tenancy.Name);
        List<Group> resultGroup = UthGroup.getGroupUsingName(tenancyName);
        
        List<GroupMember> groupMembersToInsert = new List<GroupMember>{
            UthGroupMember.build(resultGroup[0].Id,customerUser.Id)
        };
        insert groupMembersToInsert;
        System.runAs(customerUser){
            Test.startTest();
                String filter = '{"period":"custom","startDate":"2022-01-01","endDate":"2025-12-01"}';
                String tenancyParm = '{"tenancyNumber":"123456","chargeFrequency":"Weekly","rentType":"Social Rent"}';
                RentStatementController.StatementsWrapper result =
                    RentStatementController.getStatements('0',tenancyParm,filter);
            Test.stopTest();
            System.assertEquals(1, result.totalCount);
            System.assertEquals(141.91, result.statements[0].balance);
            System.assertEquals('31 Jul 2025', result.statements[0].balanceDate);
            System.assertEquals(714.82, result.statements[0].rent.amount);
            System.assertEquals('10 Jul 2025', result.statements[0].rent.transactionDate);
            System.assertEquals(0.39, result.statements[0].charges.totalAmount);
            List<RentStatementController.TransactionWrapper> chargesTransactionList = result.statements[0].charges.chargesTransactions;
            System.assertEquals(2, chargesTransactionList.size());
            RentStatementController.TransactionWrapper charge1 ;
            RentStatementController.TransactionWrapper charge2 ;
            for(RentStatementController.TransactionWrapper chg : chargesTransactionList){
                if(chg.description == 'Administration'){
                    charge1 = chg;
                }
                else if(chg.description == 'Gardens & Grounds'){
                    charge2 = chg;
                }
            }
            System.assert(charge1 != null);
            System.assert(charge2 != null);
            System.assertEquals(0.09, charge1.amount);
            System.assertEquals('10 Jul 2025', charge1.transactionDate);
            System.assertEquals(0.3, charge2.amount);
            System.assertEquals('10 Jul 2025', charge2.transactionDate);
        }
    }

    @isTest static void test_invalidTenancyNumber() {
        String invalidTenancyNumber = '677644';
        String expectedMessage = 'Oops! Something didn\'t load quite right. Please try again later.';
        String actualMessage;
        Test.startTest();
            try {
                RentStatementController.getAccountsByTenancyNumber(invalidTenancyNumber,'1');
            } catch (Exception ex) {
                actualMessage = ex.getMessage();
            }
        Test.stopTest();
        System.assertEquals(expectedMessage, actualMessage, 'AuraHandledException should be thrown for invalid tenancy number');
    }
}