@IsTest
public class ManageCustomerPortalSelfRegCtrTest {
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
    static void validationTest(){
        PageReference pageRef = Page.ManageCustomerPortalSelfRegistrationVF;
        Test.setCurrentPage(pageRef);
        PageReference pageRefResult;
        List<ApexPages.Message> msgs;
        ManageCustomerPortalSelfRegistrationCtr ctrl;

        Test.startTest();
            ctrl = new ManageCustomerPortalSelfRegistrationCtr(null, null, null, null, null);
            pageRefResult = ctrl.registerUser();
            msgs = ApexPages.getMessages();
        Test.stopTest();

        Assert.areEqual(null, pageRefResult, 'pageRefResult shuld be null');
    }

    @isTest
    static void createExternalUserTest(){
        TriggerBase.bypass('Account');
        TriggerBase.bypass('YH_Tenancy__c');
        TriggerBase.bypass('Member__c');
        Date dobThree = Date.newInstance(1981, 03, 15);
            insert new List<Account>{
                UthAccount.buildPersonAccount('JamesThree', 'DoeThree', 'jamesdoethree7895728975967@randomemail.random', '07458256717', dobThree,'KR4 3RT')
                
            };

            YH_Property__c property = UthProperty.getAll()[0];

            YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        	insert tenancy;

            List<Member__c> memberList = new List<Member__c>{
                UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('JamesThree', 'DoeThree')[0].Id,tenancy.Id,MemberDecorator.TYPE_SOLO)
            };
            insert memberList;
        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('YH_Tenancy__c');
        TriggerBase.clearBypass('Member__c');

        PageReference pageRef = Page.ManageCustomerPortalSelfRegistrationVF;
        Test.setCurrentPage(pageRef);
        PageReference pageRefResult;
        ManageCustomerPortalSelfRegistrationCtr ctrl;

        Test.startTest();
            ctrl = new ManageCustomerPortalSelfRegistrationCtr('JamesThree', 'DoeThree', 'jamesdoethree7895728975967@randomemail.random', dobThree, 'KR4 3RT');
            pageRefResult = ctrl.registerUser();
        Test.stopTest();

        Assert.areEqual(null, pageRefResult, 'pageRefResult shuld be null');
        Assert.areEqual(true, ctrl.isUserCreationSuccessful, 'isUserCreationSuccessful must be true.');
        Assert.isTrue(ctrl.sucessMessage.contains(Label.UserCreatedSuccessfully), 'sucessMessage must be UserCreatedSuccessfully.');
    }

    @isTest
    static void externaluserAlreadyexistTest(){
        Date dobOne = Date.newInstance(1983, 06, 22);

        PageReference pageRef = Page.ManageCustomerPortalSelfRegistrationVF;
        Test.setCurrentPage(pageRef);
        PageReference pageRefResult;
        ManageCustomerPortalSelfRegistrationCtr ctrl;

        Test.startTest();
            ctrl = new ManageCustomerPortalSelfRegistrationCtr('JamesOne', 'DoeOne', 'jamesdoeone7895728975982@randomemail.random', dobOne, 'KR4 3RT');
            pageRefResult = ctrl.registerUser();
        Test.stopTest();

        Assert.areEqual(null, pageRefResult, 'pageRefResult shuld be null');
        Assert.areEqual(true, ctrl.isUserCreationSuccessful, 'isUserCreationSuccessful must be true.');
        Assert.isTrue(ctrl.sucessMessage.contains(Label.UserCreatedSuccessfully), 'sucessMessage must be UserCreatedSuccessfully.');
    }

    @isTest
    static void noMatchUsingEmailOrDOBTest(){
        Date dobThree = Date.newInstance(1983, 06, 22);
        PageReference pageRef = Page.ManageCustomerPortalSelfRegistrationVF;
        Test.setCurrentPage(pageRef);
        PageReference pageRefResult;
        ManageCustomerPortalSelfRegistrationCtr ctrl;

        Test.startTest();
            ctrl = new ManageCustomerPortalSelfRegistrationCtr('JamesThree', 'DoeThree', 'jamesdoethree7895728975967@randomemail.random', dobThree, 'KR4 3RT');
            pageRefResult = ctrl.registerUser();
        Test.stopTest();

        Assert.areEqual(null, pageRefResult, 'pageRefResult shuld be null');
        Assert.areEqual(false, ctrl.isUserCreationSuccessful, 'isUserCreationSuccessful must be false.');
        Assert.areEqual(null, ctrl.sucessMessage, 'sucessMessage must be null.');
        Assert.isTrue(ctrl.failureMessage.contains(Label.GenericContactUsMessage), 'failureMessage must be GenericContactUsMessage.');
    }

    @isTest
    static void duplicateMatchUsingEmailOnlyTest(){
        Date dobOne = Date.newInstance(1983, 06, 25);
        PageReference pageRef = Page.ManageCustomerPortalSelfRegistrationVF;
        Test.setCurrentPage(pageRef);
        PageReference pageRefResult;
        ManageCustomerPortalSelfRegistrationCtr ctrl;

        Test.startTest();
            ctrl = new ManageCustomerPortalSelfRegistrationCtr('JamesOne', 'DoeOne', 'jamesdoeone7895728975982@randomemail.random', dobOne, 'KR4 3RZ');
            pageRefResult = ctrl.registerUser();
        Test.stopTest();

        Assert.areEqual(null, pageRefResult, 'pageRefResult shuld be null');
        Assert.areEqual(false, ctrl.isUserCreationSuccessful, 'isUserCreationSuccessful must be false.');
        Assert.areEqual(null, ctrl.sucessMessage, 'sucessMessage must be null.');
        Assert.isTrue(ctrl.failureMessage.contains(Label.GenericContactUsMessage), 'failureMessage must be GenericContactUsMessage.');
    }

    @isTest
    static void duplicateMatchUsingEmailAndPostcodeNoMemberMatchTest(){
        Date dobOne = Date.newInstance(1983, 06, 22);
        PageReference pageRef = Page.ManageCustomerPortalSelfRegistrationVF;
        Test.setCurrentPage(pageRef);
        PageReference pageRefResult;
        ManageCustomerPortalSelfRegistrationCtr ctrl;

        Test.startTest();
            ctrl = new ManageCustomerPortalSelfRegistrationCtr('JamesOne', 'DoeOne', 'jamesdoeone7895728975982@randomemail.random', dobOne, 'KR4 3RZ');
            pageRefResult = ctrl.registerUser();
        Test.stopTest();

        Assert.areEqual(null, pageRefResult, 'pageRefResult shuld be null');
        Assert.areEqual(false, ctrl.isUserCreationSuccessful, 'isUserCreationSuccessful must be false.');
        Assert.areEqual(null, ctrl.sucessMessage, 'sucessMessage must be null.');
        Assert.isTrue(ctrl.failureMessage.contains(Label.GenericContactUsMessage), 'failureMessage must be GenericContactUsMessage.');
    }

    @isTest
    static void duplicateMatchUsingEmailAndPostcodeMemberMatchTest(){
        Date dobOne = Date.newInstance(1983, 06, 22);
        PageReference pageRef = Page.ManageCustomerPortalSelfRegistrationVF;
        Test.setCurrentPage(pageRef);
        PageReference pageRefResult;
        ManageCustomerPortalSelfRegistrationCtr ctrl;

        Test.startTest();
            ctrl = new ManageCustomerPortalSelfRegistrationCtr('JamesOne', 'DoeOne', 'jamesdoeone7895728975982@randomemail.random', dobOne, 'KR4 3RT');
            pageRefResult = ctrl.registerUser();
        Test.stopTest();

        Assert.areEqual(null, pageRefResult, 'pageRefResult shuld be null');
        Assert.areEqual(true, ctrl.isUserCreationSuccessful, 'isUserCreationSuccessful must be true.');
        Assert.areEqual(null, ctrl.failureMessage, 'failureMessage must be null.');
        Assert.isTrue(ctrl.sucessMessage.contains(Label.UserCreatedSuccessfully), 'sucessMessage must be UserCreatedSuccessfully.');
    }

    @isTest
    static void psgAssignmentTest(){
        Date dobOne = Date.newInstance(1983, 06, 22);
        PageReference pageRef = Page.ManageCustomerPortalSelfRegistrationVF;
        Test.setCurrentPage(pageRef);
        List<Contact> contacts = UthContact.getAll();
        List<User> userOne = UthUser.getUserUsingContactId(new List<Id>{contacts[0].Id});

        PermissionSetGroup psg = UthPermissionSet.getPSGByName(PermissionSetDecorator.YH_CUSTOMERPORTAL_PSG);
         // force calculation of the PSG if it is not already Updated
        if (psg.Status != PermissionSetDecorator.STATUS_UPDATED) {
            Test.calculatePermissionSetGroup(psg.Id);
        }
        Boolean alreadyAssigned = UthPermissionSet.getPermissionSetGrpAssignment(userOne[0].Id, psg.Id).size() > 0;

        Assert.isTrue(!alreadyAssigned, 'Permission set should not be assigned');

        PageReference pageRefResult;
        ManageCustomerPortalSelfRegistrationCtr ctrl;

        Test.startTest();

            new ManageCustomerPortalSelfRegistrationCtr.ManageCustomerPortalSelfRegistrationCtrWS(userOne[0].Id).assignCustomerPortalPSG();
        Test.stopTest();

        Boolean alreadyAssignedResult = UthPermissionSet.getPermissionSetGrpAssignment(userOne[0].Id, psg.Id).size() > 0;

        Assert.isTrue(alreadyAssignedResult, 'Permission set should be assigned');
    }

    @isTest
    static void accountWithDuplicateEmailAndOnlyOneDuplicateDOBMatch(){
        TriggerBase.bypass('Account');
        TriggerBase.bypass('YH_Tenancy__c');
        TriggerBase.bypass('Member__c');
            Date dobOne = Date.newInstance(1983, 01, 01);
            Date dobTwo = Date.newInstance(1982, 02, 02);
            List<Account> accounts = new List<Account>{
                UthAccount.buildPersonAccount('EmailDOBOne', 'EmailDOBOne', 'EmailDOBOneTwo123456789@randomemail.random', '07458256715', dobOne,'KR4 3RT'),
                UthAccount.buildPersonAccount('EmailDOBOne', 'EmailDOBOne', 'EmailDOBOneTwo123456789@randomemail.random', '07458256716', dobTwo,'KR4 3RT')
            };
            insert accounts;
            
            YH_Property__c property = UthProperty.buildPropertyWithAssetClass('Leeds',
                    PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
                    PropertyDecorator.RENT_TYPE_MARKET_RENT, PropertyDecorator.PRODUCT_TYPE_MARKETRENTAL,
                    '123 Test St', 'London', 'KR4 3RZ',PropertyDecorator.FLAT_ASSET_CLASS);
            insert property;

            YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT);
            insert tenancy;

            List<Member__c> memberList = new List<Member__c>{
                UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('EmailDOBOne', 'EmailDOBOne')[0].Id,tenancy.Id,MemberDecorator.TYPE_JOINT),
                UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('EmailDOBOne', 'EmailDOBOne')[1].Id,tenancy.Id,MemberDecorator.TYPE_JOINT)
            };
            insert memberList;
        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('YH_Tenancy__c');
        TriggerBase.clearBypass('Member__c');

        PageReference pageRef = Page.ManageCustomerPortalSelfRegistrationVF;
        Test.setCurrentPage(pageRef);
        PageReference pageRefResult;
        ManageCustomerPortalSelfRegistrationCtr ctrl;
        Account accountResult;

        Test.startTest();
            ctrl = new ManageCustomerPortalSelfRegistrationCtr('EmailDOBOne', 'EmailDOBOne', 'EmailDOBOneTwo123456789@randomemail.random', dobOne, 'KR4 3RZ');
            accountResult = ctrl.getMatchedAccountBasedonEmailAndDOB();
        Test.stopTest();

        Assert.areNotEqual(null, accountResult, 'Result account should not be null');
        Assert.areEqual(accounts[0].Id, accountResult.Id, 'Result account should not be null');
    }

    @isTest
    static void accountWithDuplicateEmailAndDuplicateDOBMatchMethodTest(){
        TriggerBase.bypass('Account');
        TriggerBase.bypass('YH_Tenancy__c');
        TriggerBase.bypass('Member__c');
            Date dobOne = Date.newInstance(1983, 06, 22);
            Date dobTwo = Date.newInstance(1982, 06, 22);
            insert new List<Account>{
                UthAccount.buildPersonAccount('EmailDOBOne', 'EmailDOBOne', 'EmailDOBOneTwo123456789@randomemail.random', '07458256715', dobOne,'KR4 3RT'),
                UthAccount.buildPersonAccount('EmailDOBOne', 'EmailDOBOne', 'EmailDOBOneTwo123456789@randomemail.random', '07458256716', dobOne,'KR4 3RT')
            };
            
            YH_Property__c property = UthProperty.buildPropertyWithAssetClass('Leeds',
                    PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
                    PropertyDecorator.RENT_TYPE_MARKET_RENT, PropertyDecorator.PRODUCT_TYPE_MARKETRENTAL,
                    '123 Test St', 'London', 'KR4 3RZ',PropertyDecorator.FLAT_ASSET_CLASS);
            insert property;

            YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT);
            insert tenancy;

            List<Member__c> memberList = new List<Member__c>{
                UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('EmailDOBOne', 'EmailDOBOne')[0].Id,tenancy.Id,MemberDecorator.TYPE_JOINT),
                UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('EmailDOBOne', 'EmailDOBOne')[1].Id,tenancy.Id,MemberDecorator.TYPE_JOINT)
            };
            insert memberList;
        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('YH_Tenancy__c');
        TriggerBase.clearBypass('Member__c');

        PageReference pageRef = Page.ManageCustomerPortalSelfRegistrationVF;
        Test.setCurrentPage(pageRef);
        PageReference pageRefResult;
        ManageCustomerPortalSelfRegistrationCtr ctrl;
        Account accountResult;

        Test.startTest();
            ctrl = new ManageCustomerPortalSelfRegistrationCtr('EmailDOBOne', 'EmailDOBOne', 'EmailDOBOneTwo123456789@randomemail.random', dobOne, 'KR4 3RZ');
            accountResult = ctrl.getMatchedAccountBasedonEmailAndDOB();
        Test.stopTest();

        Assert.areEqual(null, accountResult, 'Result account should be null');
    }
}