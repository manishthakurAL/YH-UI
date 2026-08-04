@isTest
public class AccountAndTenancyAddressMatchServiceTest {
	
    @TestSetup
    static void makeData() {
            TriggerBase.bypass('Account');
            TriggerBase.bypass('YH_Tenancy__c');
        	insert new List<Account>{
                UthAccount.buildPersonAccount('John', 'Doe','123 Test St','London','AB12 3CD'),
                UthAccount.buildPersonAccount('James', 'Fiorello','123 Test St','London','AB12 3CD'),
                UthAccount.buildPersonAccount('Tim', 'Hortons','15 Drive','Shenfield','SN12 3FN')
            };
            Yh_Property__c Property = UthProperty.buildPropertyWithAssetClass('Leeds',
                    PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
                    PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT, PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL,
                	'123 Test St', 'London', 'AB123CD',PropertyDecorator.FLAT_ASSET_CLASS);
        	insert Property;
        	YH_Tenancy__c tenancy = UthTenancy.build(Property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT);
        	insert tenancy;
            List<Member__c> memberList = new List<Member__c>{
            	UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('John','Doe')[0].Id,tenancy.Id,MemberDecorator.TYPE_JOINT),
                UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('James','Fiorello')[0].Id,tenancy.Id,MemberDecorator.TYPE_JOINT)
        	};
        	insert memberList;
            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('YH_Tenancy__c');
        }
        
		@isTest
        static void testFindDuplicatesPositive(){
        	Map<String, List<Account>> accountsBySourceKey = new Map<String, List<Account>>();
			Account acc1 = UthAccount.buildPersonAccount('John', 'Doe','123 Test St','London','AB12 3CD');
        	accountsBySourceKey.put('KEY1', new List<Account>{ acc1 });

        	Test.startTest();
            Map<String, AccountAndTenancyAddressMatchService.AccountAndAddressMatchingResponse> result = new Map<String, AccountAndTenancyAddressMatchService.AccountAndAddressMatchingResponse>();
        	result = new AccountAndTenancyAddressMatchService(accountsBySourceKey).findMatch();
        	Test.stopTest();

            Contact con = UthContact.getContactByName('John','Doe')[0];
            Member__c member = UthMember.getMembersByContactId(con.Id)[0];
            System.assertEquals(result.containsKey('KEY1'),true, 'KEY1 should be present');
            System.assertEquals(member.Tenancy__c, result.get('KEY1').tenancy.Id, 'Tenancy Id should match');
            System.assertEquals(con.AccountId, result.get('KEY1').accountId, 'Account Id should match');

    	}
        @isTest
        static void testFindDuplicatesNagative(){
            Map<String, List<Account>> accountsBySourceKey = new Map<String, List<Account>>();
			Account acc1 = UthAccount.buildPersonAccount('John', 'Dee','Mont Drive','London','RM8 7ED');
        	accountsBySourceKey.put('KEY1', new List<Account>{ acc1 });

        	Test.startTest();
        	Map<String, AccountAndTenancyAddressMatchService.AccountAndAddressMatchingResponse> result = new Map<String, AccountAndTenancyAddressMatchService.AccountAndAddressMatchingResponse>();
        	result = new AccountAndTenancyAddressMatchService(accountsBySourceKey).findMatch();
        	Test.stopTest();

            System.assertEquals(result.containsKey('KEY1'),false, 'KEY1 should not be present');
        }
    	@isTest
        static void testFindDuplicatesMultiplePositive(){
        	Map<String, List<Account>> accountsBySourceKey = new Map<String, List<Account>>();
			Account acc1 = UthAccount.buildPersonAccount('Sian', 'Doe','123 Test St','London','AB12 3CD');
            Account acc2 = UthAccount.buildPersonAccount('John', 'Doe','123 Test St','London','AB12 3CD');
            Account acc3 = UthAccount.buildPersonAccount('Sian', 'Doe','15 Drive','Shenfield','SN12 3FN');
            Account acc4 = UthAccount.buildPersonAccount('Tim', 'Hort','15 Drive','Shenfield','SN12 3FN');
       
            accountsBySourceKey.put('KEY1', new List<Account>{ acc1, acc2 });
        	accountsBySourceKey.put('KEY2', new List<Account>{ acc3, acc4});

        	Test.startTest();
            Map<String, AccountAndTenancyAddressMatchService.AccountAndAddressMatchingResponse> result = new Map<String, AccountAndTenancyAddressMatchService.AccountAndAddressMatchingResponse>();
        	result = new AccountAndTenancyAddressMatchService(accountsBySourceKey).findMatch();
        	Test.stopTest();

            Contact con = UthContact.getContactByName('John','Doe')[0];
            Member__c member = UthMember.getMembersByContactId(con.Id)[0];
            System.assertEquals(result.containsKey('KEY1'), true , 'KEY1 should be present');
            System.assertEquals(member.Tenancy__c, result.get('KEY1').tenancy.Id, 'Tenancy Id should match');
            System.assertEquals(con.AccountId, result.get('KEY1').accountId, 'Account Id should match');
            System.assertEquals(result.containsKey('KEY2'),false, 'KEY2 should not be present as there is no match');
    	}
}