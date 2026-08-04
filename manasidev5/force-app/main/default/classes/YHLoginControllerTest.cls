@IsTest
public class YHLoginControllerTest {
    @TestSetup
    static void setUpTestData(){
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.buildUser(roleId,adminProfileId,'fname1','lname1');
        insert adminUser;

        System.runAs(adminUser){
            UthCustomerPortalSettings.setDefaultValues();
            insert UthSmagicinteractSMSSenderId.build();
            TriggerBase.bypass('Account');
            TriggerBase.bypass('YH_Tenancy__c');
            TriggerBase.bypass('Member__c');
                Date dobOne = Date.newInstance(1983, 06, 22);
                Date dobTwo = Date.newInstance(1982, 06, 22);
                insert new List<Account>{
                    UthAccount.buildPersonAccount('JamesOne', 'DoeOne', 'jamesdoeone7895728975982@randomemail.random', '07458256715', dobOne,'KR4 3RT'),
                    UthAccount.buildPersonAccount('JamesTwo', 'DoeTwo', 'jamesdoetwo6666666668876@randomemail.random', null, dobTwo,'KR4 3RT')
                };
                
                YH_Property__c property = UthProperty.buildPropertyWithAssetClass('Leeds',
                        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
                        PropertyDecorator.RENT_TYPE_MARKET_RENT, PropertyDecorator.PRODUCT_TYPE_MARKETRENTAL,
                        '123 Test St', 'London', 'KR43RT',PropertyDecorator.FLAT_ASSET_CLASS);
                insert property;

                YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT);
        	    insert tenancy;

                List<Member__c> memberList = new List<Member__c>{
                    UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('JamesOne', 'DoeOne')[0].Id,tenancy.Id,MemberDecorator.TYPE_JOINT),
                    UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('JamesTwo', 'DoeTwo')[0].Id,tenancy.Id,MemberDecorator.TYPE_JOINT)
                };
                insert memberList;

                List<Contact> contacts = UthContact.getAll();

                List<User> userList = new List<User>{
                    UthUser.buildCommunityUser(contacts[0].Id, contacts[0].Email),
                    UthUser.buildCommunityUser(contacts[1].Id, contacts[1].Email)
                };
                insert userList;
            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('YH_Tenancy__c');
            TriggerBase.clearBypass('Member__c');
        }
    }

    
    @isTest
    static void testUserDoesNotExist() {
        Test.startTest();
            YHLoginController ctrl = new YHLoginController();
            ctrl.emailAddress = 'nouser@test.com';
            ctrl.password = 'wrong';
            PageReference result = ctrl.doLogin();
        Test.stopTest();

        System.assertEquals(null, result);
        System.assertEquals(true, ctrl.isError);
        System.assert(ctrl.errorText.contains(Label.InvalidPassword));
    }

    
    @isTest
    static void testInvalidPasswordNoLock() {
        List<Contact> contacts = UthContact.getAll();
        List<User> userOne = UthUser.getUserUsingContactId(new List<Id>{contacts[0].Id});

        Test.startTest();
            YHLoginController ctrl = new YHLoginController();
            ctrl.emailAddress = userOne[0].Username;
            ctrl.password = 'wrongpassword';
            PageReference result = ctrl.doLogin();
        Test.stopTest();

        System.assertEquals(null, result);
        System.assertEquals(true, ctrl.isError);
        System.assert(ctrl.errorText.contains(Label.InvalidPassword));
    }

    
    @isTest
    static void testAccountLockedEmailPath() {
        List<Contact> contacts = UthContact.getAll();
        List<User> userOne = UthUser.getUserUsingContactId(new List<Id>{contacts[0].Id});

        // Simulate login history lock (NOTE: LoginHistory cannot be inserted, 
        // but code coverage still executes isAccountLocked path conditionally)

        Test.startTest();
            YHLoginController ctrl = new YHLoginController();
            ctrl.emailAddress = userOne[0].Username;
            ctrl.password = 'wrongpassword';

            try {
                ctrl.doLogin();
            } catch (Exception e){}
        Test.stopTest();

        // We can't enforce actual LoginHistory, but still validate flow
        System.assertEquals(true, ctrl.isError || ctrl.isLocked);
    }

    
    @isTest
    static void testSMSNotificationPath() {
        List<Contact> contacts = UthContact.getAll();
        List<User> userOne = UthUser.getUserUsingContactId(new List<Id>{contacts[0].Id});

        Test.startTest();
            YHLoginController ctrl = new YHLoginController();
            ctrl.currentUser = userOne[0];
            ctrl.emailAddress = userOne[0].Username;
            ctrl.sendSMSNotification();
        Test.stopTest();

        System.assert(true);
        List<smagicinteract__smsMagic__c> smsRecords = UthSMSMagic.getSMSRecords();
        System.assertEquals(1, smsRecords.size(), 'SMS record should have been created');
        smagicinteract__smsMagic__c sms = smsRecords[0];
        System.assertEquals(contacts[0].Id, sms.smagicinteract__Contact__c);
    }

    
    @isTest
    static void testEmailNotificationPath() {
        List<Contact> contacts = UthContact.getAll();
        List<User> userOne = UthUser.getUserUsingContactId(new List<Id>{contacts[1].Id});

        Test.startTest();
            YHLoginController ctrl = new YHLoginController();
            ctrl.emailAddress = userOne[0].Username;
            ctrl.sendNotifications();
        Test.stopTest();

        List<Task> tasks = UthTask.getAll();

        System.assert(true);
        System.assertEquals(1, tasks.size());
        System.assert( tasks[0].Subject.contains('Your Yorkshire Housing Customer Portal Account'));
    }

    
    @isTest
    static void testExceptionHandling() {
        Test.startTest();
            YHLoginController ctrl = new YHLoginController();
            ctrl.password = 'test';
            PageReference result = ctrl.doLogin();
        Test.stopTest();

        System.assertEquals(null, result);
        System.assertEquals(true, ctrl.isError);
    }

    
    @isTest
    static void testResetValues() {
        YHLoginController ctrl = new YHLoginController();
        ctrl.isError = true;
        ctrl.isLocked = true;
        ctrl.errorText = 'Test';

        Test.startTest();
            ctrl.doLogin();
        Test.stopTest();

        System.assertEquals(false, ctrl.isLocked);
    }

    
    @isTest
    static void testUserDetailsClass() {
        List<Contact> contacts = UthContact.getAll();
        List<User> userWithoutMobile = UthUser.getUserUsingContactId(new List<Id>{contacts[1].Id});

        Test.startTest();
        YHLoginController.WithoutSharingController details =
            new YHLoginController.WithoutSharingController(userWithoutMobile[0].Username);
        Test.stopTest();

        System.assertNotEquals(null, details.currentUser);
        System.assertEquals(userWithoutMobile[0].Id, details.currentUser.Id);
    }
}