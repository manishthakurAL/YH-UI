@isTest(seeAllData=false)
public with sharing class CaseDupeCheckerOnOpenAndClosedImplTest {
    @testSetup
        static void setUpTestData(){
            UthFeatureSwitches.enableAllRT();

        	TriggerBase.bypass('Account');
            TriggerBase.bypass('Case');
        	List<Account> accountList = new List<Account>();
            accountList.add(UthAccount.buildPersonAccount('fNameOne', 'lNameOne'));
            accountList.add(UthAccount.buildPersonAccount('fNameTwo', 'lNameTwo'));
            accountList.add(UthAccount.buildPersonAccount('fNameThree', 'lNameThree'));
            accountList.add(UthAccount.buildPersonAccount('fNameFour', 'lNameFour'));
        	insert accountList;

            Contact contactOne;
            Contact contactTwo;
            Contact contactThree;
            
            for(Contact contact : UthContact.getAll()){
                if(contact.LastName == 'lNameOne'){
                    contactOne = contact;
                } else if(contact.LastName == 'lNameTwo'){
                    contactTwo = contact;
                } else if(contact.LastName == 'lNameThree'){
                    contactThree = contact;
                }
            }
            
            YH_Property__c property = uthProperty.buildPropertyWithDesignAssumptions(
                PropertyDecorator.AUTHORITY_BARNSLEY,
                PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE,
                PropertyDecorator.AUTHCODE_E08000038,
                PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
                PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE
                );
            insert property;

            List<YH_Tenancy__c> tenancyList = new List<YH_Tenancy__c>();
            tenancyList.add(UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT));
            tenancyList.add(UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO));
            insert tenancyList;

            YH_Tenancy__c tenancyJoint;
            YH_Tenancy__c tenancySolo;

            for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                    tenancyJoint = tenancy;
                }else if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_SOLO){
                    tenancySolo = tenancy;
                }
            }

            List<Member__c> memberList = new List<Member__c>();
            memberList.add(UthMember.build(contactOne.Id, tenancyJoint.Id, MemberDecorator.TYPE_JOINT));
            memberList.add(UthMember.build(contactTwo.Id, tenancyJoint.Id, MemberDecorator.TYPE_JOINT));
            memberList.add(UthMember.build(contactThree.Id, tenancySolo.Id, MemberDecorator.TYPE_SOLO));
            insert memberList;

        	TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('Case');
    	}

        @isTest
        static void testBreachASBGenericCase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;
            Case caseRecord;
            Case caseRecordForTest;
            Map<Id, List<Case>> result;
            List<Case> caseRecords = new List<Case>();
            
            System.runAs(UthUser.getBreachAndASBUser(UserInfo.getUserId())) {
                for(Contact contact : UthContact.getAll()){
                    if(contact.LastName == 'lNameOne'){
                        contactOne = contact;
                    } else if(contact.LastName == 'lNameTwo'){
                        contactTwo = contact;
                    } 
                }

                for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                    if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                        tenancyJoint = tenancy;
                    }
                }

                caseRecords.add(UthCase.buildBreachAndASBCaseWithTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id));
                caseRecords.add(UthCase.buildBreachAndASBCaseWithTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id));
                insert caseRecords;

                Case caseRecordWithClosedStatus = UthCase.buildBreachAndASBCaseWithTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id);
                insert caseRecordWithClosedStatus;
                caseRecordWithClosedStatus = UthCase.buildBreachAndASBCaseWithStatusClosed(caseRecordWithClosedStatus);
                update caseRecordWithClosedStatus;
                
                Test.startTest();
                    try {
                        caseRecordForTest = UthCase.buildBreachAndASBCaseWithTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id);
                        
                        CaseDuplicateCheckerService caseDuplicateCheckerService = new CaseDuplicateCheckerService();
                        result =  caseDuplicateCheckerService.getDuplicate(new List<Case>{caseRecordForTest});
                    } 
                    catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                    }
        	    Test.stopTest();
            }

            Assert.areEqual(1, result.size(), 'Result size should be 1');
            Assert.areEqual(3, result.get(caseRecordForTest?.Id).size(), 'Duplicate case result list size should be 3');
    	}
}