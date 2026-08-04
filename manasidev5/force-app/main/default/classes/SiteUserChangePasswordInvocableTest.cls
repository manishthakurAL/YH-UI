@isTest
public with sharing class SiteUserChangePasswordInvocableTest {

    @TestSetup
    static void makeData(){
        User accountOwner = UthUser.buildUser(UthUserRole.getUserRole(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER).Id, UthProfile.getProfileUsingName('Standard User')[0].Id, 'fname', 'lname');
        insert accountOwner;
        System.runAs(accountOwner){
            TriggerBase.bypass('Account');
            TriggerBase.bypass('Contact');
            Account account = UthAccount.build();
            insert account;
            Contact contact = UthContact.build(account.Id);
            insert contact; 
            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('Contact');
        }  
    }

    @IsTest
    static void testSiteChangePassword() { 
       
        User auser = UthUser.buildPortalUser('Test','Testuser',UthContact.getAll()[0].Id);
        insert auser;

        // Set the user's initial password
        System.setPassword(auser.Id, 'OldPassword123!');
        Test.startTest();

        SiteUserChangePasswordInvocable.Request request = new SiteUserChangePasswordInvocable.Request();
        request.newPassword = 'NewPassword@123!';
        request.oldPassword = 'OldPassword123!';
        request.verifyNewPassword = 'NewPassword@123!';

        List<SiteUserChangePasswordInvocable.Response> responses = SiteUserChangePasswordInvocable.changePassword(new List<SiteUserChangePasswordInvocable.Request>{request});
        Test.stopTest();
        Assert.isNotNull(responses);
        Assert.areEqual(true, responses[0].isSuccessful, 'Password change successful');

    }
}