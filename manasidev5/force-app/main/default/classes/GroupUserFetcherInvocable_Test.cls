@IsTest
public class GroupUserFetcherInvocable_Test {

    @TestSetup
    static void setupData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Resource Planner' LIMIT 1];
        
        User u1 = UthUser.buildUser(role.Id, p.Id, 'Test', 'UserOne');
        insert u1;
        User u2 = UthUser.buildUser(role.Id, p.Id, 'Test', 'UserTwo');
        insert u2;
        User u3 = UthUser.buildUser(role.Id, p.Id, 'Test', 'UserThree');     
        insert u3;
        User uRoleUser = UthUser.buildUser(role.Id, p.Id, 'Test', 'RoleUser');
        insert uRoleUser;

        Group groupA = UthGroup.createGroup('Public Group A');
        Group groupB = UthGroup.createGroup('Public Group B');
        Group groupC = UthGroup.createGroup('Public Group C');

        UthGroup.createGroupMember(groupA.Id, u1.Id);
        UthGroup.createGroupMember(groupA.Id, groupB.Id);
        
		UthGroup.createGroupMember(groupB.Id, u2.Id);
        UthGroup.createGroupMember(groupB.Id, groupC.Id);
        
        UthGroup.createGroupMember(groupC.Id, u3.Id);

        Group nestedRoleGroup = UthGroup.createGroup('Nested Role Group');
		UthGroup.createGroupMember(nestedRoleGroup.Id, uRoleUser.Id);
        UthGroup.createGroupMember(groupA.Id, nestedRoleGroup.Id);
    }

    @IsTest
    static void testGetGroupUserIdsFromFlow() {
        Group groupA = [SELECT Id FROM Group WHERE Name = 'Public Group A' LIMIT 1];

        GroupUserFetcherInvocable.Request req = new GroupUserFetcherInvocable.Request();
        req.groupId = groupA.Id;

        List<GroupUserFetcherInvocable.Request> reqList = new List<GroupUserFetcherInvocable.Request>{ req };

        Test.startTest();
        List<GroupUserFetcherInvocable.Response> responses = GroupUserFetcherInvocable.getGroupUserIdsFromFlow(reqList);
        Test.stopTest();

        System.assertEquals(1, responses.size());
        Set<Id> userIdsSet = new Set<Id>(responses[0].userIds);

        System.assertEquals(4, userIdsSet.size(), 'Should return all 4 unique users including the role user');

        Set<Id> expectedUserIds = new Set<Id>{
            [SELECT Id FROM User WHERE LastName = 'UserOne' LIMIT 1].Id,
            [SELECT Id FROM User WHERE LastName = 'UserTwo' LIMIT 1].Id,
            [SELECT Id FROM User WHERE LastName = 'UserThree' LIMIT 1].Id,
            [SELECT Id FROM User WHERE LastName = 'RoleUser' LIMIT 1].Id
        };
        System.assert(userIdsSet.containsAll(expectedUserIds), 'All expected users should be included');

        Set<String> emailsSet = new Set<String>(responses[0].userEmails);
        List<User> users = [SELECT Id, Email FROM User WHERE Id IN :expectedUserIds];
        for (User u : users) {
            String email = u.Email;
            System.assert(emailsSet.contains(email), 'Email for user ' + u.Id + ' should be included');
        }
    }


}