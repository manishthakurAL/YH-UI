@isTest(seeAllData=false)
public with sharing class CaseRoleSetupServiceTest {
     
    @testSetup
        static void setUpTestData(){
            UthFeatureSwitches.enableAllRT();

        	TriggerBase.bypass('Account');
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
                PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS,
                PropertyDecorator.AUTHCODE_E08000038,
                PropertyDecorator.RENT_TYPE_SOCIAL_RENT,
                PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL
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
    	}

        @isTest
        static void test_SafeguardingGenericCase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;
            Case caseRecord;
            
            System.runAs(new User(Id = UserInfo.getUserId())){
                Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_SAFEGUARDING_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
                Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_PS_CAN_UPDATE_SAFEGUARDING_CASE).Id;
                PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
                if (permissionSetAssignment == null) {
                    UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
                }

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

                caseRecord = UthCase.buildSafeguardingCaseWithTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id);
                
                Test.startTest();
                System.runAs(new User(Id = currentUserId)) {

                    try {
                        insert caseRecord;
                    } 
                    catch(Exception exp) {
                        actualErrorMessage = exp.getMessage();
                    }
                } 
                Test.stopTest();

                TriggerBase.bypass('Case');
                UthCase.createCaseShareRecords(caseRecord.Id, currentUserId, 'Edit','Manual');
                TriggerBase.clearBypass('Case');
            }

            CaseRole__c personAtRiskCaseRole;
            CaseRole__c reporterCaseRole;
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            for(CaseRole__c caseRole : resultCaseRoles){
                if(caseRole.Role__c == CaseRoleDecorator.PERSONATRISK_ROLE){
                    personAtRiskCaseRole = caseRole;
                } else if(caseRole.Role__c == CaseRoleDecorator.REPORTER_ROLE){
                    reporterCaseRole = caseRole;
                }
            }
            
            Assert.areEqual(2, resultCaseRoles.size(), 'Two case role should be created');
            Assert.areEqual(contactOne.Id, personAtRiskCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.areEqual(contactTwo.Id, reporterCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.isNull(actualErrorMessage, 'Owner assignment correct');
        }
        
        @isTest
        static void testChangeJointToSoleCase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;
            Case caseRecord;
            
            System.runAs(UthUser.setChangeUser(UserInfo.getUserId())) {
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
                
                caseRecord = UthCase.buildJointToSoleCaseWithTenancyandReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id);
                
                Test.startTest();
                    try {
                        insert caseRecord;
                    } 
                    catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                    }
        	    Test.stopTest();
            }

            List<CaseRole__c> tenantCaseRole = new List<CaseRole__c>();
            CaseRole__c reporterCaseRole;
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            for(CaseRole__c caseRole : resultCaseRoles){
                if(caseRole.Role__c == CaseRoleDecorator.TENANT_ROLE){
                    tenantCaseRole.add(caseRole);
                } else if(caseRole.Role__c == CaseRoleDecorator.REPORTER_ROLE){
                    reporterCaseRole = caseRole;
                }
            }
            
            Assert.areEqual(3, resultCaseRoles.size(), 'Two case role should be created');
            Assert.areEqual(2, tenantCaseRole.size(), 'Two tenants should be linked');
            Assert.areEqual(contactTwo.Id, reporterCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.isNull(actualErrorMessage, 'Exception should be null');
    	}

        @isTest
        static void testChangeDeathOfaTenantase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;
            Case caseRecord;
            
            System.runAs(UthUser.setChangeUser(UserInfo.getUserId())) {
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
                
                caseRecord = UthCase.buildDeathOfTenantSurvivorWithTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id);
                
                Test.startTest();
                    try {
                        insert caseRecord;
                    } 
                    catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                    }
        	    Test.stopTest();
            }

            CaseRole__c customDeceasedCaseRole;
            CaseRole__c reporterCaseRole;
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            for(CaseRole__c caseRole : resultCaseRoles){
                if(caseRole.Role__c == CaseRoleDecorator.CUSTOMER_DECEASED_ROLE){
                    customDeceasedCaseRole = caseRole;
                } else if(caseRole.Role__c == CaseRoleDecorator.REPORTER_ROLE){
                    reporterCaseRole = caseRole;
                }
            }
            
            Assert.areEqual(2, resultCaseRoles.size(), 'Two case role should be created');
            Assert.areEqual(contactOne.Id, customDeceasedCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.areEqual(contactTwo.Id, reporterCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.isNull(actualErrorMessage, 'Exception should be null');
    	}

        @isTest
        static void testTenancyGenericCase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;
            Case caseRecord;
            
            System.runAs(UthUser.setTenancyUser(UserInfo.getUserId())) {
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
                
                caseRecord = UthCase.buildTenancyCaseWithTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id);
                
                Test.startTest();
                    try {
                        insert caseRecord;
                    } 
                    catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                    }
        	    Test.stopTest();
            }

            CaseRole__c tenantCaseRole;
            CaseRole__c reporterCaseRole;
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            for(CaseRole__c caseRole : resultCaseRoles){
                if(caseRole.Role__c == CaseRoleDecorator.TENANT_ROLE){
                    tenantCaseRole = caseRole;
                } else if(caseRole.Role__c == CaseRoleDecorator.REPORTER_ROLE){
                    reporterCaseRole = caseRole;
                }
            }
            
            Assert.areEqual(2, resultCaseRoles.size(), 'Two case role should be created');
            Assert.areEqual(contactOne.Id, tenantCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.areEqual(contactTwo.Id, reporterCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.isNull(actualErrorMessage, 'Exception should be null');
    	}

        @isTest
        static void testPlaceGenericCase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;
            Case caseRecord;
            
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_CREATE_AT_NEW).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }

            Id permissionSetIdUpdate = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_UPDATE).Id;
            PermissionSetAssignment permissionSetAssignmentNwNew = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetIdUpdate);
            if (permissionSetAssignmentNwNew == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetIdUpdate);
            }

            System.runAs(new User(Id = currentUserId)) {
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
                
                caseRecord = UthCase.buildPlaceWithCaseTypeTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_LAND_DISPUTES);
                
                Test.startTest();
                    try {
                        insert caseRecord;
                    } 
                    catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                    }
        	    Test.stopTest();
            }

            List<CaseRole__c> tenantCaseRole = new List<CaseRole__c>();
            CaseRole__c reporterCaseRole;
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            for(CaseRole__c caseRole : resultCaseRoles){
                if(caseRole.Role__c == CaseRoleDecorator.TENANT_ROLE){
                    tenantCaseRole.add(caseRole);
                } else if(caseRole.Role__c == CaseRoleDecorator.REPORTER_ROLE){
                    reporterCaseRole = caseRole;
                }
            }
            
            Assert.areEqual(3, resultCaseRoles.size(), 'Two case role should be created');
            Assert.areEqual(2, tenantCaseRole.size(), 'Two tenants should be linked');
            Assert.areEqual(contactTwo.Id, reporterCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.isNull(actualErrorMessage, 'Exception should be null');
    	}

        @isTest
        static void testPlaceAbandonedVehiclesCase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;
            Case caseRecord;
            
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_CREATE_AT_NEW).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }

            Id permissionSetIdUpdate = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_UPDATE).Id;
            PermissionSetAssignment permissionSetAssignmentNwNew = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetIdUpdate);
            if (permissionSetAssignmentNwNew == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetIdUpdate);
            }

            System.runAs(new User(Id = currentUserId)) {
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
                
                caseRecord = UthCase.buildPlaceWithCaseTypeTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_ABANDONED_VEHICLES);
                
                Test.startTest();
                    try {
                        insert caseRecord;
                    } 
                    catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                    }
        	    Test.stopTest();
            }

            CaseRole__c tenantCaseRole;
            CaseRole__c reporterCaseRole;
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            for(CaseRole__c caseRole : resultCaseRoles){
                if(caseRole.Role__c == CaseRoleDecorator.TENANT_ROLE){
                    tenantCaseRole = caseRole;
                } else if(caseRole.Role__c == CaseRoleDecorator.REPORTER_ROLE){
                    reporterCaseRole = caseRole;
                }
            }
            
            Assert.areEqual(1, resultCaseRoles.size(), 'Two case role should be created');
            Assert.areEqual(contactTwo.Id, reporterCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.isNull(actualErrorMessage, 'Exception should be null');
    	}

        @isTest
        static void testPlaceAbandonedVehiclesNoCaseContact(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;
            Case caseRecord;
            
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_CREATE_AT_NEW).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }

            Id permissionSetIdUpdate = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_PLACE_CASE_UPDATE).Id;
            PermissionSetAssignment permissionSetAssignmentNwNew = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetIdUpdate);
            if (permissionSetAssignmentNwNew == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetIdUpdate);
            }

            System.runAs(new User(Id = currentUserId)) {
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
                
                caseRecord = UthCase.buildPlaceWithCaseTypeTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_ABANDONED_VEHICLES);
                caseRecord.ContactId = null;
                
                Test.startTest();
                    try {
                        insert caseRecord;
                    } 
                    catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                    }
        	    Test.stopTest();
            }

            CaseRole__c tenantCaseRole;
            CaseRole__c reporterCaseRole;
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            for(CaseRole__c caseRole : resultCaseRoles){
                if(caseRole.Role__c == CaseRoleDecorator.TENANT_ROLE){
                    tenantCaseRole = caseRole;
                } else if(caseRole.Role__c == CaseRoleDecorator.REPORTER_ROLE){
                    reporterCaseRole = caseRole;
                }
            }
            
            Assert.areEqual(1, resultCaseRoles.size(), 'Two case role should be created');
            Assert.areEqual(contactTwo.Id, reporterCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.isNull(actualErrorMessage, 'Exception should be null');
    	}

        @isTest
        static void testBreachASBGenericCase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;
            Case caseRecord;
            
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_CREATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_SAFEGUARDING_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }

            System.runAs(new User(Id = currentUserId)) {
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
                
                caseRecord = UthCase.buildBreachAndASBCaseWithTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id);
                
                Test.startTest();
                    try {
                        insert caseRecord;
                    } 
                    catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                    }
        	    Test.stopTest();
            }

            CaseRole__c accusedPartyCaseRole;
            CaseRole__c reporterCaseRole;
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            for(CaseRole__c caseRole : resultCaseRoles){
                if(caseRole.Role__c == CaseRoleDecorator.ACCUSED_PARTY_ROLE){
                    accusedPartyCaseRole = caseRole;
                } else if(caseRole.Role__c == CaseRoleDecorator.REPORTER_ROLE){
                    reporterCaseRole = caseRole;
                }
            }
            
            Assert.areEqual(2, resultCaseRoles.size(), 'Two case role should be created');
            Assert.areEqual(contactOne.Id, accusedPartyCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.areEqual(contactTwo.Id, reporterCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.isNull(actualErrorMessage, 'Exception should be null');
    	}

        @isTest
        static void testBreachASBGenericCaseWithoutAccusedParty(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;
            Case caseRecord;
            
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_BREACH_CASE_CREATE_AT_NEW).Id;
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_SAFEGUARDING_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }

            System.runAs(new User(Id = currentUserId)) {
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
                
                caseRecord = UthCase.buildBreachAndASBCaseWithoutAccusedParty(tenancyJoint.Id, contactTwo.Id);
                
                Test.startTest();
                    try {
                        insert caseRecord;
                    } 
                    catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                    }
        	    Test.stopTest();
            }

            CaseRole__c accusedPartyCaseRole;
            CaseRole__c reporterCaseRole;
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            for(CaseRole__c caseRole : resultCaseRoles){
                if(caseRole.Role__c == CaseRoleDecorator.ACCUSED_PARTY_ROLE){
                    accusedPartyCaseRole = caseRole;
                } else if(caseRole.Role__c == CaseRoleDecorator.REPORTER_ROLE){
                    reporterCaseRole = caseRole;
                }
            }
            
            Assert.areEqual(1, resultCaseRoles.size(), 'One case role should be created');
            Assert.areEqual(null, accusedPartyCaseRole, 'Accused party case role should not exst');
            Assert.areEqual(contactTwo.Id, reporterCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.isNull(actualErrorMessage, 'Exception should be null');
    	}

        @isTest
        static void testCustomerGenericCase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;
            Case caseRecord;
            
            System.runAs(UthUser.setCustomerUser(UserInfo.getUserId())) {
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
                
                caseRecord = UthCase.buildCustomerCaseWithTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id);
                
                Test.startTest();
                    try {
                        insert caseRecord;
                    } 
                    catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                    }
        	    Test.stopTest();
            }

            CaseRole__c tenantCaseRole;
            CaseRole__c reporterCaseRole;
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            for(CaseRole__c caseRole : resultCaseRoles){
                if(caseRole.Role__c == CaseRoleDecorator.TENANT_ROLE){
                    tenantCaseRole = caseRole;
                } else if(caseRole.Role__c == CaseRoleDecorator.REPORTER_ROLE){
                    reporterCaseRole = caseRole;
                }
            }
            
            Assert.areEqual(2, resultCaseRoles.size(), 'Two case role should be created');
            Assert.areEqual(contactOne.Id, tenantCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.areEqual(contactTwo.Id, reporterCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.isNull(actualErrorMessage, 'Exception should be null');
    	}

        @isTest
        static void testManagedMoveGenericCase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;
            Case caseRecord;
            
            System.runAs(UthUser.getSchemeUserForManagedMove(UserInfo.getUserId())) {
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
                
                caseRecord = UthCase.buildManagedMoveCaseWithTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id);
                
                Test.startTest();
                    try {
                        insert caseRecord;
                    } 
                    catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                    }
        	    Test.stopTest();
            }

            CaseRole__c tenantRequiringMoveCaseRole;
            CaseRole__c reporterCaseRole;
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            for(CaseRole__c caseRole : resultCaseRoles){
                if(caseRole.Role__c == CaseRoleDecorator.TENANT_REQUIRING_MOVE_ROLE){
                    tenantRequiringMoveCaseRole = caseRole;
                } else if(caseRole.Role__c == CaseRoleDecorator.REPORTER_ROLE){
                    reporterCaseRole = caseRole;
                }
            }
            
            Assert.areEqual(2, resultCaseRoles.size(), 'Two case role should be created');
            Assert.areEqual(contactOne.Id, tenantRequiringMoveCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.areEqual(contactTwo.Id, reporterCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.isNull(actualErrorMessage, 'Exception should be null');
    	}

        @isTest
        static void testFeatureEnabledCase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;
            Case caseRecord;
            
            System.runAs(UthUser.setCustomerUser(UserInfo.getUserId())) {
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
                
                caseRecord = UthCase.buildManagedMoveCaseWithTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id);
                caseRecord.CaseFeatureSwitches__c = null;
                
                Test.startTest();
                    try {
                        insert caseRecord;
                    } 
                    catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                    }
        	    Test.stopTest();
            }

            CaseRole__c tenantRequiringMoveCaseRole;
            CaseRole__c reporterCaseRole;
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            for(CaseRole__c caseRole : resultCaseRoles){
                if(caseRole.Role__c == CaseRoleDecorator.TENANT_REQUIRING_MOVE_ROLE){
                    tenantRequiringMoveCaseRole = caseRole;
                } else if(caseRole.Role__c == CaseRoleDecorator.REPORTER_ROLE){
                    reporterCaseRole = caseRole;
                }
            }
            
            Assert.areEqual(0, resultCaseRoles.size(), 'No case role should be created');
    	}
    	@isTest
        static void testTerminationCustomerPortalCase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;
            Case caseRecord;
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        	MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
        	MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
            System.runAs(new User(Id = UserInfo.getUserId())) {
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
                caseRecord = UthCase.buildTerminationCustomerPortalCase(contactOne.Id, tenancyJoint.Id, contactTwo.Id);
                Test.startTest();
                    try {
                        insert caseRecord;
                        MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            			MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
           			    MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());

                    } 
                    catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                    }
        	    Test.stopTest();
            }
            CaseRole__c TenantCaseRole;
            CaseRole__c reporterCaseRole;
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            for(CaseRole__c caseRole : resultCaseRoles){
                if(caseRole.Role__c == CaseRoleDecorator.TENANT_ROLE){
                    TenantCaseRole = caseRole;
                } else if(caseRole.Role__c == CaseRoleDecorator.REPORTER_ROLE){
                    reporterCaseRole = caseRole;
                }
            }
            
            Assert.areEqual(2, resultCaseRoles.size(), 'Two case role should be created');
            Assert.areEqual(contactOne.Id, TenantCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.areEqual(contactTwo.Id, reporterCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.isNull(actualErrorMessage, 'Exception should be null');
    	}
    	@isTest
        static void testTerminationGuestPortalCase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;
            Case caseRecord;
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        	MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
        	MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
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
           caseRecord = UthCase.buildTerminationGuestPortalCase();
           caseRecord.ContactId = contactOne.Id;
           insert caseRecord;
           MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
           MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
           MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
           caseRecord.Reporter__c = contactTwo.Id;
           Test.startTest();
                    try{
                        TA_Case_AI_AutoCaseRoleSetup.updateFromReporterFlow = true;
                        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
                        update caseRecord;
                        MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
                    } 
                    catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                    }
        	Test.stopTest();
            CaseRole__c reporterCaseRole;
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            for(CaseRole__c caseRole : resultCaseRoles){
                if(caseRole.Role__c == CaseRoleDecorator.REPORTER_ROLE){
                    reporterCaseRole = caseRole;
                }
            }
            Assert.areEqual(contactTwo.Id, reporterCaseRole.Contact__c, 'Reporter Role should be there after update');
            Assert.isNull(actualErrorMessage, 'Exception should be null');
    	}
    	@isTest
        static void testComplimentGuestPortalCase(){
            String actualErrorMessage;
            Contact contactOne;
            Case caseRecord;
     
            for(Contact contact : UthContact.getAll()){
                    if(contact.LastName == 'lNameOne'){
                        contactOne = contact;
                    }
            }
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            caseRecord = UthCase.buildCustomerFeedbackCaseGuestPortal();
            insert caseRecord;
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
           	caseRecord.ContactId = contactOne.Id;
            caseRecord.Reporter__c = contactOne.Id;
            Test.startTest();
                    try{
                            TA_Case_AI_AutoCaseRoleSetup.updateFromReporterFlow = true;
                            MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
                            update caseRecord;
                            MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());                    
                    } 
                    catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                    }
        	Test.stopTest();
            CaseRole__c reporterCaseRole;
            CaseRole__c feedbackProviderCaseRole;
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            for(CaseRole__c caseRole : resultCaseRoles){
                if(caseRole.Role__c == CaseRoleDecorator.FEEDBACK_PROVIDER_ROLE){
                    feedbackProviderCaseRole = caseRole;
                } else if(caseRole.Role__c == CaseRoleDecorator.REPORTER_ROLE){
                    reporterCaseRole = caseRole;
                }
            }
             Assert.areEqual(2, resultCaseRoles.size(), 'Two case role should be created');
            Assert.areEqual(contactOne.Id, feedbackProviderCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.areEqual(contactOne.Id, reporterCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.isNull(actualErrorMessage, 'Exception should be null');
    	}
    	@isTest
        static void testCaseRolesWhenReporterIsNotChangedFromPortal(){
            String actualErrorMessage;
            Contact contactOne;
            Case caseRecord;
     
            for(Contact contact : UthContact.getAll()){
                    if(contact.LastName == 'lNameOne'){
                        contactOne = contact;
                    }
            }
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            caseRecord = UthCase.buildCustomerFeedbackCaseGuestPortal();
            insert caseRecord;
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
           	caseRecord.ContactId = contactOne.Id;
            caseRecord.Reporter__c = contactOne.Id;
            Test.startTest();
                    try {
                        update caseRecord;
                    } 
                    catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                    }
        	Test.stopTest();
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            Assert.areEqual(0, resultCaseRoles.size(), 'No case role should be created');
    	}
    
    	@isTest
        static void testBreachASBCustomerPortalCase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;
            Case caseRecord;
            
            MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
			MetadataTriggerHandler.bypass(TA_Case_AI_AutoCaseRoleSetup.class.getName());
            MetadataTriggerHandler.bypass(TA_EnforcementAction_BI_CheckPermission.class.getName());
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
                
                caseRecord = UthCase.buildBreachAndASBCaseWithTenancyAndReporter(contactTwo.Id, tenancyJoint.Id, contactTwo.Id);
                caseRecord.Origin = CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL;
                Test.startTest();
                    try {
                        insert caseRecord;
                        MetadataTriggerHandler.ClearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
                        MetadataTriggerHandler.ClearBypass(TA_Case_AI_AutoCaseRoleSetup.class.getName());
                        MetadataTriggerHandler.ClearBypass(TA_EnforcementAction_BI_CheckPermission.class.getName());
                        caseRecord.contactId = contactOne.Id;
                        TA_Case_AI_AutoCaseRoleSetup.updateFromReporterFlow = true;
                        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
                        MetadataTriggerHandler.bypass(TA_EnforcementAction_BU_CheckPermission.class.getName());
                        update caseRecord;
                        MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
                        MetadataTriggerHandler.clearBypass(TA_EnforcementAction_BU_CheckPermission.class.getName());

                    } 
                    catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                    }
        	    Test.stopTest();

            CaseRole__c accusedPartyCaseRole;
            CaseRole__c reporterCaseRole;
            List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
            for(CaseRole__c caseRole : resultCaseRoles){
                if(caseRole.Role__c == CaseRoleDecorator.ACCUSED_PARTY_ROLE){
                    accusedPartyCaseRole = caseRole;
                } else if(caseRole.Role__c == CaseRoleDecorator.REPORTER_ROLE){
                    reporterCaseRole = caseRole;
                }
            }
            
            Assert.areEqual(2, resultCaseRoles.size(), 'Two case role should be created');
            Assert.areEqual(contactOne.Id, accusedPartyCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.areEqual(contactTwo.Id, reporterCaseRole.Contact__c, 'Wrong Contact and Case role contact is linked');
            Assert.isNull(actualErrorMessage, 'Exception should be null');
    	}
    	
}