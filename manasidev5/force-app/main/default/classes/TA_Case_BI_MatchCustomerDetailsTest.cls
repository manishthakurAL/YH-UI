@isTest
public class TA_Case_BI_MatchCustomerDetailsTest {
    @TestSetup
    static void makeData() {
            TriggerBase.bypass('Account');
            TriggerBase.bypass('YH_Tenancy__c');
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
            List<Member__c> memberList = new List<Member__c>{
            	UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('John','Doe')[0].Id,tenancy.Id,MemberDecorator.TYPE_JOINT),
                UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('James','Fiorello')[0].Id,tenancy.Id,MemberDecorator.TYPE_JOINT)
        	};
        	insert memberList;
            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('YH_Tenancy__c');
        }
        
		@isTest
        static void testTenancyMatchAndDuplicate(){
            YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
            List<Contact> contactList = UthContact.getAll();
            Case caseRec = UthCase.buildTerminationCaseForGuestPortal('John', 'Doe', 'James', 'Fiorello','123 Test St','London','AB12 3CD');
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
            Test.startTest(); 
                    insert caseRec; 
                   	Case caseRec2 = UthCase.buildTerminationCaseForGuestPortal('John', 'Doe', 'James', 'Fiorello','123 Test St','London','AB12 3CD');
                    insert caseRec2;
            Test.stopTest();
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
            Contact con = UthContact.getContactByName('John','Doe')[0];
            Member__c member = UthMember.getMembersByContactId(con.Id)[0];
            Case caseRecAfterInsert = UthCase.get(caseRec.Id);
            System.assertEquals(caseRecAfterInsert.Tenancy__c,tenancy.Id, 'Tenancy should be present');
            System.assertEquals(caseRecAfterInsert.contactId,con.Id, 'Contact Id should match');
            Case caseRecAfterInsert2 = UthCase.get(caseRec2.Id);
            System.assertEquals(caseRecAfterInsert2.Tenancy__c,null, 'Tenancy should not be present');
            System.assertEquals(caseRecAfterInsert2.contactId,null, 'Contact Id should not match');

    	}
    
    	@isTest
        static void testTenancyMatchNegative(){
            YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
            List<Contact> contactList = UthContact.getAll();
            Case caseRec = UthCase.buildTerminationCaseForGuestPortal('James', 'Doe', null, null,'123 Test St','London','AB12 3CD');
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
            Test.startTest(); 
                    insert caseRec; 
            Test.stopTest();
            Case caseRecAfterInsert = UthCase.get(caseRec.Id);
            System.assertEquals(caseRecAfterInsert.Tenancy__c, null, 'Tenancy should be present');
            System.assertEquals(caseRecAfterInsert.contactId, null, 'Contact Id should match');
            
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
    	}

        @isTest
        static void testTenancyMatchNegativeIncorrectRentTag(){
            YH_Property__c property = UthProperty.getAll()[0];
            property.YH_RentType__c = null;
            property.YH_ProductType__c = null;
            update property;	
            List<Contact> contactList = UthContact.getAll();
            Case caseRec = UthCase.buildTerminationCaseForGuestPortal('John', 'Doe', 'James', 'Fiorello','123 Test St','London','AB12 3CD');
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
            Test.startTest(); 
                    insert caseRec; 
            Test.stopTest();
            Case caseRecAfterInsert = UthCase.get(caseRec.Id);
            System.assertEquals(null, caseRecAfterInsert.Tenancy__c, 'Tenancy should not be present');
            System.assertEquals(null, caseRecAfterInsert.contactId, 'Contact Id should not be present');
            
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
    	}
    
    	@isTest
        static void testTenancyMatchNegativeWithTenancyEndDate(){
            YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
            tenancy.TenancyEndDate__c =  tenancy.StartDate__c.addDays(10);
            Update tenancy;
            List<Contact> contactList = UthContact.getAll();
            Case caseRec = UthCase.buildTerminationCaseForGuestPortal('John', 'Doe', 'James', 'Fiorello','123 Test St','London','AB12 3CD');
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
            Test.startTest(); 
                    insert caseRec; 
            Test.stopTest();
            Case caseRecAfterInsert = UthCase.get(caseRec.Id);
            System.assertEquals(caseRecAfterInsert.Tenancy__c, null, 'Tenancy should be present');
            System.assertEquals(caseRecAfterInsert.contactId, null, 'Contact Id should match');
            
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
    	}
    
    	@isTest
        static void testTenancyMatchMultiple(){
            YH_Tenancy__c tenancy1 = UthTenancy.getAll()[0]; 
            Account ac = UthAccount.buildPersonAccount('Jay', 'Dhillon','123 Drive','London','CD123');
            insert ac;            
            YH_Property__c property = UthProperty.buildPropertyWithAssetClass('Leeds',
                    PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
                    PropertyDecorator.RENT_TYPE_MARKET_RENT, PropertyDecorator.PRODUCT_TYPE_MARKETRENTAL,
                	'123 Drive', 'London', 'CD123',PropertyDecorator.FLAT_ASSET_CLASS);
        	insert property;
        	YH_Tenancy__c tenancy2 = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        	insert tenancy2;
            Member__c member = UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('Jay','Dhillon')[0].Id,tenancy2.Id,MemberDecorator.TYPE_SOLO);
        	insert member;
            List<Case> caseList = new List<Case>{
                UthCase.buildTerminationCaseForGuestPortal('Jay', 'Dhillon', null, null,'123 Drive','London','CD123'),
                UthCase.buildTerminationCaseForGuestPortal('Jay', null, null, null,'123 Drive','London','CD123'),
                UthCase.buildTerminationCaseForGuestPortal('John', 'Doe', 'James', 'Fiorello','123 Test St','London','AB12 3CD')
        	};
            
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
            Test.startTest(); 
                    insert caseList; 
            Test.stopTest();
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_TerminationAmmend_BI_CheckPermission.class.getName());
            
            Case caseRecAfterInsert = UthCase.get(caseList[0].Id);
            Case caseRecAfterInsert2 = UthCase.get(caseList[1].Id);
            Case caseRecAfterInsert3 = UthCase.get(caseList[2].Id);
            Id contactId1 = UthContact.getContactByName('Jay','Dhillon')[0].Id;
            Id contactId3 = UthContact.getContactByName('John','Doe')[0].Id;
            
            System.assertEquals(caseRecAfterInsert.Tenancy__c,tenancy2.Id,'Tenancy should be present');
            System.assertEquals(caseRecAfterInsert.contactId,contactId1, 'Contact Id should match');
            System.assert(caseRecAfterInsert2.Tenancy__c == null, 'Tenancy should not be present');
            System.assert(caseRecAfterInsert2.contactId == null, 'Contact Id should not match');
            System.assertEquals(caseRecAfterInsert3.Tenancy__c,tenancy1.Id, 'Tenancy should be present');
            System.assertEquals(caseRecAfterInsert3.contactId,contactId3, 'Contact Id should be present');
    	}


        @isTest
        static void testASBMatchDuplicate_withAllRequiredFields(){
            YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
            List<Contact> contactList = UthContact.getAll();
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_EnforcementAction_BI_CheckPermission.class.getName());
            Test.startTest(); 
                Case caseRec = UthCase.buildBreachASBCaseForGuestPortal('John', 'Doe', '123 Test St','London','AB12 3CD');
                insert caseRec;
            Test.stopTest();
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_EnforcementAction_BI_CheckPermission.class.getName());
            Contact con = UthContact.getContactByName('John','Doe')[0];
            Member__c member = UthMember.getMembersByContactId(con.Id)[0];
            Case caseRecAfterInsert = UthCase.get(caseRec.Id);
            System.assertEquals(caseRecAfterInsert.Tenancy__c,tenancy.Id, 'Tenancy should be present');
            System.assertEquals(Id.valueOf(caseRecAfterInsert.MatchedContact__c),con.Id, 'Contact Id should be present');
            System.assertEquals(caseRecAfterInsert.contactId,con.Id, 'Contact Id should not be blank');
    	}

        @isTest
        static void testASBMatchDuplicate_withoutAddressFields(){
            YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
            List<Contact> contactList = UthContact.getAll();
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_EnforcementAction_BI_CheckPermission.class.getName());
            Test.startTest(); 
                   	Case caseRec = UthCase.buildBreachASBCaseForGuestPortal('John', 'Doe', null,null,null);
                    insert caseRec;
            Test.stopTest();
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_EnforcementAction_BI_CheckPermission.class.getName());
            Contact con = UthContact.getContactByName('John','Doe')[0];
            Member__c member = UthMember.getMembersByContactId(con.Id)[0];
            Case caseRecAfterInsert = UthCase.get(caseRec.Id);
            System.assertEquals(caseRecAfterInsert.Tenancy__c,null, 'Tenancy should not be present');
            System.assertEquals(caseRecAfterInsert.contactId, null, 'Contact Id shouldnot match');
    	}

        @isTest
        static void testASBMatchDuplicate_OnlyFirstNameAvailable(){
            YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
            List<Contact> contactList = UthContact.getAll();
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_EnforcementAction_BI_CheckPermission.class.getName());
            Test.startTest(); 
                   	Case caseRec = UthCase.buildBreachASBCaseForGuestPortal('John', null, null, null, null);
                    insert caseRec;
            Test.stopTest();
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_EnforcementAction_BI_CheckPermission.class.getName());
            Contact con = UthContact.getContactByName('John','Doe')[0];
            Member__c member = UthMember.getMembersByContactId(con.Id)[0];
            Case caseRecAfterInsert = UthCase.get(caseRec.Id);
            System.assertEquals(caseRecAfterInsert.Tenancy__c,null, 'Tenancy should not be present');
            System.assertEquals(caseRecAfterInsert.contactId, null, 'Contact Id shouldnot match');
    	}

        @isTest
        static void negativeTestASBMatchDuplicate_NoFieldsAvailable(){
            YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
            List<Contact> contactList = UthContact.getAll();
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_EnforcementAction_BI_CheckPermission.class.getName());
            Test.startTest(); 
                   	Case caseRec = UthCase.buildBreachASBCaseForGuestPortal(null, null, null, null, null);
                    insert caseRec;
            Test.stopTest();
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_EnforcementAction_BI_CheckPermission.class.getName());
            Contact con = UthContact.getContactByName('John','Doe')[0];
            Member__c member = UthMember.getMembersByContactId(con.Id)[0];
            Case caseRecAfterInsert = UthCase.get(caseRec.Id);
            System.assertEquals(caseRecAfterInsert.Tenancy__c,null, 'Tenancy should not be present');
            System.assertEquals(caseRecAfterInsert.contactId, null, 'Contact Id shouldnot match');
    	}
    
    	@isTest
        static void testASBMatchCustomerPortal(){
            YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
            Contact reporter = UthContact.getContactByName('James','Fiorello')[0];
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_EnforcementAction_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.Bypass(TA_Case_AI_AutoCaseRoleSetup.class.getName());
            Test.startTest(); 
                Case caseRec = UthCase.buildBreachASBCaseForCustomerPortal('John', 'Doe', '123 Test St','London','AB12 3CD',reporter.Id);
                insert caseRec;
            Test.stopTest();
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_EnforcementAction_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.ClearBypass(TA_Case_AI_AutoCaseRoleSetup.class.getName());
            Contact con = UthContact.getContactByName('John','Doe')[0];
            Member__c member = UthMember.getMembersByContactId(con.Id)[0];
            Case caseRecAfterInsert = UthCase.get(caseRec.Id);
            System.assertEquals(Id.valueOf(caseRecAfterInsert.MatchedContact__c),con.Id, 'Contact Id should be present');
            System.assertEquals(caseRecAfterInsert.contactId,null, 'Contact Id should be blank');
            System.assertEquals(caseRecAfterInsert.accountId,null, 'account Id should be blank');
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            Assert.areEqual(0, resultCaseRoles.size(), 'No case role should be created');
            
            caseRec.contactId = caseRecAfterInsert.MatchedContact__c;
			TA_Case_AI_AutoCaseRoleSetup.updateFromReporterFlow = true;
            MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_EnforcementAction_BU_CheckPermission.class.getName());
            update caseRec;
            MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_EnforcementAction_BU_CheckPermission.class.getName());
            CaseRole__c accusedPartyCaseRole;
            CaseRole__c reporterCaseRole;
            List<CaseRole__c> resultCaseRolesAfterUpdate = UthCaseRole.getAll();
            for(CaseRole__c caseRole : resultCaseRolesAfterUpdate){
                if(caseRole.Role__c == CaseRoleDecorator.ACCUSED_PARTY_ROLE){
                    accusedPartyCaseRole = caseRole;
                } else if(caseRole.Role__c == CaseRoleDecorator.REPORTER_ROLE){
                    reporterCaseRole = caseRole;
                }
            }
            
            Assert.areEqual(2, resultCaseRolesAfterUpdate.size(), 'Two case role should be created');
            Assert.areEqual(caseRecAfterInsert.MatchedContact__c, accusedPartyCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.areEqual(reporter.Id, reporterCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
    	}
    	
        @isTest
        static void testComplaintMatchCustomerPortal(){
            YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
            Contact reporter = UthContact.getContactByName('John','Doe')[0];
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.Bypass(TA_Case_AI_AutoCaseRoleSetup.class.getName());
            Test.startTest(); 
                Case caseRec = UthCase.buildComplaintsForGuestPortal('John', 'Doe', '123 Test St','London','AB12 3CD');
                insert caseRec;
            Test.stopTest();
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            Contact con = UthContact.getContactByName('John','Doe')[0];
            Member__c member = UthMember.getMembersByContactId(con.Id)[0];
            Case caseRecAfterInsert = UthCase.get(caseRec.Id);
            Assert.areEqual(Id.valueOf(caseRecAfterInsert.MatchedContact__c),con.Id, 'Contact Id should be present');
            Assert.areEqual(caseRecAfterInsert.contactId,con.Id, 'Contact Id should not be blank');
            Assert.areEqual(caseRecAfterInsert.accountId,con.AccountId, 'account Id should not be blank');
            Assert.areEqual(caseRecAfterInsert.Reporter__c, caseRecAfterInsert.contactId, 'Reporter and Contact should be same');
            Assert.areEqual(caseRecAfterInsert.Tenancy__c, tenancy.Id, 'Tenancy Id should be present');
    	}

         @isTest
        static void negativeTestComplaintchDuplicate_NoFieldsAvailable(){
            YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
            List<Contact> contactList = UthContact.getAll();
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            Test.startTest(); 
                   	Case caseRec = UthCase.buildComplaintsForGuestPortal(null, null, null, null, null);
                    insert caseRec;
            Test.stopTest();
            MetadataTriggerHandler.clearbypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            Contact con = UthContact.getContactByName('John','Doe')[0];
            Member__c member = UthMember.getMembersByContactId(con.Id)[0];
            Case caseRecAfterInsert = UthCase.get(caseRec.Id);
            System.assertEquals(caseRecAfterInsert.Tenancy__c,null, 'Tenancy should not be present');
            System.assertEquals(caseRecAfterInsert.contactId, null, 'Contact Id shouldnot match');
    	}

        @isTest
        static void testComplaintsMatchDuplicate_OnlyFirstNameAvailable(){
            YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
            List<Contact> contactList = UthContact.getAll();
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            Test.startTest(); 
                   	Case caseRec = UthCase.buildComplaintsForGuestPortal('John', null, null, null, null);
                    insert caseRec;
            Test.stopTest();
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            Contact con = UthContact.getContactByName('John','Doe')[0];
            Member__c member = UthMember.getMembersByContactId(con.Id)[0];
            Case caseRecAfterInsert = UthCase.get(caseRec.Id);
            Assert.areEqual(caseRecAfterInsert.Tenancy__c,null, 'Tenancy should not be present');
            Assert.areEqual(caseRecAfterInsert.contactId, null, 'Contact Id shouldnot match');
    	}

         @isTest
        static void testComplaintsMatchDuplicate_OnlyContactNoTenancy(){
            TriggerBase.bypass('Account');
            TriggerBase.bypass('YH_Tenancy__c');
        	insert new List<Account>{
                UthAccount.buildPersonAccount('Tina', 'Doe','123 Test St','London','AB123CD')
            };
        	YH_Tenancy__c tenancy = UthTenancy.build(UthProperty.getall()[0].Id, false, TenancyDecorator.TENANCY_TYPE_JOINT);
        	insert tenancy;
            List<Member__c> memberList = new List<Member__c>{
                UthMember.buildWithNullOccupancyEndDate(UthContact.getContactByName('Tina','Doe')[0].Id,tenancy.Id,MemberDecorator.TYPE_JOINT)	};
        	insert memberList;
            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('YH_Tenancy__c');
            List<Contact> contactList = UthContact.getAll();
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            Test.startTest(); 
                Case caseRec = UthCase.buildComplaintsForGuestPortal('Tina', 'Doe', '123 Test St','London','AB12 3CD');
                insert caseRec;
            Test.stopTest();
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            Contact con = UthContact.getContactByName('Tina','Doe')[0];
            Member__c member = UthMember.getMembersByContactId(con.Id)[0];
            Case caseRecAfterInsert = UthCase.get(caseRec.Id);
            Assert.areEqual(caseRecAfterInsert.Tenancy__c,null, 'Tenancy should not be present');
            Assert.areEqual(caseRecAfterInsert.contactId, null, 'Contact Id should not be present');
            Assert.areEqual(caseRecAfterInsert.Reporter__c, caseRecAfterInsert.contactId, 'Reporter and Contact should be same');
          
    	}
    	
    
}