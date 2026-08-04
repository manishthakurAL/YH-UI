@isTest(seeAllData=false)
public with sharing class MemberServiceTest {
    @testSetup
        static void setUpTestData(){
            UthFeatureSwitches.enableCaseChangesRT();
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
    	}

        @isTest
        static void testSoleToJointCase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;

            System.runAs(UthUser.setChangeUser(UserInfo.getUserId())) {
                for(Contact contact : UthContact.getAll()){
                    if(contact.LastName == 'lNameOne'){
                        contactOne = contact;
                    } else if(contact.LastName == 'lNameTwo'){
                        contactTwo = contact;
                    } 
                }

                for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                    if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_SOLO){
                        tenancyJoint = tenancy;
                    }
                }
                
                Case caseRec = UthCase.buildSoleToJointCase(contactOne.Id);
                caseRec.Tenancy__c = tenancyJoint.Id;
                insert caseRec;

                List<CaseRole__c> caseRoleList = new List<CaseRole__c>();
                caseRoleList.add(UthCaseRole.build(caseRec.Id, contactOne.Id, CaseRoleDecorator.TENANT_ROLE));
                caseRoleList.add(UthCaseRole.build(caseRec.Id, contactTwo.Id, CaseRoleDecorator.APPLICANT_ROLE));
                insert caseRoleList;

                TenancyChange__c tcRec = UthTenancyChange.updateRequiredDetailsForTenancyChangeForSoleToJoint(caseRec.Id);
                Test.startTest();
                try {
                        caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_APPROVED;
                        caseRec.status = CaseDecorator.STATUS_STAGE_CLOSED;
                        caseRec.ClosureReason__c = 'Test reason';
                        update caseRec;
                 } 
                 catch(Exception exp) {
                        actualErrorMessage = exp.getMessage();
                 }
        	Test.stopTest();
            }

            List<Member__c> resultMembers = UthMember.getAll();
            Member__c resultMember;
            for(Member__c member : resultMembers){
                if(member.Contact__c == contactTwo.Id){
                    resultMember = member;
                }
            }
            
            Assert.areNotEqual(null, resultMember, 'New Joint Member must be added to tenancy');
    	}

        @isTest
        static void testJointToSoleCase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;

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
                
                Case caseRec = UthCase.buildJointToSoleCase(contactOne.Id);
                caseRec.Tenancy__c = tenancyJoint.Id;
                insert caseRec;

                List<CaseRole__c> caseRoleList = new List<CaseRole__c>();
                caseRoleList.add(UthCaseRole.build(caseRec.Id, contactOne.Id, CaseRoleDecorator.OUTGOING_CUSTOMER_ROLE));
                insert caseRoleList;

                TenancyChange__c tcRec = UthTenancyChange.updateRequiredDetailsForTenancyChangeForJointToSole(caseRec.Id);
                Test.startTest();
                try {
                        caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_APPROVED;
                        caseRec.status = CaseDecorator.STATUS_STAGE_CLOSED;
                        caseRec.ClosureReason__c = 'Test reason';
                        update caseRec;
                 } 
                 catch(Exception exp) {
                        actualErrorMessage = exp.getMessage();
                 }
        	Test.stopTest();
            }

            List<Member__c> resultMembers = UthMember.getAll();
            Member__c resultMember;
            for(Member__c member : resultMembers){
                if(member.Contact__c == contactOne.Id && member.Tenancy__c == tenancyJoint.Id){
                    resultMember = member;
                }
            }
            
            Assert.areEqual(Date.today(), resultMember.OccupancyEndDate__c, 'Member OccupancyEndDate__c is not populated');
            Assert.areEqual(null,actualErrorMessage, 'Exception message should not be there');
    	}

        @isTest
        static void testSoleToJointCaseValidationNoApplicantCustomerCaseRole(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;

            System.runAs(UthUser.setChangeUser(UserInfo.getUserId())) {
                for(Contact contact : UthContact.getAll()){
                    if(contact.LastName == 'lNameOne'){
                        contactOne = contact;
                    } 
                }

                for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                    if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_SOLO){
                        tenancyJoint = tenancy;
                    }
                }
                
                Case caseRec = UthCase.buildSoleToJointCase(contactOne.Id);
                caseRec.Tenancy__c = tenancyJoint.Id;
                insert caseRec;

                List<CaseRole__c> caseRoleList = new List<CaseRole__c>();
                caseRoleList.add(UthCaseRole.build(caseRec.Id, contactOne.Id, CaseRoleDecorator.TENANT_ROLE));
                insert caseRoleList;

                TenancyChange__c tcRec = UthTenancyChange.updateRequiredDetailsForTenancyChangeForSoleToJoint(caseRec.Id);
                Test.startTest();
                try {
                        caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_APPROVED;
                        caseRec.status = CaseDecorator.STATUS_STAGE_CLOSED;
                        caseRec.ClosureReason__c = 'Test reason';
                        update caseRec;
                 } 
                 catch(Exception exp) {
                        actualErrorMessage = exp.getMessage();
                 }
        	Test.stopTest();
            }
        
            Assert.areNotEqual(Label.CaseRoleApplicantMissingError, actualErrorMessage, 'New Joint Member must be added to tenancy');
    	}

        @isTest
        static void testJointToSoleCaseValidationNoOutgoingCustomerCaseRole(){
            String actualErrorMessage;
            String expectedErrorMessage = Label.CaseRoleOutgoingCustomerError;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;

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
                
                Case caseRec = UthCase.buildJointToSoleCase(contactOne.Id);
                caseRec.Tenancy__c = tenancyJoint.Id;
                insert caseRec;

                TenancyChange__c tcRec = UthTenancyChange.updateRequiredDetailsForTenancyChangeForJointToSole(caseRec.Id);
                Test.startTest();
                try {
                        caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_APPROVED;
                        caseRec.status = CaseDecorator.STATUS_STAGE_CLOSED;
                        caseRec.ClosureReason__c = 'Test reason';
                        update caseRec;
                 } 
                 catch(Exception exp) {
                        actualErrorMessage = exp.getMessage();
                 }
        	Test.stopTest();
            }

            Assert.areEqual(true,(actualErrorMessage.containsIgnoreCase(expectedErrorMessage)), 'Exception message should be there');
    	}

        @isTest
        static void testJointToSoleCaseValidationMoreThanOneOutgoingCustomerCaseRole(){
            String actualErrorMessage;
            String expectedErrorMessage = Label.CaseRoleMoreOutgoingCustomerError;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;

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
                
                Case caseRec = UthCase.buildJointToSoleCase(contactOne.Id);
                caseRec.Tenancy__c = tenancyJoint.Id;
                insert caseRec;

                List<CaseRole__c> caseRoleList = new List<CaseRole__c>();
                caseRoleList.add(UthCaseRole.build(caseRec.Id, contactOne.Id, CaseRoleDecorator.OUTGOING_CUSTOMER_ROLE));
                caseRoleList.add(UthCaseRole.build(caseRec.Id, contactTwo.Id, CaseRoleDecorator.OUTGOING_CUSTOMER_ROLE));
                insert caseRoleList;

                TenancyChange__c tcRec = UthTenancyChange.updateRequiredDetailsForTenancyChangeForJointToSole(caseRec.Id);
                Test.startTest();
                try {
                        caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_APPROVED;
                        caseRec.status = CaseDecorator.STATUS_STAGE_CLOSED;
                        caseRec.ClosureReason__c = 'Test reason';
                        update caseRec;
                 } 
                 catch(Exception exp) {
                        actualErrorMessage = exp.getMessage();
                 }
        	Test.stopTest();
            }

            Assert.areEqual(true,(actualErrorMessage.containsIgnoreCase(expectedErrorMessage)), 'Exception message should be there');
    	}

        @isTest
        static void testDeathOfTenantSurvivorCase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;

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
                
                Case caseRec = UthCase.buildDeathOfTenantSurvivor(contactOne.Id);
                caseRec.Tenancy__c = tenancyJoint.Id;
                caseRec.DateOfDeath__c = Date.today().addDays(-5);
                insert caseRec;

                TenancyChange__c tcRec = UthTenancyChange.updateRequiredDetailsForTenancyChangeForDeathOfaTenantSurvivor(caseRec.Id);
                Test.startTest();
                try {
                        caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_COMPLETED;
                        caseRec.status = CaseDecorator.STATUS_STAGE_CLOSED;
                        caseRec.ClosureReason__c = 'Test reason';
                        update caseRec;
                 } 
                 catch(Exception exp) {
                        actualErrorMessage = exp.getMessage();
                 }
        	Test.stopTest();
            }

            List<Member__c> resultMembers = UthMember.getAll();
            List<Contact> resultContacts = UthContact.getAll();
            Member__c resultMember;
            Contact resultContact;
            for(Member__c member : resultMembers){
                if(member.Contact__c == contactOne.Id && member.Tenancy__c == tenancyJoint.Id){
                    resultMember = member;
                }
            }

            for(Contact contact : resultContacts){
                if(contact.Id == contactOne.Id){
                    resultContact = contact;
                }
            }

            Assert.areEqual(Date.today(), resultMember.OccupancyEndDate__c, 'Member OccupancyEndDate__c is not populatd');
            Assert.areEqual(Date.today().addDays(-5), resultContact.DateOfDeath__c, 'Contact DateOfDeath is not populated');
            Assert.areEqual(null,actualErrorMessage, 'Exception message should not be there');
    	}

        @isTest
        static void testDeathOfTenantSurvivorTenanctAndCustomerDeseasedDifferentCase(){
            String actualErrorMessage;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;

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
                
                Case caseRec = UthCase.buildDeathOfTenantSurvivor(contactOne.Id);
                caseRec.Tenancy__c = tenancyJoint.Id;
                caseRec.DateOfDeath__c = Date.today().addDays(-5);
                insert caseRec;

                TenancyChange__c tcRec = UthTenancyChange.updateRequiredDetailsForTenancyChangeForDeathOfaTenantSurvivor(caseRec.Id);
                Test.startTest();
                try {
                        caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_COMPLETED;
                        caseRec.status = CaseDecorator.STATUS_STAGE_CLOSED;
                        caseRec.ClosureReason__c = 'Test reason';
                        update caseRec;
                 } 
                 catch(Exception exp) {
                        actualErrorMessage = exp.getMessage();
                 }
        	Test.stopTest();
            }

            List<Member__c> resultMembers = UthMember.getAll();
            List<Contact> resultContacts = UthContact.getAll();
            Member__c resultMember;
            Contact resultContact;
            for(Member__c member : resultMembers){
                if(member.Contact__c == contactOne.Id && member.Tenancy__c == tenancyJoint.Id){
                    resultMember = member;
                }
            }

            for(Contact contact : resultContacts){
                if(contact.Id == contactOne.Id){
                    resultContact = contact;
                }
            }

            Assert.areEqual(Date.today(), resultMember.OccupancyEndDate__c, 'Member OccupancyEndDate__c is not populatd');
            Assert.areEqual(Date.today().addDays(-5), resultContact.DateOfDeath__c, 'Contact DateOfDeath is not populated');
            Assert.areEqual(null,actualErrorMessage, 'Exception message should not be there');
    	}

        @isTest
        static void testDeathOfTenantSurvivorCaseValidationNoCustomerDeseasedCaseRole(){
            String actualErrorMessage;
            String expectedErrorMessage = Label.CaseRoleCustomerDeseasedError;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;

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
                
                Case caseRec = UthCase.buildDeathOfTenantSurvivor(contactOne.Id);
                caseRec.Tenancy__c = tenancyJoint.Id;
                caseRec.DateOfDeath__c = Date.today().addDays(-5);
                insert caseRec;

                List<CaseRole__c> caseRoleList = UthCaseRole.getAll();
                for(CaseRole__c caseRole : caseRoleList){
                    if(caseRole.Role__c == CaseRoleDecorator.CUSTOMER_DECEASED_ROLE){
                        delete caseRole;
                    }
                }
                
                TenancyChange__c tcRec = UthTenancyChange.updateRequiredDetailsForTenancyChangeForDeathOfaTenantSurvivor(caseRec.Id);
                Test.startTest();
                try {
                        caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_COMPLETED;
                        caseRec.status = CaseDecorator.STATUS_STAGE_CLOSED;
                        caseRec.ClosureReason__c = 'Test reason';
                        update caseRec;
                 } 
                 catch(Exception exp) {
                        actualErrorMessage = exp.getMessage();
                 }
        	Test.stopTest();
            }

            Assert.areEqual(true,(actualErrorMessage.containsIgnoreCase(expectedErrorMessage)), 'Exception message should be there');
    	}

        @isTest
        static void testDeathOfTenantSurvivorCaseValidationMoreThanOneCustomerDeseasedCaseRole(){
            String actualErrorMessage;
            String expectedErrorMessage = Label.CaseRoleMoreCustomerDeseasedError;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;

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
                
                Case caseRec = UthCase.buildDeathOfTenantSurvivor(contactOne.Id);
                caseRec.Tenancy__c = tenancyJoint.Id;
                caseRec.DateOfDeath__c = Date.today().addDays(-5);
                insert caseRec;

                List<CaseRole__c> caseRoleList = new List<CaseRole__c>();
                caseRoleList.add(UthCaseRole.build(caseRec.Id, contactTwo.Id, CaseRoleDecorator.CUSTOMER_DECEASED_ROLE));
                insert caseRoleList;

                TenancyChange__c tcRec = UthTenancyChange.updateRequiredDetailsForTenancyChangeForDeathOfaTenantSurvivor(caseRec.Id);
                Test.startTest();
                try {
                        caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_COMPLETED;
                        caseRec.status = CaseDecorator.STATUS_STAGE_CLOSED;
                        caseRec.ClosureReason__c = 'Test reason';
                        update caseRec;
                 } 
                 catch(Exception exp) {
                        actualErrorMessage = exp.getMessage();
                 }
        	Test.stopTest();
            }

            Assert.areEqual(true,(actualErrorMessage.containsIgnoreCase(expectedErrorMessage)), 'Exception message should be there');
    	}

        @isTest
        static void testDeathOfTenantSuccessorCase(){
            String actualErrorMessage;
            String expectedErrorMessage = Label.CaseRoleAddInquirerError;
            Contact contactOne;
            Contact contactTwo;
            Contact contactFour;
            YH_Tenancy__c tenancyJoint;

            System.runAs(UthUser.setChangeUser(UserInfo.getUserId())) {
                for(Contact contact : UthContact.getAll()){
                    if(contact.LastName == 'lNameOne'){
                        contactOne = contact;
                    } else if(contact.LastName == 'lNameTwo'){
                        contactTwo = contact;
                    } else if(contact.LastName == 'lNameFour'){
                        contactFour = contact;
                    }
                }

                for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                    if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                        tenancyJoint = tenancy;
                    }
                }
                
                Case caseRec = UthCase.buildDeathOfTenantSuccessor(contactOne.Id);
                caseRec.Tenancy__c = tenancyJoint.Id;
                caseRec.DateOfDeath__c = Date.today().addDays(-5);
                insert caseRec;

                List<CaseRole__c> caseRoleList = new List<CaseRole__c>();
                caseRoleList.add(UthCaseRole.build(caseRec.Id, contactFour.Id, CaseRoleDecorator.APPLICANT_ROLE));
                insert caseRoleList;

                TenancyChange__c tcRec = UthTenancyChange.updateRequiredDetailsForTenancyChangeForDeathOfaTenantSuccessor(caseRec.Id);
                Test.startTest();
                try {
                        caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_COMPLETED;
                        caseRec.status = CaseDecorator.STATUS_STAGE_CLOSED;
                        caseRec.ClosureReason__c = 'Test reason';
                        update caseRec;
                 } 
                 catch(Exception exp) {
                        actualErrorMessage = exp.getMessage();
                 }
        	Test.stopTest();
            }

            List<Member__c> resultMembers = UthMember.getAll();
            List<Contact> resultContacts = UthContact.getAll();
            Member__c resultMember;
            Member__c resultNewMember;
            Contact resultContact;
            for(Member__c member : resultMembers){
                if(member.Contact__c == contactOne.Id && member.Tenancy__c == tenancyJoint.Id){
                    resultMember = member;
                } else if(member.Contact__c == contactFour.Id && member.Tenancy__c == tenancyJoint.Id){
                    resultNewMember = member;
                }
            }

            for(Contact contact : resultContacts){
                if(contact.Id == contactOne.Id){
                    resultContact = contact;
                }
            }

            Assert.areEqual(Date.today(), resultMember.OccupancyEndDate__c, 'Member OccupancyEndDate__c is not populatd');
            Assert.areEqual(Date.today(), resultNewMember.DateOfOccupancy__c, 'Member DateOfOccupancy__c is not populatd');
            Assert.areEqual(MemberDecorator.TYPE_JOINT, resultNewMember.Type__c, 'Member Type__c is not populatd');
            Assert.areEqual(Date.today().addDays(-5), resultContact.DateOfDeath__c, 'Contact DateOfDeath is not populated');
            Assert.areEqual(null,actualErrorMessage, 'Exception message should not be there');
    	}

        @isTest
        static void testDeathOfTenantSuccessorCaseValidationNoApplicantCaseRole(){
            String actualErrorMessage;
            String expectedErrorMessage = Label.CaseRoleApplicantError;
            Contact contactOne;
            Contact contactTwo;
            YH_Tenancy__c tenancyJoint;

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
                
                Case caseRec = UthCase.buildDeathOfTenantSuccessor(contactOne.Id);
                caseRec.Tenancy__c = tenancyJoint.Id;
                caseRec.DateOfDeath__c = Date.today().addDays(-5);
                insert caseRec;

                TenancyChange__c tcRec = UthTenancyChange.updateRequiredDetailsForTenancyChangeForDeathOfaTenantSuccessor(caseRec.Id);
                Test.startTest();
                try {
                        caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_COMPLETED;
                        caseRec.status = CaseDecorator.STATUS_STAGE_CLOSED;
                        caseRec.ClosureReason__c = 'Test reason';
                        update caseRec;
                 } 
                 catch(Exception exp) {
                        actualErrorMessage = exp.getMessage();
                 }
        	Test.stopTest();
            }

            Assert.areEqual(true,(actualErrorMessage.containsIgnoreCase(expectedErrorMessage)), 'Exception message should be there');
    	}

        @isTest
        static void testDeathOfTenantSuccessorCaseValidationMoreThanOneApplicantCaseRole(){
            String actualErrorMessage;
            String expectedErrorMessage = Label.CaseRoleMoreApplicantError;
            Contact contactOne;
            Contact contactTwo;
            Contact contactThree;
            Contact contactFour;
            YH_Tenancy__c tenancyJoint;

            System.runAs(UthUser.setChangeUser(UserInfo.getUserId())) {
                for(Contact contact : UthContact.getAll()){
                    if(contact.LastName == 'lNameOne'){
                        contactOne = contact;
                    } else if(contact.LastName == 'lNameTwo'){
                        contactTwo = contact;
                    } else if(contact.LastName == 'lNameThree'){
                        contactThree = contact;
                    } else if(contact.LastName == 'lNameFour'){
                        contactFour = contact;
                    } 
                }

                for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                    if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                        tenancyJoint = tenancy;
                    }
                }
                
                Case caseRec = UthCase.buildDeathOfTenantSuccessor(contactOne.Id);
                caseRec.Tenancy__c = tenancyJoint.Id;
                caseRec.DateOfDeath__c = Date.today().addDays(-5);
                insert caseRec;

                List<CaseRole__c> caseRoleList = new List<CaseRole__c>();
                caseRoleList.add(UthCaseRole.build(caseRec.Id, contactThree.Id, CaseRoleDecorator.APPLICANT_ROLE));
                caseRoleList.add(UthCaseRole.build(caseRec.Id, contactFour.Id, CaseRoleDecorator.APPLICANT_ROLE));
                insert caseRoleList;

                TenancyChange__c tcRec = UthTenancyChange.updateRequiredDetailsForTenancyChangeForDeathOfaTenantSuccessor(caseRec.Id);
                Test.startTest();
                try {
                        caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_COMPLETED;
                        caseRec.status = CaseDecorator.STATUS_STAGE_CLOSED;
                        caseRec.ClosureReason__c = 'Test reason';
                        update caseRec;
                 } 
                 catch(Exception exp) {
                        actualErrorMessage = exp.getMessage();
                 }
        	Test.stopTest();
            }

            Assert.areEqual(true,(actualErrorMessage.containsIgnoreCase(expectedErrorMessage)), 'Exception message should be there');
    	}

        @isTest
        static void testDeathOfTenantNoSuccessorCase(){
            String actualErrorMessage;
            String expectedErrorMessage = Label.CaseRoleAddInquirerError;
            Contact contactThree;
            YH_Tenancy__c tenancySolo;

            System.runAs(UthUser.setChangeUser(UserInfo.getUserId())) {
                for(Contact contact : UthContact.getAll()){
                    if(contact.LastName == 'lNameThree'){
                        contactThree = contact;
                    }
                }

                for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                    if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_SOLO){
                        tenancySolo = tenancy;
                    }
                }
                
                Case caseRec = UthCase.buildDeathOfTenantNoSuccessor(contactThree.Id);
                caseRec.Tenancy__c = tenancySolo.Id;
                caseRec.DateOfDeath__c = Date.today().addDays(-5);
                insert caseRec;

                TenancyChange__c tcRec = UthTenancyChange.updateRequiredDetailsForTenancyChangeForDeathOfaTenantNoSuccessor(caseRec.Id);
                Test.startTest();
                try {
                        caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_COMPLETED;
                        caseRec.status = CaseDecorator.STATUS_STAGE_CLOSED;
                        caseRec.ClosureReason__c = 'Test reason';
                        update caseRec;
                 } 
                 catch(Exception exp) {
                        actualErrorMessage = exp.getMessage();
                 }
        	Test.stopTest();
            }

            List<Member__c> resultMembers = UthMember.getAll();
            List<Contact> resultContacts = UthContact.getAll();
            List<YH_Tenancy__c> resultTenancies = UthTenancy.getAll();
            Member__c resultMember;
            Contact resultContact;
            YH_Tenancy__c resultTenancy;
            for(Member__c member : resultMembers){
                if(member.Contact__c == contactThree.Id && member.Tenancy__c == tenancySolo.Id){
                    resultMember = member;
                }
            }

            for(Contact contact : resultContacts){
                if(contact.Id == contactThree.Id){
                    resultContact = contact;
                }
            }

            for(YH_Tenancy__c tenancy : resultTenancies){
                if(tenancy.Id == tenancySolo.Id){
                    resultTenancy = tenancy;
                }
            }

            Assert.areEqual(Date.today().addDays(-5), resultContact.DateOfDeath__c, 'Contact DateOfDeath is not populated');
       }
}