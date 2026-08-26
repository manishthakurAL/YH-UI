@isTest
public class CustomPortalThemeControllerTest {
    @TestSetup
    static void setupTestData() {
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact; 

        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        insert property; 
        YH_Tenancy__c tenancyJoint = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT,'123456');
        tenancyJoint.StartDate__c = System.today().addyears(-6);
        insert tenancyJoint;
        insert UthMember.build(contact.Id, tenancyJoint.Id, MemberDecorator.TYPE_JOINT, true);
        User portalUser = UthUser.buildPortalUser('test','testlast',contact.Id);
        insert portalUser;
        System.runAs(new User(Id=UserInfo.getUserId())){
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.YH_CUSTOMERCOMMUNITY_USER_PS).Id;
            UthPermissionAssigner.assignPermissionSet(portalUser.Id, permissionSetId);
            YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];
            Group tenancyGroup = UthGroup.build('TenancySharing' + resultTenancy.Name.replace('-', '_'));
            insert tenancyGroup;
            insert UthGroupMember.build(tenancyGroup.Id, portalUser.Id);
            YH_Tenancy__Share tenancyShare = UthTenancyShare.build(resultTenancy.Id, tenancyGroup.Id);
            insert tenancyShare;
        }
            
    }
    
    @isTest
    static void testGetNavigationMenuItemsWithoutCommunity() {
        List<CustomPortalThemeController.NavItem> result = 
            CustomPortalThemeController.getNavigationMenuItems('TestMenu');
        Assert.areEqual(0, result.size(), 'Should return empty list when no community exists');
    }
    
    @isTest
    static void testGetNavigationMenuItemsWithBlankMenuName() {
        List<CustomPortalThemeController.NavItem> result = 
            CustomPortalThemeController.getNavigationMenuItems('');
        Assert.areEqual(0, result.size(), 'Should return empty list when menu name is blank');
    }
    
    @isTest
    static void testGetNavigationMenuItemsWithNullMenuName() {
        List<CustomPortalThemeController.NavItem> result = 
            CustomPortalThemeController.getNavigationMenuItems(null);
        Assert.areEqual(0, result.size(), 'Should return empty list when menu name is null');
    }
    
    @isTest
    static void testGetCurrentUser() {
        User testUser = [SELECT Id, FirstName, LastName, Name FROM User WHERE ContactId = :UthContact.getAll()[0].Id LIMIT 1];
        System.runAs(testUser) {
            CustomPortalThemeController.UserDisplay result = 
                CustomPortalThemeController.getCurrentUser();
            
            System.assertNotEquals(null, result, 'Should return user display object');
            Assert.areEqual(testUser.Name, result.name, 'User name should match');
            Assert.areEqual(testUser.FirstName, result.firstname, 'First name should match');
        }   
    }
    
    @isTest
    static void testGetCurrentUserInitials() {
        User testUser = [SELECT Id, FirstName, LastName FROM User WHERE ContactId = :UthContact.getAll()[0].Id LIMIT 1];
        System.runAs(testUser) {
            CustomPortalThemeController.UserDisplay result = 
                CustomPortalThemeController.getCurrentUser();
            
            String expectedInitials = '';
            if (String.isNotBlank(testUser.FirstName)) {
                expectedInitials += testUser.FirstName.left(1);
            }
            if (String.isNotBlank(testUser.LastName)) {
                expectedInitials += testUser.LastName.left(1);
            }
            expectedInitials = expectedInitials.toUpperCase();
            
            Assert.areEqual(expectedInitials, result.initials, 'Initials should be calculated correctly');
        }
    }
    
    @isTest
    static void testGetCurrentUserSubtitle() {
        User testUser = [SELECT Id, FirstName, LastName FROM User WHERE ContactId = :UthContact.getAll()[0].Id LIMIT 1];
        System.runAs(testUser) {
            CustomPortalThemeController.UserDisplay result = 
                CustomPortalThemeController.getCurrentUser();
            
            System.assertNotEquals(null, result.subtitle, 'Subtitle should not be null');
            System.assert(result.subtitle.contains('Tenant since'), 'Subtitle should contain tenant since text');
        }
    }
    
    @isTest
    static void testNavItemConstructor() {
        CustomPortalThemeController.NavItem item = 
new CustomPortalThemeController.NavItem('Test Label', 'test_action', 'Link', null);
        
        Assert.areEqual('Test Label', item.label, 'Label should match');
        Assert.areEqual('test_action', item.actionValue, 'Action value should match');
        Assert.areEqual('Link', item.itemType, 'Item type should match');
    }
    
    @isTest
    static void testUserDisplayFields() {
        User testUser = [SELECT Id, FirstName, LastName FROM User WHERE ContactId = :UthContact.getAll()[0].Id LIMIT 1];

        System.runAs(testUser) {
            CustomPortalThemeController.UserDisplay display = 
                CustomPortalThemeController.getCurrentUser();
            display.name = 'Test User';
            display.firstName = 'Test';
            display.initials = 'TU';
            display.subtitle = 'Tenant since'+ UthMember.getMembersByContactId(UthContact.getAll()[0].Id)[0].TenancyStartDate__c.year(); 
            
            Assert.areEqual('Test User', display.name, 'Name field should be set');
            Assert.areEqual('Test', display.firstName, 'FirstName field should be set');
            Assert.areEqual('TU', display.initials, 'Initials field should be set');
            Assert.areEqual('Tenant since' + System.today().addyears(-6).year(), display.subtitle, 'Subtitle field should be set');
        }
    }
}