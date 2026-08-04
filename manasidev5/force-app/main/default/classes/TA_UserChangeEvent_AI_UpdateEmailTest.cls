@IsTest
public class TA_UserChangeEvent_AI_UpdateEmailTest {
    
    @IsTest
    static void testUserChangeEventEmailUpdate() {
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
			Test.enableChangeDataCapture();
        	User u = UthUser.buildCommunityUser(con.Id,'oldemail@test.com');
        	insert u;
            Test.getEventBus().deliver();
        	u.Email = 'newemail@test.com'; 
        	update u;
            Test.getEventBus().deliver();
        }
        
        Contact updatedCon = UthContact.getAll()[0];
        System.assertEquals('newemail@test.com', updatedCon.Email,
            'Contact email should be updated after UserChangeEvent');
    }

}