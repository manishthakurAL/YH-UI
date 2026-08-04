@isTest
public with sharing class TA_Account_AU_UpdateEmailPortalUserTest {
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
        
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
                pa.PersonEmail = 'newemail@test.com';
                update pa;
            Test.stopTest();
        }
        User updatedUser = UthUser.getUserUsingContactId(new List<Id>{pa.PersonContactId})[0];

        Assert.areEqual('newemail@test.com', updatedUser.Email, 'Email should be updated');
    }

    @isTest
    static void testNoUpdateWhenEmailUnchanged() {

        Account pa = UthAccount.getAllPersonAccount()[0];
        Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
            update pa;
            Test.stopTest();
        }
        User updatedUser = UthUser.getUserUsingContactId(new List<Id>{pa.PersonContactId})[0];
        Assert.areNotEqual('test788787878901test@test.com', updatedUser.Email, 'Email should not change');
    }

     @isTest
    static void testEmailUpdateOnPersonAccountEmailNull() {

        Account pa = UthAccount.getAllPersonAccount()[0];
        Boolean isException = false;
        String exceptionMessage;
        Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        try{
        System.runAs(new User(Id = currentUserId)) {
            Test.startTest();
                pa.PersonEmail = null;
                update pa;
            Test.stopTest();
        }
        }catch(Exception e){
            isException = true;
            exceptionMessage = e.getMessage();
        }finally{
            Assert.isTrue(exceptionMessage.contains(Label.PersonAccountEmailNotBlankForPortalUser), 'Exception message should match');
            Assert.isTrue(isException, 'Exception should be thrown');
        }
    }
}