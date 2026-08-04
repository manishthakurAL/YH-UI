@IsTest
public class TA_UserChangeEvent_AI_ActivePortalUrTest {
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
            TriggerBase.bypass('Case');
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
                List<Case> caseRecords = new List<Case>();
                for(Integer i = 0; i < contacts.size(); i++){
                    Case caseRecord = UthCase.buildPermissionCaseWithSharingReason(
                        contacts[i].Id, 
                        tenancy.Id, 
                        CaseDecorator.CASE_TYPE_PERMISSION_FOR_A_LoDGER_OR_SUBLET,
                        CaseDecorator.CASESHARINGREASON_TENANT);
                    caseRecords.add(caseRecord);
                }
                insert caseRecords;
                
            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('YH_Tenancy__c');
            TriggerBase.clearBypass('Member__c');
            TriggerBase.clearBypass('Case');
        }
    }

    @isTest
    static void testCreateActiveUser(){
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.getUser(adminProfileId,'fname1','lname1')[0];
        
        List<Contact> contacts = UthContact.getAll();
        List<Case> cases = UthCase.getAll();
        YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];

        List<User> userList = new List<User>{
            UthUser.buildCommunityUser(contacts[0].Id,null),
            UthUser.buildCommunityUser(contacts[1].Id,null),
            UthUser.buildUser(null,adminProfileId,'fnameTwo','lnameTwo')
        };
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
                Test.getEventBus().deliver();
                insert userList;
                Test.getEventBus().deliver();
            Test.stopTest();
        }

        String tenancyName = new TenancyService().getGroupName(resultTenancy.Name);
        List<Group> resultGroup = UthGroup.getGroupUsingName(tenancyName);
        List<GroupMember> groupMembers = UthGroupMember.getGroupMemberUsingId(resultGroup[0].Id);
        List<CaseShare> caseShares = UthCaseShare.getAllUsingCaseId(new List<Id>{cases[0].Id, cases[1].Id});
        
        System.Assert.areEqual(2, caseShares.size(), 'Two case share record should exist');
        System.Assert.areEqual(2, groupMembers.size(), 'Two group member record should exist');
    }

    @isTest
    static void testUpdateDeActivateUser(){
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.getUser(adminProfileId,'fname1','lname1')[0];

        List<Contact> contacts = UthContact.getAll();
        List<Case> cases = UthCase.getAll();
        YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];
        String tenancyName = new TenancyService().getGroupName(resultTenancy.Name);
        List<Group> groups = UthGroup.getGroupUsingName(tenancyName);

        TriggerBase.bypass('UserChangeEvent');
        List<User> userList = new List<User>{
            UthUser.buildCommunityUser(contacts[0].Id,null),
            UthUser.buildCommunityUser(contacts[1].Id,null)
        };
        insert userList;

        List<GroupMember> groupMembersToInsert = new List<GroupMember>{
            UthGroupMember.build(groups[0].Id,userList[0].Id),
            UthGroupMember.build(groups[0].Id,userList[1].Id)
        };

        List<CaseShare> caseSharesToInsert = new List<CaseShare>{
            UthCaseShare.build(cases[0].Id, userList[0].Id),
            UthCaseShare.build(cases[1].Id, userList[1].Id)};
            
        
        System.runAs(adminUser) {
            insert groupMembersToInsert;
            insert caseSharesToInsert;
        }
        TriggerBase.clearBypass('Case');
        TriggerBase.clearBypass('User');
        TriggerBase.clearBypass('UserChangeEvent');

        List<GroupMember> groupMembers = UthGroupMember.getGroupMemberUsingId(groups[0].Id);
        List<CaseShare> caseShares = UthCaseShare.getAllUsingCaseId(new List<Id>{cases[0].Id, cases[1].Id});
        
        System.Assert.areEqual(2, caseShares.size(), 'Two case share record should exist');
        System.Assert.areEqual(2, groupMembers.size(), 'Two group member record should exist');
        
        System.runAs(adminUser) {
            Test.startTest();
                Test.getEventBus().deliver();
                userList[0].IsActive = false;
                userList[1].IsActive = false;
                update userList;
                Test.getEventBus().deliver();
            Test.stopTest();
        }

        
        List<GroupMember> groupMembersResult = UthGroupMember.getGroupMemberUsingId(groups[0].Id);
        List<CaseShare> caseSharesResult = UthCaseShare.getAllUsingCaseId(new List<Id>{cases[0].Id, cases[1].Id});
        
        System.Assert.areEqual(0, caseSharesResult.size(), 'Zero case share record should exist');
        System.Assert.areEqual(0, groupMembersResult.size(), 'Zero group member record should exist');
    }

    @isTest
    static void testUpdateActivateAndDeActivateDifferentUser(){
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.getUser(adminProfileId,'fname1','lname1')[0];

        List<Contact> contacts = UthContact.getAll();
        List<Case> cases = UthCase.getAll();
        YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];
        String tenancyName = new TenancyService().getGroupName(resultTenancy.Name);
        List<Group> groups = UthGroup.getGroupUsingName(tenancyName);

        TriggerBase.bypass('UserChangeEvent');
        List<User> userList = new List<User>{
            UthUser.buildCommunityUser(contacts[0].Id,null, false),
            UthUser.buildCommunityUser(contacts[1].Id,null)
        };
        insert userList;

        // Create group member for active user
        List<GroupMember> groupMembersToInsert = new List<GroupMember>{
            UthGroupMember.build(groups[0].Id,userList[1].Id)
        };

        // create case shae of active user
        List<CaseShare> caseSharesToInsert = new List<CaseShare>{
            UthCaseShare.build(cases[1].Id, userList[1].Id)
        };  
        
        System.runAs(adminUser) {
            insert groupMembersToInsert;
            insert caseSharesToInsert;
        }
        TriggerBase.clearBypass('Case');
        TriggerBase.clearBypass('User');
        TriggerBase.clearBypass('UserChangeEvent');
        
        List<GroupMember> groupMembers = UthGroupMember.getGroupMemberUsingId(groups[0].Id);
        List<CaseShare> caseShares = UthCaseShare.getAllUsingCaseId(new List<Id>{cases[0].Id, cases[1].Id});
        
        // Assert group member and case share for active user before test
        System.Assert.areEqual(1, caseShares.size(), 'One case share record should exist');
        System.Assert.areEqual(1, groupMembers.size(), 'One group member record should exist');
        
        System.runAs(adminUser) {
            Test.startTest();
                Test.getEventBus().deliver();
                userList[0].IsActive = true;
                userList[1].IsActive = false;
                update userList;
                Test.getEventBus().deliver();
            Test.stopTest();
        }

        
        List<GroupMember> groupMembersResult = UthGroupMember.getGroupMemberUsingId(groups[0].Id);
        List<CaseShare> caseSharesResultUser0 = UthCaseShare.getAllUsingCaseId(new List<Id>{cases[0].Id});
        List<CaseShare> caseSharesResultUser1 = UthCaseShare.getAllUsingCaseId(new List<Id>{cases[1].Id});
        
        System.Assert.areEqual(1, caseSharesResultUser0.size(), 'One case share record should exist for active user');
        System.Assert.areEqual(0, caseSharesResultUser1.size(), 'Zero case share record should exist for inactive user');
        System.Assert.areEqual(1, groupMembersResult.size(), 'One group member record should exist for Active user');
        System.Assert.areEqual(userList[0].Id, groupMembersResult[0].UserOrGroupId, 'One group member record should be linked toActive user');
    }
}