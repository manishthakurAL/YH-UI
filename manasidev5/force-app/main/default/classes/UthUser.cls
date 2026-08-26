@isTest
public class UthUser {
    private static Integer userCounter = 1;

    public static User buildUser(Id roleId, Id profileId, String firstName, String lastName) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueOf(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer ramdonInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + ramdonInt;
        User testUser = new User(
            FirstName = firstName,
            LastName = lastName,
            Email = uniqueName + '@test' + orgId + '.org',
            Username = uniqueName + '@test' + orgId + '.org',
            Alias = uniqueName.substring(18, 23),
            TimeZoneSidKey = 'Europe/London',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = profileId,
            UserRoleId = roleId
        );
        return testUser;
    }
    public static User buildPortalUser(String firstName, String lastName, Id contactId) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueOf(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer ramdonInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + ramdonInt;
        User testUser = new User(
            FirstName = firstName,
            LastName = lastName,
            Email = uniqueName + '@test' + orgId + '.org',
            Username = uniqueName + '@test' + orgId + '.org',
            Alias = uniqueName.substring(18, 23),
            TimeZoneSidKey = 'Europe/London',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = UthProfile.getProfileUsingName('YH Customer Community Plus Login')[0].Id,
            contactId = contactId
        );
        return testUser;
    }

    public static User buildKnowledgeUser(Id roleId, Id profileId, String firstName, String lastName) {
        User testUser = buildUser(roleId, profileId, firstName, lastName);
        testUser.UserPermissionsKnowledgeUser = true;
        return testUser;
    }

    public static List<User> getUser(Id profileId, String fName, String lName){
        return [SELECT Id 
            FROM User 
            WHERE ProfileId = :profileId 
                AND FirstName = :fName
                AND LastName = :lName Limit 1 ];
    }

    public static List<User> getUserUsingContactId(List<Id> contactIds){
        return [SELECT Id, IsActive, Username, Email, Contact.MobilePhone, Contact.Id, Contact.Name
            FROM User 
            WHERE ContactId IN : contactIds];
    }

    public static User buildCommunityUser(Id conId, String emailaddress) {
        userCounter++;
        Id commProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN)[0]?.Id;
        String emailAddr = String.IsBlank(emailaddress)? 'testEmail' + userCounter + '@test.com': emailaddress;
        User testUser = new User(
            FirstName = 'firstName'+ userCounter,
            LastName = 'lastName'+ userCounter,
            Email = emailAddr,
            Username = 'userN' + '@test' + userCounter + '.org',
            Alias = userCounter+'test',
            TimeZoneSidKey = 'Europe/London',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = commProfileId,
        	ContactId = conId
        );
        return testUser;
    }
    
    public static Id createNonAdminUser(String roleName, String profileName){
        Id userRoleId = UthUserRole.getUserRole(roleName).Id;
        Id customSuccessProfileId = UthProfile.getProfileUsingName(profileName)[0].Id;
        User runAsUser = UthUser.buildUser(userRoleId, customSuccessProfileId, 'fName', 'lname');
        insert runAsUser;
        return runAsUser.Id;
    }

    public static User buildCommunityUser(Id conId, String emailaddress, Boolean IsActive) {
        User testUser = buildCommunityUser(conId, emailaddress);
        testUser.IsActive = IsActive;
        return testUser;
    }

    public static Id createNonAdminUser(String roleName, String profileName, string fname, string lname){
        Id userRoleId = UthUserRole.getUserRole(roleName).Id;
        Id profileId = UthProfile.getProfileUsingName(profileName)[0].Id;
        User runAsUser = UthUser.buildUser(userRoleId, profileId, fName, lname);
        insert runAsUser;
        return runAsUser.Id;
    } 

    public static User setCustomerUser(Id userId) {
        Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CEC_RT_CREATE).Id;
        Id updatePermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CEC_RT_UPDATE).Id;
        UthPermissionAssigner.assignPermissionSet(userId, createPermissionSetId);
        UthPermissionAssigner.assignPermissionSet(userId, updatePermissionSetId);
        return (new User(Id = userId));
    }

    public static User setChangeUser(Id userId) {
        Id createAtNewPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_CREATE_AT_NEW).Id;
        Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_UPDATE_AT_NEW).Id;
        Id updatePermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_CHANGES_CASE_UPDATE).Id;
        UthPermissionAssigner.assignPermissionSet(userId, createAtNewPermissionSetId);
        UthPermissionAssigner.assignPermissionSet(userId, createPermissionSetId);
        UthPermissionAssigner.assignPermissionSet(userId, updatePermissionSetId);
        return (new User(Id = userId));
    }

    public static User setTenancyUser(Id userId) {
        Id createAtNewPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id;
        Id updatAtNewPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_UPDATE_AT_NEW).Id;
        Id updatePermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_UPDATE).Id;
        UthPermissionAssigner.assignPermissionSet(userId, createAtNewPermissionSetId);
        UthPermissionAssigner.assignPermissionSet(userId, updatAtNewPermissionSetId);
        UthPermissionAssigner.assignPermissionSet(userId, updatePermissionSetId);
        return (new User(Id = userId));
    }

    public static User getMoneyCoachingUser(Id userId) {
        Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MONEY_COACHING_CASE_CREATE).Id;
        Id updatePermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MONEY_COACHING_CASE_UPDATE).Id;
        UthPermissionAssigner.assignPermissionSet(userId, createPermissionSetId);
        UthPermissionAssigner.assignPermissionSet(userId, updatePermissionSetId);
        return (new User(Id = userId));
    }

    public static User getSchemeUser(Id userId) {
        Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_SCHEMES_CASE_CREATE).Id;
        Id updatePermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_SCHEMES_CASE_UPDATE).Id;
        UthPermissionAssigner.assignPermissionSet(userId, createPermissionSetId);
        UthPermissionAssigner.assignPermissionSet(userId, updatePermissionSetId);
        return (new User(Id = userId));
    }

    public static User getPlaceUser(Id userId) {
        Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_CREATE_AT_NEW).Id;
        Id updatePermissionAtNewSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_UPDATE_AT_NEW).Id;
        Id updatePermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_UPDATE).Id;
        UthPermissionAssigner.assignPermissionSet(userId, createPermissionSetId);
        UthPermissionAssigner.assignPermissionSet(userId, updatePermissionAtNewSetId);
        UthPermissionAssigner.assignPermissionSet(userId, updatePermissionSetId);
        return (new User(Id = userId));
    }

    public static User getPermissionUser(Id userId) {
        Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PERMISSION_CASE_CREATE_AT_NEW).Id;
        Id updatePermissionAtNewSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PERMISSION_CASE_UPDATE_AT_NEW).Id;
        Id updatePermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PERMISSION_CASE_UPDATE).Id;
        UthPermissionAssigner.assignPermissionSet(userId, createPermissionSetId);
        UthPermissionAssigner.assignPermissionSet(userId, updatePermissionAtNewSetId);
        UthPermissionAssigner.assignPermissionSet(userId, updatePermissionSetId);
        return (new User(Id = userId));
    }

    public static User getBreachAndASBUser(Id userId) {
        Id createBreachAndASBSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_CREATE_AT_NEW).Id;
        Id updateBreachAndASBAtNewSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_UPDATE_AT_NEW).Id;
        Id updateBreachAndASBSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_UPDATE).Id;
        UthPermissionAssigner.assignPermissionSet(userId, createBreachAndASBSetId);
        UthPermissionAssigner.assignPermissionSet(userId, updateBreachAndASBAtNewSetId);
        UthPermissionAssigner.assignPermissionSet(userId, updateBreachAndASBSetId);
        return (new User(Id = userId));
    }

    public static User getSchemeUserForManagedMove(Id userId) {
        Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MANAGEDMOVE_RT_CREATE).Id;
        Id updatePermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MANAGEDMOVE_RT_UPDATE).Id;
        UthPermissionAssigner.assignPermissionSet(userId, createPermissionSetId);
        UthPermissionAssigner.assignPermissionSet(userId, updatePermissionSetId);
        return (new User(Id = userId));
    }

    public static User getSchemeUserForManagedMoveAndSchemes(Id userId) {
        Id createPermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MANAGEDMOVE_RT_CREATE).Id;
        Id updatePermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_MANAGEDMOVE_RT_UPDATE).Id;
        Id createSchemePermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_SCHEMES_CASE_CREATE).Id;
        Id updateSchemePermissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_SCHEMES_CASE_UPDATE).Id;
        UthPermissionAssigner.assignPermissionSet(userId, createPermissionSetId);
        UthPermissionAssigner.assignPermissionSet(userId, updatePermissionSetId);
        UthPermissionAssigner.assignPermissionSet(userId, createSchemePermissionSetId);
        UthPermissionAssigner.assignPermissionSet(userId, updateSchemePermissionSetId);
        return (new User(Id = userId));
    }
}