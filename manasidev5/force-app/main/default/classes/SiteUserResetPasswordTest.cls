@IsTest
private class SiteUserResetPasswordTest {

   @IsTest
    static void testChangePasswordSuccess() {
        Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);

        SiteUserResetPassword.Request req = new SiteUserResetPassword.Request();
        req.aUserId = currentUserId;

        List<SiteUserResetPassword.Request> requests = 
            new List<SiteUserResetPassword.Request>{ req };

        Test.startTest();
        List<SiteUserResetPassword.Response> responses = 
            SiteUserResetPassword.changePassword(requests);
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals(true, responses[0].isSuccessful);
        System.assertEquals(
            'Password update successful',
            responses[0].message
        );
    }

    @IsTest
    static void testChangePasswordException() {

        SiteUserResetPassword.Request req = new SiteUserResetPassword.Request();
        req.aUserId = 'invaliduser@example.com';

        List<SiteUserResetPassword.Request> requests = 
            new List<SiteUserResetPassword.Request>{ req };

        Test.startTest();
        List<SiteUserResetPassword.Response> responses = 
            SiteUserResetPassword.changePassword(requests);
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals(true, responses[0].isSuccessful);
        System.assertNotEquals(null, responses[0].message);
    }
}