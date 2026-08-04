@IsTest
public class MfaOtpControllerTest {
    @TestSetup
    static void setUpTestData(){
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.buildUser(roleId,adminProfileId,'fname1','lname1');
        insert adminUser;

        System.runAs(adminUser){
            UthCustomerPortalSettings.setDefaultValues();
            TriggerBase.bypass('Account');
            TriggerBase.bypass('YH_Tenancy__c');
            TriggerBase.bypass('Member__c');
                Date dobOne = Date.newInstance(1983, 06, 22);
                Date dobTwo = Date.newInstance(1982, 06, 22);
                insert new List<Account>{
                    UthAccount.buildPersonAccount('JamesOne', 'DoeOne', 'jamesdoeone7895728975982@randomemail.random', '07458256715', dobOne,'KR4 3RT'),
                    UthAccount.buildPersonAccount('JamesTwo', 'DoeTwo', 'jamesdoetwo6666666668876@randomemail.random', '07458256716', dobTwo,'KR4 3RT')
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
    static void validOTPTest(){
        PageReference pageRef = Page.MfaOtpVerification;
        Test.setCurrentPage(pageRef);
        PageReference pageRefResult;
        List<ApexPages.Message> msgs;
        MfaOtpController ctrl;
        String otp;

        List<Contact> contacts = UthContact.getAll();
        List<User> userOne = UthUser.getUserUsingContactId(new List<Id>{contacts[0].Id});

        System.runAs(userOne[0]) {
            Test.startTest();
                ctrl = new MfaOtpController();
                ctrl.selectedMethod = OtpService.METHOD.EMAIL.name();
                pageRefResult = ctrl.sendCode();
                msgs = ApexPages.getMessages();
            Test.stopTest();
        }

        List<AuthenticationToken__c> resultToken = UthAuthenticationToken.getAll();

        Assert.areEqual(null, pageRefResult, 'pageRefResult should be null');
        Assert.areEqual(1, resultToken.size(), 'AuthenticationToken__c size should be 1');
        Assert.areNotEqual(null, resultToken[0].Salt__c, 'Salt__c should not be null');
        Assert.areEqual(userOne[0].Id, resultToken[0].User__c, 'Running user should be populated');
        Assert.areEqual(AuthenticationTokenDecorator.METHOD_EMAIL, resultToken[0].Method__c, 'Method should be email');
        Assert.areEqual(contacts[0].Email, resultToken[0].ContactPoint__c, 'Contact point should be user email');
        Assert.areNotEqual(null, resultToken[0].OTPHash__c, 'OTPHash__c should not be null');
        Assert.areNotEqual(null, resultToken[0].ExpiresAt__c, 'ExpiresAt__c should not be null');
        Assert.areEqual(AuthenticationTokenDecorator.STATUS_PENDING, resultToken[0].Status__c, 'Status__c should be Pending');
        Assert.areEqual(0, resultToken[0].NumberOfAttempts__c, 'NumberOfAttempts__c should be default to 0');
    }

    @isTest
    static void inValidOTPTest(){
        PageReference pageRef = Page.MfaOtpVerification;
        Test.setCurrentPage(pageRef);
        PageReference pageRefResult;
        List<ApexPages.Message> msgs;
        MfaOtpController ctrl;
        String otp;

        List<Contact> contacts = UthContact.getAll();
        List<User> userOne = UthUser.getUserUsingContactId(new List<Id>{contacts[0].Id});

        System.runAs(userOne[0]) {
            Test.startTest();
                ctrl = new MfaOtpController();
                ctrl.selectedMethod = OtpService.METHOD.EMAIL.name();
                pageRefResult = ctrl.sendCode();
                msgs = ApexPages.getMessages();

                ctrl.otpEntered = '12345678';
                pageRefResult = ctrl.verifyCode();
            Test.stopTest();
        }

        List<AuthenticationToken__c> resultToken = UthAuthenticationToken.getAll();

        Assert.areEqual(null, pageRefResult, 'pageRefResult should be null');
        Assert.areEqual(1, resultToken.size(), 'AuthenticationToken__c size should be 1');
        Assert.areNotEqual(null, resultToken[0].Salt__c, 'Salt__c should not be null');
        Assert.areEqual(userOne[0].Id, resultToken[0].User__c, 'Running user should be populated');
        Assert.areEqual(AuthenticationTokenDecorator.METHOD_EMAIL, resultToken[0].Method__c, 'Method should be email');
        Assert.areEqual(contacts[0].Email, resultToken[0].ContactPoint__c, 'Contact point should be user email');
        Assert.areNotEqual(null, resultToken[0].OTPHash__c, 'OTPHash__c should not be null');
        Assert.areNotEqual(null, resultToken[0].ExpiresAt__c, 'ExpiresAt__c should not be null');
        Assert.areEqual(AuthenticationTokenDecorator.STATUS_PENDING, resultToken[0].Status__c, 'Status__c should be Pending');
        Assert.areEqual(1, resultToken[0].NumberOfAttempts__c, 'NumberOfAttempts__c should be default to 0');
    }

    @isTest
    static void accountLockedTest(){
        PageReference pageRef = Page.MfaOtpVerification;
        Test.setCurrentPage(pageRef);
        PageReference pageRefResult;
        List<ApexPages.Message> msgs;
        MfaOtpController ctrl;
        String otp;

        List<Contact> contacts = UthContact.getAll();
        List<User> userOne = UthUser.getUserUsingContactId(new List<Id>{contacts[0].Id});

        System.runAs(userOne[0]) {
            Test.startTest();
                ctrl = new MfaOtpController();
                ctrl.selectedMethod = OtpService.METHOD.EMAIL.name();
                pageRefResult = ctrl.sendCode();
                msgs = ApexPages.getMessages();

                for(Integer i=0; i< ctrl.maxAttempts; i++){
                    ctrl.otpEntered = '12345678';
                    pageRefResult = ctrl.verifyCode();
                }
            Test.stopTest();
        }

        CustomerPortalSettings__c customerPortalSettings = CustomerPortalSettings__c.getOrgDefaults();
        List<AuthenticationToken__c> resultToken = UthAuthenticationToken.getAll();

        Assert.areEqual(null, pageRefResult, 'pageRefResult should not be null');
        Assert.areEqual(1, resultToken.size(), 'AuthenticationToken__c size should be 1');
        Assert.areNotEqual(null, resultToken[0].Salt__c, 'Salt__c should not be null');
        Assert.areEqual(userOne[0].Id, resultToken[0].User__c, 'Running user should be populated');
        Assert.areEqual(AuthenticationTokenDecorator.METHOD_EMAIL, resultToken[0].Method__c, 'Method should be email');
        Assert.areEqual(contacts[0].Email, resultToken[0].ContactPoint__c, 'Contact point should be user email');
        Assert.areNotEqual(null, resultToken[0].OTPHash__c, 'OTPHash__c should not be null');
        Assert.areNotEqual(null, resultToken[0].ExpiresAt__c, 'ExpiresAt__c should not be null');
        Assert.areEqual(AuthenticationTokenDecorator.STATUS_LOCKED, resultToken[0].Status__c, 'Status__c should be locked');
        system.debug('YH LOGS customerPortalSettings.MaxOTPAttempts__c = ' + customerPortalSettings.MaxOTPAttempts__c);
        system.debug('YH LOGS resultToken[0].NumberOfAttempts__c = ' + resultToken[0].NumberOfAttempts__c);
        Assert.areEqual(customerPortalSettings.MaxOTPAttempts__c, resultToken[0].NumberOfAttempts__c, 'NumberOfAttempts__c should be Max attempts');
        Assert.areEqual(TRUE, resultToken[0].AutorizationLocked__c, 'AuthenticationToken__c should be 1');
    }
}