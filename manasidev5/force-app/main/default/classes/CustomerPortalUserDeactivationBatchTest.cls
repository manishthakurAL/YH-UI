@IsTest
public class CustomerPortalUserDeactivationBatchTest {
    @TestSetup
    static void setUpTestData(){
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.buildUser(roleId,adminProfileId,'fname1','lname1');
        insert adminUser;

        System.runAs(adminUser){
            TriggerBase.bypass('Account');
            TriggerBase.bypass('YH_Tenancy__c');
            TriggerBase.bypass('Member__c');
            TriggerBase.bypass('Case');
                insert new List<Account>{
                    UthAccount.buildPersonAccount('John', 'Doe','123 Test St','London','AB123CD'),
                    UthAccount.buildPersonAccount('James', 'Fiorello','123 Test St','London','AB123CD')
                };
                
                YH_Property__c property = UthProperty.buildPropertyWithAssetClass('Leeds',
                        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
                        PropertyDecorator.RENT_TYPE_MARKET_RENT, PropertyDecorator.PRODUCT_TYPE_MARKETRENTAL,
                        '123 Test St', 'London', 'AB123CD',PropertyDecorator.FLAT_ASSET_CLASS);
                insert property;

                YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT);
        	    insert tenancy;

                YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];

                Group tenancyGroup = UthGroup.build('TenancySharing' + resultTenancy.Name.replace('-', '_'));
                insert tenancyGroup;

                YH_Tenancy__Share tenancyShare = UthTenancyShare.build(resultTenancy.Id, tenancyGroup.Id);
                insert tenancyShare;

                BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
                Date twoDaysPastBusinessdays = Date.ValueOf(businessHourService.addBusinessDays( Datetime.now(), -3));

                List<Member__c> memberList = new List<Member__c>{
                    UthMember.buildWithOccupancyEndDate(UthContact.getContactByName('John','Doe')[0].Id,tenancy.Id,MemberDecorator.TYPE_JOINT, twoDaysPastBusinessdays),
                    UthMember.buildWithOccupancyEndDate(UthContact.getContactByName('James','Fiorello')[0].Id,tenancy.Id,MemberDecorator.TYPE_JOINT, Date.today().addDays(10))
                };
                insert memberList;

                List<Contact> contacts = UthContact.getAll();
                List<Case> caseRecords = new List<Case>();
                for(Integer i = 0; i < contacts.size(); i++){
                    Case caseRecord = UthCase.buildPermissionCaseWithSharingReason(
                        contacts[i].Id, 
                        tenancy.Id, 
                        CaseDecorator.CASE_TYPE_PERMISSION_FOR_A_LoDGER_OR_SUBLET,
                        CaseDecorator.CASESHARINGREASON_TENANT);
                    caseRecords.add(caseRecord);
                }
                insert caseRecords;

                List<User> userList = new List<User>{
                    UthUser.buildCommunityUser(contacts[0].Id,null),
                    UthUser.buildCommunityUser(contacts[1].Id,null)
                };
                insert userList;
            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('YH_Tenancy__c');
            TriggerBase.clearBypass('Member__c');
            TriggerBase.clearBypass('Case');
        }
    }

    @isTest
    static void testExecuteAutoCloseBatchUserRole(){
        List<Contact> contacts = UthContact.getAll();

        System.runAs((new User(Id = UserInfo.getUserId()))){
            Test.startTest();
                CustomerPortalUserDeactivationBatch batch = new CustomerPortalUserDeactivationBatch(10, 30);
                batch.chatterImpl = new MockChatterPoster();
                Database.executeBatch(batch);
            Test.stopTest();
        }

        List<User> userOne = UthUser.getUserUsingContactId(new List<Id>{contacts[0].Id});
        List<User> userTwo = UthUser.getUserUsingContactId(new List<Id>{contacts[1].Id});
        Assert.areEqual(false, userOne[0].IsActive, 'User One should be inactive as their occupancy has ended');
        Assert.areEqual(true, userTwo[0].IsActive, 'User Two should be active as their occupancy has not ended');
    }  

    private class MockChatterPoster implements ChatterInterface { 
        public ConnectApi.BatchResult[] postToChatterFeedBatchResults(Id subjectId, List<String> messages) {  
           return new List<ConnectApi.BatchResult>();
        }  
    }
}