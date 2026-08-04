@IsTest
public class ManageCustomerMemberSharingImplTest {
    @TestSetup
    static void setUpTestData(){
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.buildUser(roleId,adminProfileId,'fname1','lname1');
        insert adminUser;

        System.runAs(adminUser){
            TriggerBase.bypass('Account');
            TriggerBase.bypass('YH_Tenancy__c');
            TriggerBase.bypass('Member__c');
                insert new List<Account>{
                    UthAccount.buildPersonAccount('John', 'Doe','123 Test St','London','AB123CD'),
                    UthAccount.buildPersonAccount('James', 'Fiorello','123 Test St','London','AB123CD')
                };
                
                YH_Property__c property = UthProperty.buildPropertyWithAssetClass('Leeds',
                        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
                        PropertyDecorator.RENT_TYPE_MARKET_RENT, PropertyDecorator.PRODUCT_TYPE_MARKETRENTAL,
                        '123 Test St', 'London', 'AB123CD',PropertyDecorator.FLAT_ASSET_CLASS);
                insert property;

                YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT);
        	    insert tenancy;

                YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];

                Group tenancyGroup = UthGroup.build('TenancySharing' + resultTenancy.Name.replace('-', '_'));
                insert tenancyGroup;

                YH_Tenancy__Share tenancyShare = UthTenancyShare.build(resultTenancy.Id, tenancyGroup.Id);
                insert tenancyShare;

                List<Member__c> memberList = new List<Member__c>{
                    UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('John','Doe')[0].Id,tenancy.Id,MemberDecorator.TYPE_JOINT),
                    UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('James','Fiorello')[0].Id,tenancy.Id,MemberDecorator.TYPE_JOINT)
                };
                insert memberList;

                List<Contact> contacts = UthContact.getAll();

                List<User> userList = new List<User>{
                    UthUser.buildCommunityUser(contacts[0].Id,null),
                    UthUser.buildCommunityUser(contacts[1].Id,null)
                };
                insert userList;
            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('YH_Tenancy__c');
            TriggerBase.clearBypass('Member__c');
        }
    }

    @isTest
    static void membersActivatedTest(){
        List<Member__c> memberList = UthMember.getAll();

        Test.startTest();
            for(Member__c member : memberList){
                member.IsActiveValue__c = true;
            }
            update memberList;
        Test.stopTest();

        YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];
        String tenancyName = new TenancyService().getGroupName(resultTenancy.Name);
        List<Group> resultGroup = UthGroup.getGroupUsingName(tenancyName);

        List<GroupMember> groupMembers = UthGroupMember.getGroupMemberUsingId(resultGroup[0].Id);
        System.Assert.areEqual(2, groupMembers.size(), 'Two group member record should exist');
    }

    @isTest
    static void membersDeActivatedTest(){
        List<Contact> contacts = UthContact.getAll();
        List<User> users = UthUser.getUserUsingContactId(new List<Id>{contacts[0].Id, contacts[1].Id});
        List<Member__c> memberList = UthMember.getAll();
        for(Member__c member : memberList){
            member.IsActiveValue__c = true;
        }
        update memberList;

        YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];
        String tenancyName = new TenancyService().getGroupName(resultTenancy.Name);
        List<Group> resultGroup = UthGroup.getGroupUsingName(tenancyName);
        
        List<GroupMember> groupMembersToInsert = new List<GroupMember>{
            UthGroupMember.build(resultGroup[0].Id,users[0].Id),
            UthGroupMember.build(resultGroup[0].Id,users[1].Id)
        };
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert groupMembersToInsert;
        }

        List<GroupMember> groupMembers = UthGroupMember.getGroupMemberUsingId(resultGroup[0].Id);
        System.Assert.areEqual(2, groupMembers.size(), 'Two group member record should exist');

        Test.startTest();
            for(Member__c member : memberList){
                member.IsActiveValue__c = false;
            }
            update memberList;
        Test.stopTest();

        resultTenancy = UthTenancy.getAll()[0];
        List<GroupMember> groupMembersResult = UthGroupMember.getGroupMemberUsingId(resultGroup[0].Id);
        System.Assert.areEqual(0, groupMembersResult.size(), 'No group member record should exist');
    }
}