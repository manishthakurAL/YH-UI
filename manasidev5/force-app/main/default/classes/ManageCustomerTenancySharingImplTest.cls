@IsTest
public class ManageCustomerTenancySharingImplTest {

    @TestSetup
    static void setUpTestData(){
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.buildUser(roleId,adminProfileId,'fname1','lname1');
        insert adminUser;

        System.runAs(adminUser){
            TriggerBase.bypass('Account');
                insert new List<Account>{
                    UthAccount.buildPersonAccount('John', 'Doe','123 Test St','London','AB123CD'),
                    UthAccount.buildPersonAccount('James', 'Fiorello','123 Test St','London','AB123CD')
                };
                
                YH_Property__c property = UthProperty.buildPropertyWithAssetClass('Leeds',
                        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
                        PropertyDecorator.RENT_TYPE_MARKET_RENT, PropertyDecorator.PRODUCT_TYPE_MARKETRENTAL,
                        '123 Test St', 'London', 'AB123CD',PropertyDecorator.FLAT_ASSET_CLASS);
                insert property;

                List<Contact> contacts = UthContact.getAll();

                List<User> userList = new List<User>{
                    UthUser.buildCommunityUser(contacts[0].Id,null),
                    UthUser.buildCommunityUser(contacts[1].Id,null)
                };
                insert userList;
            TriggerBase.clearBypass('Account');
        }
    }

    @isTest
    static void activeTenancyInsertTest(){

        YH_Property__c property = UthProperty.getAll()[0];

        Test.startTest();
            Test.getEventBus().deliver();
            YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT);
            insert tenancy;
            Test.getEventBus().deliver();
        Test.stopTest();

        YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];
        
        String tenancyName = new TenancyService().getGroupName(resultTenancy.Name);
        List<Group> resultGroup = UthGroup.getGroupUsingName(tenancyName);
        List<YH_Tenancy__Share> shareRecords = UthTenancyShare.getAll();

        system.debug('YH LOGS this.shareRecords ' + shareRecords);
        
        System.assertEquals(1, resultGroup.size(), 'One group with tenancyname should exist');
        System.assertEquals(1, shareRecords.size(), 'One YH_Tenancy__Share should exist');
        System.assertEquals(TenancyShareDecorator.ACCESSLEVEL_READ, shareRecords[0].AccessLevel, 'Access level shoud be Read');
        System.assertEquals(resultGroup[0].Id, shareRecords[0].UserOrGroupId, 'UserOrGroupId should be the group id');
        System.assertEquals(resultTenancy.Id, shareRecords[0].ParentId, 'ParentId should be the tenancy id');
        System.assertEquals('Tenancy__c', shareRecords[0].RowCause, 'Rowcase should be Tenancy__c');
    }

    @isTest
    static void activeTenancyUpdateTest(){

        YH_Property__c property = UthProperty.getAll()[0];
        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, false, TenancyDecorator.TENANCY_TYPE_JOINT);
        insert tenancy;

        Test.startTest();
            Test.getEventBus().deliver();
            tenancy.Active__c = true;
            update tenancy;
            Test.getEventBus().deliver();
        Test.stopTest();

        YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];
        
        String tenancyName = new TenancyService().getGroupName(resultTenancy.Name);
        List<Group> resultGroup = UthGroup.getGroupUsingName(tenancyName);
        List<YH_Tenancy__Share> shareRecords = UthTenancyShare.getAll();

        System.assertEquals(1, resultGroup.size(), 'One group with tenancyname should exist');
        System.assertEquals(1, shareRecords.size(), 'One YH_Tenancy__Share should exist');
        System.assertEquals(TenancyShareDecorator.ACCESSLEVEL_READ, shareRecords[0].AccessLevel, 'Access level shoud be Read');
        System.assertEquals(resultGroup[0].Id, shareRecords[0].UserOrGroupId, 'UserOrGroupId should be the group id');
        System.assertEquals(resultTenancy.Id, shareRecords[0].ParentId, 'ParentId should be the tenancy id');
        System.assertEquals('Tenancy__c', shareRecords[0].RowCause, 'Rowcase should be Tenancy__c');
        
    }

    @isTest
    static void activeTenancyUpdateGroupExistWitoutShareTest(){

        YH_Property__c property = UthProperty.getAll()[0];
        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, false, TenancyDecorator.TENANCY_TYPE_JOINT);
        insert tenancy;

        YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];
        String tenancyName = new TenancyService().getGroupName(resultTenancy.Name);
        insert UthGroup.build(tenancyName);

        Test.startTest();
            Test.getEventBus().deliver();
            tenancy.Active__c = true;
            update tenancy;
            Test.getEventBus().deliver();
        Test.stopTest();
        
        
        List<Group> resultGroup = UthGroup.getGroupUsingName(tenancyName);
        List<YH_Tenancy__Share> shareRecords = UthTenancyShare.getAll();

        System.assertEquals(1, resultGroup.size(), 'One group with tenancyname should exist');
        System.assertEquals(1, shareRecords.size(), 'One YH_Tenancy__Share should exist');
        System.assertEquals(TenancyShareDecorator.ACCESSLEVEL_READ, shareRecords[0].AccessLevel, 'Access level shoud be Read');
        System.assertEquals(resultGroup[0].Id, shareRecords[0].UserOrGroupId, 'UserOrGroupId should be the group id');
        System.assertEquals(resultTenancy.Id, shareRecords[0].ParentId, 'ParentId should be the tenancy id');
        System.assertEquals('Tenancy__c', shareRecords[0].RowCause, 'Rowcase should be Tenancy__c');
        
    }

    @isTest
    static void deActiveTenancyUpdateTest(){

        YH_Property__c property = UthProperty.getAll()[0];
        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT);
        insert tenancy;

        YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];
        
        String tenancyName = new TenancyService().getGroupName(resultTenancy.Name);
        insert UthGroup.build(tenancyName);

        List<Group> tenancyGroup = UthGroup.getGroupUsingName(tenancyName);

        List<YH_Tenancy__Share> tenancyShares = new List<YH_Tenancy__Share>{
            UthTenancyShare.build(resultTenancy.Id, tenancyGroup[0].Id)
        };
        insert tenancyShares;

        Test.startTest();
            Test.getEventBus().deliver();
                tenancy.Active__c = false;
                update tenancy;
            Test.getEventBus().deliver();

            System.enqueueJob(new ManageCustomerTenancySharingImpl.ManageCustTenSharingDeactivationQueueable(new List<Id>{tenancyGroup[0].Id}));
        Test.stopTest();

        List<Group> resultGroup = UthGroup.getGroupUsingName(tenancyName);
        List<YH_Tenancy__Share> shareRecords = UthTenancyShare.getAll();

        System.assertEquals(0, resultGroup.size(), 'No group with tenancyname should exist');
        System.assertEquals(0, shareRecords.size(), 'NO share record for group with tenancyname should exist');
    }

    @isTest
    static void multipleDeActiveTenancyUpdateTest(){

        YH_Property__c property = UthProperty.getAll()[0];
        TriggerBase.bypass('YH_Tenancy__c');
        TriggerBase.bypass('Member__c');
        
        List<YH_Tenancy__c> tenancyList = new List<YH_Tenancy__c>{
            UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO),
            UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO)
        };
        insert tenancyList;

        Contact contact = UthContact.getAll()[0];

        List<Member__c> memberList = new List<Member__c>{
            UthMember.buildWithNullOccupancyEndDate(contact.Id,tenancyList[0].Id,MemberDecorator.TYPE_SOLO),
            UthMember.buildWithNullOccupancyEndDate(contact.Id,tenancyList[1].Id,MemberDecorator.TYPE_SOLO)
        };
        insert memberList;

        List<YH_Tenancy__c> resultTenancies = UthTenancy.getAll();
        String tenancyNameOne = new TenancyService().getGroupName(resultTenancies[0].Name);
        String tenancyNameTwo = new TenancyService().getGroupName(resultTenancies[1].Name);
        
        List<Group> tenancyGroups = new List<Group>{
            UthGroup.build(tenancyNameOne),
            UthGroup.build(tenancyNameTwo)
        };
        insert tenancyGroups;
        
        List<YH_Tenancy__Share> tenancyShares = new List<YH_Tenancy__Share>{
            UthTenancyShare.build(tenancyList[0].Id, tenancyGroups[0].Id),
            UthTenancyShare.build(tenancyList[1].Id, tenancyGroups[1].Id)
        };
        insert tenancyShares;

        TriggerBase.clearBypass('YH_Tenancy__c');
        TriggerBase.clearBypass('Member__c');

        List<Group> resultGroupOne = UthGroup.getGroupUsingName(tenancyNameOne);
        List<Group> resultGroupTwo = UthGroup.getGroupUsingName(tenancyNameTwo);
        List<YH_Tenancy__Share> shareRecordsBefore = UthTenancyShare.getAll();

        System.assertEquals(1, resultGroupOne.size(), 'No group with tenancyname should exist');
        System.assertEquals(1, resultGroupTwo.size(), 'No group with tenancyname should exist');
        System.assertEquals(2, shareRecordsBefore.size(), 'NO share record for group with tenancyname should exist');

        Test.startTest();
            Test.getEventBus().deliver();
            YH_Tenancy__c tenancy = tenancyList[0];
            tenancy.Active__c = false;
            update tenancy;
            Test.getEventBus().deliver();

            System.enqueueJob(new ManageCustomerTenancySharingImpl.ManageCustTenSharingDeactivationQueueable(new List<Id>{resultGroupOne[0].Id}));
        Test.stopTest();

        List<Group> resultGroupAfterOne = UthGroup.getGroupUsingName(tenancyNameOne);
        List<Group> resultGroupAfterTwo = UthGroup.getGroupUsingName(tenancyNameTwo);
        List<YH_Tenancy__Share> shareRecordsAfter = UthTenancyShare.getAll();

        System.assertEquals(0, resultGroupAfterOne.size(), 'No group with tenancyname should exist');
        System.assertEquals(1, resultGroupAfterTwo.size(), 'No group with tenancyname should exist');
        System.assertEquals(1, shareRecordsAfter.size(), 'NO share record for group with tenancyname should exist');
    }

    @isTest
    static void deActiveTenancyUpdateWithMembersTest(){
        List<Contact> contacts = UthContact.getAll();
        List<User> users = UthUser.getUserUsingContactId(new List<Id>{contacts[0].Id, contacts[1].Id});
        YH_Property__c property = UthProperty.getAll()[0];
        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT);
        insert tenancy;

        YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];

        List<Member__c> memberList = new List<Member__c>{
            UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('John','Doe')[0].Id,tenancy.Id,MemberDecorator.TYPE_JOINT),
            UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('James','Fiorello')[0].Id,tenancy.Id,MemberDecorator.TYPE_JOINT)
        };
        insert memberList;

        String tenancyName = new TenancyService().getGroupName(resultTenancy.Name);

        insert UthGroup.build(tenancyName);

        List<Group> tenancyGroup = UthGroup.getGroupUsingName(tenancyName);

        List<GroupMember> groupMembersToInsert = new List<GroupMember>{
            UthGroupMember.build(tenancyGroup[0].Id,users[0].Id),
            UthGroupMember.build(tenancyGroup[0].Id,users[1].Id)
        };

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert groupMembersToInsert;
        }

        List<GroupMember> groupMembers = UthGroupMember.getGroupMemberUsingGroupName(tenancyName);
        System.Assert.areEqual(2, groupMembers.size(), 'Two group member record should exist');

        Test.startTest();
            Test.getEventBus().deliver();
            tenancy.Active__c = false;
            update tenancy;
            Test.getEventBus().deliver();

            System.enqueueJob(new ManageCustomerTenancySharingImpl.ManageCustTenSharingDeactivationQueueable(new List<Id>{tenancyGroup[0].Id}));
        Test.stopTest();

        List<Group> resultGroup = UthGroup.getGroupUsingName(tenancyName);
        List<YH_Tenancy__Share> shareRecords = UthTenancyShare.getAll();
        List<GroupMember> resultGroupMembers = UthGroupMember.getGroupMemberUsingGroupName(tenancyName);

        System.assertEquals(0, resultGroup.size(), 'No group with tenancyname should exist');
        System.assertEquals(0, shareRecords.size(), 'NO share record for group with tenancyname should exist');
        System.assertEquals(0, resultGroupMembers.size(), 'NO groupmember record for group with tenancyname should exist');
    }
}