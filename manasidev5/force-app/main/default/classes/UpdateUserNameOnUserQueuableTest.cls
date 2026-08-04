@isTest
public with sharing class UpdateUserNameOnUserQueuableTest {
    @IsTest
    static void testUserNameChange() {
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminu = UthUser.buildUser(roleId,adminProfileId,'fname1','lname1');
        insert adminu;
        System.runAs(adminu){        
        	
            TriggerBase.bypass('Account');
        	Account customrAccount = UthAccount.buildPersonAccount();
        	customrAccount.PersonEmail  = 'oldemail@test.com';
        	insert customrAccount;
        
        	Contact con  = UthContact.getAll()[0];
        	User u = UthUser.buildCommunityUser(con.Id,'oldemail@test.com');
        	insert u;
            Test.startTest();
            UpdateUserNameOnUserQueuable executeQueuable = new UpdateUserNameOnUserQueuable(new Set<Id>{u.Id});
            System.enqueueJob(executeQueuable);
            Test.stopTest();

        }
        
        User auser = UthUser.getUserUsingContactId(new List<Id>{UthContact.getAll()[0].Id})[0];
        Assert.areEqual(auser.email, auser.username, 'Username should be same as email address');
    }   
}