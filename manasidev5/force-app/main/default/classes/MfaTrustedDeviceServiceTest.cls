@IsTest
public class MfaTrustedDeviceServiceTest {

    @TestSetup
    static void setUpTestData(){
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.buildUser(roleId,adminProfileId,'fname1','lname1');
        insert adminUser;

        System.runAs(adminUser){
            UthCustomerPortalSettings.setDefaultValues();
            UthMfaSettings.cretaeMfaSettings();
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

    @IsTest
    static void testEstablishTrustAndValidateSingleUser() {
        List<Contact> contacts = UthContact.getAll();
        User user = UthUser.getUserUsingContactId(new List<Id>{contacts[0].Id})[0];
        DateTime nowDateTime = Datetime.now();
        MfaSettingDecorator mfaSettings = new MfaSettingDecorator();

        System.runAs(user) {
            PageReference pageRef = Page.MfaOtpVerificationV2;
            Test.setCurrentPage(pageRef);
            Test.startTest();
                MfaTrustedDeviceService mfaSercive = new MfaTrustedDeviceService();
                mfaSercive.nowDateTime = nowDateTime;
                Boolean established = mfaSercive.establishTrust();
                Boolean trusted = mfaSercive.isTrustedDevice;
                List<CustomerTrustedDevice__c> devices = UthCustomerTrustedDevice.getCustomerTrustedDevicesByIserId(user.Id);

                System.assertEquals(true, established, 'Trust establishment should succeed');
                System.assertEquals(1, devices.size(), 'Trusted device record should be created');
            Test.stopTest();

            System.assertEquals(true, trusted, 'User should be trusted with valid cookie and device record');
            System.assertEquals(user.Id, devices[0].User__c, 'Device should be linked to running user');
            System.assertNotEquals(null, devices[0].DeviceIdHash__c, 'Device Id should be populated');
            System.assertEquals(nowDateTime.addDays(mfaSettings.trustDays), devices[0].ExpiresAt__c, 'Expiry should be same as datetime now');
            System.assertNotEquals(null, devices[0].FirstTrustedAt__c, 'First Trusted at should be populated');
            System.assertNotEquals(null, devices[0].LastSeenAt__c, 'Last Seen at should be populated');
            System.assertNotEquals(null, devices[0].Signature__c, 'Signature should be populated');
            System.assertEquals(null, devices[0].ConsentRevokeReason__c, 'Revoke reason should be not be populated');
            System.assertEquals(false, devices[0].IsRevoked__c, 'Is Revoked should be false');
            System.assertEquals(false, devices[0].IsExpired__c, 'Is Expired should be false');
        }
    }

    @IsTest
    static void testEstablishTrustAndValidateMultipleUsersUsingSameDevice() {
        List<Contact> contacts = UthContact.getAll();
        User user1 = UthUser.getUserUsingContactId(new List<Id>{contacts[0].Id})[0];
        User user2 = UthUser.getUserUsingContactId(new List<Id>{contacts[1].Id})[0];
        DateTime nowDateTime = Datetime.now();
        MfaSettingDecorator mfaSettings = new MfaSettingDecorator();

        Test.startTest();
            PageReference pageRef = Page.MfaOtpVerificationV2;
            Test.setCurrentPage(pageRef);
            
            System.runAs(user1) {
                MfaTrustedDeviceService mfaSercive = new MfaTrustedDeviceService();
                mfaSercive.nowDateTime = nowDateTime;
                Boolean established = mfaSercive.establishTrust();
                Boolean trusted = mfaSercive.isTrustedDevice;
                List<CustomerTrustedDevice__c> devices = UthCustomerTrustedDevice.getCustomerTrustedDevicesByIserId(user1.Id);

                System.assertEquals(true, established, 'Trust establishment should succeed');
                System.assertEquals(1, devices.size(), 'Trusted device record should be created');
                System.assertEquals(true, trusted, 'User should be trusted with valid cookie and device record');
            }
            System.runAs(user2) {
                MfaTrustedDeviceService mfaSercive = new MfaTrustedDeviceService();
                mfaSercive.nowDateTime = nowDateTime.addDays(1);
                Boolean established = mfaSercive.establishTrust();
                Boolean trusted = mfaSercive.isTrustedDevice;
                List<CustomerTrustedDevice__c> devices = UthCustomerTrustedDevice.getCustomerTrustedDevicesByIserId(user2.Id);

                System.assertEquals(true, established, 'Trust establishment should succeed');
                System.assertEquals(1, devices.size(), 'Trusted device record should be created');
                System.assertEquals(true, trusted, 'User should be trusted with valid cookie and device record');
            }
        Test.stopTest();

        List<CustomerTrustedDevice__c> devices = UthCustomerTrustedDevice.getAll();
        System.assertEquals(2, devices.size(), 'Trusted device size should be 2');
        System.assertEquals(devices[0].DeviceIdHash__c, devices[1].DeviceIdHash__c, 'Trusted device id should be equal for same device');

        List<CustomerTrustedDevice__c> devices1 = UthCustomerTrustedDevice.getCustomerTrustedDevicesByIserId(user1.Id);
        List<CustomerTrustedDevice__c> devices2 = UthCustomerTrustedDevice.getCustomerTrustedDevicesByIserId(user2.Id);

        System.assertEquals(1, devices1.size(), 'Trusted device size should be 1');
        System.assertEquals(nowDateTime.addDays(mfaSettings.trustDays), devices1[0].ExpiresAt__c, 'Expiry should be same as datetime now');
        System.assertNotEquals(null, devices1[0].DeviceIdHash__c, 'Device Id should be populated');
        System.assertNotEquals(null, devices1[0].FirstTrustedAt__c, 'First Trusted at should be populated');
        System.assertNotEquals(null, devices1[0].LastSeenAt__c, 'Last Seen at should be populated');
        System.assertNotEquals(null, devices1[0].Signature__c, 'Signature should be populated');
        
        
        System.assertEquals(1, devices2.size(), 'Trusted device size should be 1');
        System.assertEquals(nowDateTime.addDays(mfaSettings.trustDays +1), devices2[0].ExpiresAt__c, 'Expiry should be same as datetime now + 1 day');
        System.assertNotEquals(null, devices2[0].DeviceIdHash__c, 'Device Id should be populated');
        System.assertNotEquals(null, devices2[0].FirstTrustedAt__c, 'First Trusted at should be populated');
        System.assertNotEquals(null, devices2[0].LastSeenAt__c, 'Last Seen at should be populated');
        System.assertNotEquals(null, devices2[0].Signature__c, 'Signature should be populated');
    }

    @IsTest
    static void testValidateRevokeConsentSingleUser() {
        List<Contact> contacts = UthContact.getAll();
        User user1 = UthUser.getUserUsingContactId(new List<Id>{contacts[0].Id})[0];

        Test.startTest();
            PageReference pageRef = Page.MfaOtpVerificationV2;
            Test.setCurrentPage(pageRef);
            System.runAs(user1) {
                MfaTrustedDeviceService mfaSercive = new MfaTrustedDeviceService();
                Boolean established = mfaSercive.establishTrust();
                Boolean trusted = mfaSercive.isTrustedDevice;
                MfaTrustedDeviceService.revokeTrustDevice();

                List<CustomerTrustedDevice__c> devices = UthCustomerTrustedDevice.getAll();
                System.assertEquals(1, devices.size(), 'Trusted device size should be 1');
                System.assertEquals(CustomerTrustedDeviceDecorator.REVOKE_REASON_ALLDEVICECONSENTREVOKED, devices[0].ConsentRevokeReason__c, 'Consent reason should be populated');

                MfaTrustedDeviceService mfaSercive1 = new MfaTrustedDeviceService();
                Boolean trusted1 = mfaSercive1.isTrustedDevice;
                System.assertEquals(false, trusted1, 'Device should not be trusted');
            }
        Test.stopTest();

        
    }

    @IsTest
    static void testMultipleUserConsentRemovedByOneUser() {
        List<Contact> contacts = UthContact.getAll();
        User user1 = UthUser.getUserUsingContactId(new List<Id>{contacts[0].Id})[0];
        User user2 = UthUser.getUserUsingContactId(new List<Id>{contacts[1].Id})[0];

        Test.startTest();
            PageReference pageRef = Page.MfaOtpVerificationV2;
            Test.setCurrentPage(pageRef);
            System.runAs(user1) {
                MfaTrustedDeviceService mfaSercive = new MfaTrustedDeviceService();
                Boolean established = mfaSercive.establishTrust();
                Boolean trusted = mfaSercive.isTrustedDevice;
            }
            System.runAs(user2) {
                MfaTrustedDeviceService mfaSercive = new MfaTrustedDeviceService();
                Boolean established = mfaSercive.establishTrust();
                Boolean trusted = mfaSercive.isTrustedDevice;
                MfaTrustedDeviceService.revokeTrustDevice();

                MfaTrustedDeviceService mfaSercive1 = new MfaTrustedDeviceService();
                Boolean trusted1 = mfaSercive1.isTrustedDevice;
                System.assertEquals(false, trusted1, 'Device should not be trusted');
            }
        Test.stopTest();

        List<CustomerTrustedDevice__c> devices = UthCustomerTrustedDevice.getAll();
        System.assertEquals(2, devices.size(), 'Trusted device size should be 2');
        System.assertEquals(null, devices[0].ConsentRevokeReason__c, 'Firs useer consent should not be revoked');
        System.assertEquals(CustomerTrustedDeviceDecorator.REVOKE_REASON_ALLDEVICECONSENTREVOKED, devices[1].ConsentRevokeReason__c, 'Consent reason should be populated');
    }

    @IsTest
    static void testExistingCookieExpiredWillCreateNewDeviceEntry() {
        List<Contact> contacts = UthContact.getAll();
        User user = UthUser.getUserUsingContactId(new List<Id>{contacts[0].Id})[0];

        System.runAs(user) {
            Test.startTest();
            PageReference pageRef = Page.MfaOtpVerificationV2;
            Test.setCurrentPage(pageRef);
                MfaTrustedDeviceService mfaSercive = new MfaTrustedDeviceService();
                Boolean established = mfaSercive.establishTrust();
                Boolean trusted = mfaSercive.isTrustedDevice;
                List<CustomerTrustedDevice__c> devices = UthCustomerTrustedDevice.getCustomerTrustedDevicesByIserId(user.Id);

                System.assertEquals(true, established, 'Trust establishment should succeed');
                System.assertEquals(true, trusted, 'User should be trusted with valid cookie and device record');
                System.assertEquals(1, devices.size(), 'Trusted device record should be created');

                // Manually setting cookie value to null as we cannot set the cookie expiry and mimic browser behaviour
                Cookie cookie = ApexPages.currentPage().getCookies().get(MfaTrustedDeviceService.TRUST_COOKIE_NAME);
                Cookie expired = new Cookie(MfaTrustedDeviceService.TRUST_COOKIE_NAME, null, null, null, true, 'Lax', true);
                ApexPages.currentPage().setCookies(new Cookie[]{ expired });
                cookie = ApexPages.currentPage().getCookies().get(MfaTrustedDeviceService.TRUST_COOKIE_NAME);
            
                MfaTrustedDeviceService mfaSercive1 = new MfaTrustedDeviceService();
                Boolean trusted1 = mfaSercive1.isTrustedDevice;
                System.assertEquals(false, trusted1, 'User should not be trusted with valid cookie and device record');

                Boolean established1 = mfaSercive1.establishTrust(); 

                List<CustomerTrustedDevice__c> resultDevices = UthCustomerTrustedDevice.getCustomerTrustedDevicesByIserId(user.Id);
                System.assertEquals(2, resultDevices.size(), 'Trusted device record should be created');
            Test.stopTest();
        }
    }

    @IsTest
    static void testExistingDeviceExpiredWillCreateNewDeviceEntry() {
        List<Contact> contacts = UthContact.getAll();
        User user = UthUser.getUserUsingContactId(new List<Id>{contacts[0].Id})[0];

        System.runAs(user) {
            Test.startTest();
            PageReference pageRef = Page.MfaOtpVerificationV2;
            Test.setCurrentPage(pageRef);
            

                MfaTrustedDeviceService mfaSercive = new MfaTrustedDeviceService();
                Boolean established = mfaSercive.establishTrust();
                List<CustomerTrustedDevice__c> devices = UthCustomerTrustedDevice.getCustomerTrustedDevicesByIserId(user.Id);
                Boolean trusted = mfaSercive.isTrustedDevice;

                System.assertEquals(true, established, 'Trust establishment should succeed');
                System.assertEquals(true, trusted, 'User should be trusted with valid cookie and device record');
                System.assertEquals(1, devices.size(), 'Trusted device record should be created');

                // Manually set the device expired in SF database
                update UthCustomerTrustedDevice.serExpiryDateTime(devices[0], Datetime.now().addDays(-1));
            
                MfaTrustedDeviceService mfaSercive1 = new MfaTrustedDeviceService();
                Boolean trusted1 = mfaSercive1.isTrustedDevice;

                System.assertEquals(false, trusted1, 'User should not be trusted with valid cookie and device record');

                Boolean established1 = mfaSercive1.establishTrust(); 

                List<CustomerTrustedDevice__c> resultDevices = UthCustomerTrustedDevice.getCustomerTrustedDevicesByIserId(user.Id);
                System.assertEquals(2, resultDevices.size(), 'Trusted device record should be created');
            Test.stopTest();
        }
    }

    @IsTest
    static void testInvalidCookieSignatureFails() {
        List<Contact> contacts = UthContact.getAll();
        List<User> users = UthUser.getUserUsingContactId(new List<Id>{contacts[0].Id});

        System.runAs(users[0]) {
            PageReference pageRef = Page.MfaOtpVerificationV2;
            Test.setCurrentPage(pageRef);

            String badValue = 'invalidpayload';
            Cookie badCookie = new Cookie(
                MfaTrustedDeviceService.TRUST_COOKIE_NAME,
                badValue,
                null,
                300,
                true,
                'Lax',
                true
            );
            ApexPages.currentPage().setCookies(new Cookie[] { badCookie });

            Test.startTest();

            MfaTrustedDeviceService mfaSercive = new MfaTrustedDeviceService();
            Boolean trusted = mfaSercive.isTrustedDevice;

            Test.stopTest();

            System.assertEquals(false, trusted, 'Invalid cookie signature should not be trusted');
        }
    }
}