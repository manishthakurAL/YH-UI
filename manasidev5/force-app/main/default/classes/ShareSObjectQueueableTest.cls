@isTest
public with sharing class ShareSObjectQueueableTest {
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

                List<Member__c> memberList = new List<Member__c>{
                    UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('John','Doe')[0].Id,tenancy.Id,MemberDecorator.TYPE_JOINT),
                    UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('James','Fiorello')[0].Id,tenancy.Id,MemberDecorator.TYPE_JOINT)
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
                
            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('YH_Tenancy__c');
            TriggerBase.clearBypass('Member__c');
            TriggerBase.clearBypass('Case');
        }
    }

    @isTest
    static void testCreateActiveUser(){
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.getUser(adminProfileId,'fname1','lname1')[0];
        
        List<Contact> contacts = UthContact.getAll();
        List<Case> cases = UthCase.getAll();
        YH_Tenancy__c resultTenancy = UthTenancy.getAll()[0];

        List<User> userList = new List<User>{
            UthUser.buildCommunityUser(contacts[0].Id,null),
            UthUser.buildCommunityUser(contacts[1].Id,null),
            UthUser.buildUser(null,adminProfileId,'fnameTwo','lnameTwo')
        };
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
                insert userList;
                ShareSObjectQueueable shareSObjectQueueable = new ShareSObjectQueueable(new List<Id>{cases[0].Id, cases[1].Id});
                System.enqueueJob(shareSObjectQueueable);
            Test.stopTest();
        }

        
        List<CaseShare> caseShares = UthCaseShare.getAllUsingCaseId(new List<Id>{cases[0].Id, cases[1].Id});
        
        System.Assert.areEqual(2, caseShares.size(), 'Two case share record should exist');
    }
}