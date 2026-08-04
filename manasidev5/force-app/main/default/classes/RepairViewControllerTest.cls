@IsTest
public class RepairViewControllerTest {
	
   @TestSetup
    static void makeData() {
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User accountOwner = UthUser.buildUser(roleId, adminProfileId, 'fname', 'lname');
        insert accountOwner;
        System.runAs(accountOwner) {
            TriggerBase.bypass('Account');
            TriggerBase.bypass('YH_Tenancy__c');
            TriggerBase.bypass('Case');
            Account acc = UthAccount.buildPersonAccount('John', 'Test','123 Test St','London','AB123CD');
            acc.ownerId = accountOwner.Id;
            insert acc;
            YH_Property__c property = UthProperty.buildPropertyWithAssetClass('Leeds',
                    PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
                    PropertyDecorator.RENT_TYPE_MARKET_RENT, PropertyDecorator.PRODUCT_TYPE_MARKETRENTAL,
                    '123 Test St', 'London', 'AB123CD',PropertyDecorator.FLAT_ASSET_CLASS);
            property.YH_OrchardPropertyReferenceNumberOPRN__c = '56789';
            insert property;
            YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO, '123456');
            insert tenancy;
            YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];
			Group tenancyGroup = UthGroup.build('TenancySharing' + resultTenancy.Name.replace('-', '_'));
            insert tenancyGroup;

            YH_Tenancy__Share tenancyShare = UthTenancyShare.build(resultTenancy.Id, tenancyGroup.Id);
            insert tenancyShare;
            
            insert UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('John','Test')[0].Id,tenancy.Id,MemberDecorator.TYPE_SOLO);
            insert UthCase.buildAwaabsLawCase(UthContact.getAll()[0].Id,  UthTenancy.getAll()[0].Id);
            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('YH_Tenancy__c');
            TriggerBase.clearBypass('Case');
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
                List<RepairViewController.TenancyGroupWrapper> tenancyList = RepairViewController.getTenancies(null);
                System.assertEquals(1, tenancyList.size(), 'Size should be 1');
            	System.assertEquals('123456', tenancyList[0].tenancyNumber, 'Tenancy Number should match');
           Test.stopTest();
        }
    }

     @isTest
    static void testgetTenanciesWithRecordId(){
        YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
        List<Contact> contactList = UthContact.getAll();
        Test.startTest();
            List<RepairViewController.TenancyGroupWrapper> tenancyList = RepairViewController.getTenancies(UthCase.getAll()[0].Id);
            System.assertEquals(1, tenancyList.size(), 'Size should be 1');
            System.assertEquals('123456', tenancyList[0].tenancyNumber, 'Tenancy Number should match');
        Test.stopTest(); 
    }


    @IsTest
    static void testGetRepairsRelatedTenancy_Positive() {
        Test.setMock(HttpCalloutMock.class, new GetRepairHistoryListMock(200));
        Test.startTest();
        	Date fromDate = Date.today().addMonths(-24); 
        	Date toDate = Date.today(); 
            List<RepairViewController.RepairHistoryWrapper> result =
                RepairViewController.getRepairsRelatedTenancy('123456','56789','Open',fromDate,toDate);
        Test.stopTest();
        System.assertEquals(2, result.size(), 'Two repairs should be returned');
        RepairViewController.RepairHistoryWrapper repairWrap = result[0];
        System.assertEquals(2223810, repairWrap.jobNumber,'Job Number should be there');
        System.assertEquals('Yorkshire Housing', repairWrap.contractor,'Contractor should be Yorkshire Housing');
        System.assertEquals('31 Dec 2025', repairWrap.DateReported,'Date Reported should be there');
        System.assertEquals('Open', repairWrap.status,'status should be Open');
        System.assertEquals('DMC - AROUND THE WASHING MACHINE IN KITCHEN. TNT', repairWrap.description,'Description should be there');
    }
    
    @IsTest
	static void testGetRepairsRelatedTenancyError() {
        Boolean exceptionThrown = false;
        Exception auraException;
    	Test.setMock(HttpCalloutMock.class, new GetRepairHistoryListMock(404));
    	try {
            Test.startTest();
            Date fromDate = Date.today().addMonths(-24); 
        	Date toDate = Date.today(); 
            List<RepairViewController.RepairHistoryWrapper> result =
                RepairViewController.getRepairsRelatedTenancy('123456','56789','Open',fromDate,toDate);
            Test.stopTest();
    	} 
        catch (AuraHandledException ex) {
            exceptionThrown = true;
            auraException = ex;
    	}
        System.assertEquals(true, exceptionThrown,
        		'AuraHandledException should be thrown on callout failure');
        System.assert(auraException.getMessage().contains('Something did not load quite right'),
        		'Message should match');
    }

    @IsTest
    static void testGetRepairDetails_Positive() {
        Test.setMock(HttpCalloutMock.class, new GetRepairDetailsMock(200));
        Test.startTest();
            RepairViewController.RepairDetailDataWrapper result =
                RepairViewController.getRepairDetails('2223810');
        Test.stopTest();
        System.assertEquals(2223810, result.jobNumber,'Job Number should be there');
        System.assertEquals('31 Dec 2025', result.reportedOn,'Reported On date should be there');
        System.assertEquals('PLUMBER', result.repairType,'repair Type should be there');
        System.assertEquals('SEE NOTES', result.locationOfRepair,'Location should be there');
        System.assertEquals('Routine', result.priority,'Priority should be routine');
        System.assertEquals('31 Dec 2025', result.targetDate,'Target Date should be there');
		System.assertEquals('31 Dec 2025', result.completionDate,'Completion Date should be there');
        System.assertEquals('Yorkshire Housing', result.contractor,'Contractor should be Yorkshire Housing');
        List<RepairViewController.AppointmentsWrapper> appointmentList = result.appointments;
        System.assertEquals(2, appointmentList.size());
        RepairViewController.AppointmentsWrapper app1 ;
        RepairViewController.AppointmentsWrapper app2 ;
        for(RepairViewController.AppointmentsWrapper app : appointmentList){
            if(app.appointmentDate == '30 Dec 2025'){
                app1 = app;
            }
            else if(app.appointmentDate == '31 Dec 2025'){
                app2 = app;
            }
        }
        System.assert(app1 != null);
        System.assert(app2 != null);
        System.assertEquals('Appointment Complete', app1.status,'Appointment status should be Complete');
        System.assertEquals('PM', app2.timeSlot,'TimeSlot should be there');
        System.assertEquals('Appointment Complete', app1.status,'Appointment status should be Complete');
        System.assertEquals('PM', app2.timeSlot,'TimeSlot should be there');
    }
    @IsTest
	static void  testGetAccountsDetailsError() {
        Boolean exceptionThrown = false;
        Exception auraException;
    	Test.setMock(HttpCalloutMock.class, new GetRepairDetailsMock(404));
    	try {
            Test.startTest();
                RepairViewController.RepairDetailDataWrapper result =
                		RepairViewController.getRepairDetails('2223810');
            Test.stopTest();
    	} 
        catch (AuraHandledException ex) {
            exceptionThrown = true;
            auraException = ex;
    	}
        System.assertEquals(true, exceptionThrown,
        		'AuraHandledException should be thrown on callout failure');
        System.assert(auraException.getMessage().contains('Something did not load quite right'),
        		'Message should match');
    }
}