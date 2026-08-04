@isTest
public with sharing class TA_Account_BU_UpdateEmailPortalUserTest {
    @testSetup
    static void setupData() {
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.buildUser(roleId,adminProfileId,'fname1','lname1');
        insert adminUser;
        System.runAs(adminUser){
            Account aPerson = UthAccount.buildPersonAccount('Test', 'Test123','test788787878901test@test.com');
            insert aPerson;
            Contact aContact = UthContact.getAll()[0];
            User aUser = UthUser.buildPortalUser('Test', 'Test123', aContact.Id);
            insert aUser;
        }
    }

    @isTest
    static void testEmailUpdateOnPersonAccount() {

        Account pa = UthAccount.getAllPersonAccount()[0];
        Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        Boolean isExceptionThrown = false;
        try{
            System.runAs(new User(Id = currentUserId)) {
                Test.startTest();
                    pa.PersonEmail = '';
                    update pa;
                Test.stopTest();
            }
        }catch(Exception e){
            isExceptionThrown = true;
        }
        Assert.areEqual(isExceptionThrown, true, 'Email cannot be blank on active portal user');
    }
}