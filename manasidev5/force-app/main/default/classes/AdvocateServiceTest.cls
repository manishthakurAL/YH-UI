@isTest(seeAllData=false)
public with sharing class AdvocateServiceTest {
    @testSetup
        static void setUpTestData(){
            UthFeatureSwitches.enableCustomerRT();
        	TriggerBase.bypass('Account');
        	Account account1 = UthAccount.buildPersonAccount();
        	insert account1;
            Account account2 = UthAccount.buildPersonAccount();
        	insert account2;
            Account account3 = UthAccount.buildPersonAccount();
        	insert account3;
        	
        	TriggerBase.clearBypass('Account');
    	}
    	@isTest
        static void testCaseRolesValidationWithoutTenantAndInquirer(){
            String actualErrorMessage;
            String expectedErrorMessage = Label.CaseRoleAddInquirerError;
            System.runAs(UthUser.setCustomerUser(UserInfo.getUserId())) {
                List<Contact> contactList = UthContact.getAll();
                Case caseRec = UthCase.buildCustomerCase(contactList[0].Id);
                caseRec.CaseType__c = CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_NEW;
                insert caseRec;
                AuthorityAndDetail__c authRec = UthAuthorityAndDetail.updateRequiredDetailsForAuthorityDetailsOfPANew(caseRec.Id);
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
        static void testCaseRolesValidationWithTenantAndWithoutInquirer(){
            String actualErrorMessage;
            String expectedErrorMessage = Label.CaseRoleAddInquirerError;
            System.runAs(UthUser.setCustomerUser(UserInfo.getUserId())) {
                List<Contact> contactList = UthContact.getAll();
                Case caseRec = UthCase.buildCustomerCase(contactList[0].Id);
                caseRec.CaseType__c = CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_NEW;
                insert caseRec;

                AuthorityAndDetail__c authRec = UthAuthorityAndDetail.updateRequiredDetailsForAuthorityDetailsOfPANew(caseRec.Id);


                //Contact contact = UthContact.getAll()[0];
                //CaseRole__c aCaseRole = UthCaseRole.build(caseRec.Id,contact.Id,CaseRoleDecorator.TENANT_ROLE);
                //insert aCaseRole;
    
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
            Assert.areEqual(true,actualErrorMessage.containsIgnoreCase(expectedErrorMessage), 'Exception message should be there');
    	}
        @isTest
        static void testCaseRolesValidationWithMultipleTenants(){
            String actualErrorMessage;
            String expectedErrorMessage = Label.MoreThanOneTenantError;
            System.runAs(UthUser.setCustomerUser(UserInfo.getUserId())) {
                List<Contact> contactList = UthContact.getAll();
                Case caseRec = UthCase.buildCustomerCase(contactList[0].Id);
                caseRec.CaseType__c = CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_NEW;
                insert caseRec;

                AuthorityAndDetail__c authRec = UthAuthorityAndDetail.updateRequiredDetailsForAuthorityDetailsOfPANew(caseRec.Id);

                CaseRole__c tenantCaseRole;
                List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
                for(CaseRole__c caseRole : resultCaseRoles){
                    if(caseRole.Role__c == CaseRoleDecorator.TENANT_ROLE){
                        tenantCaseRole = caseRole;
                    } 
                }

                CaseRole__c CaseRole2 = UthCaseRole.build(caseRec.Id,contactList[1].Id,CaseRoleDecorator.TENANT_ROLE);
                insert CaseRole2;
                
                CaseRole__c CaseRole3 = UthCaseRole.build(caseRec.Id,contactList[2].Id,CaseRoleDecorator.POA_INQUIRER_ROLE);
                insert CaseRole3;
    
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
            Assert.areEqual(true,actualErrorMessage.containsIgnoreCase(expectedErrorMessage), 'Exception message should be there');
    	}
        @isTest
        static void testPOAAdvocateCreation(){
            List<Contact> contactList = UthContact.getAll();
            System.runAs(UthUser.setCustomerUser(UserInfo.getUserId())) {
                Case caseRec = UthCase.buildCustomerCase(contactList[0].Id);
                caseRec.CaseType__c = CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_NEW;
                insert caseRec;

                CaseRole__c CaseRole2 = UthCaseRole.build(caseRec.Id,contactList[1].Id,CaseRoleDecorator.POA_INQUIRER_ROLE);
                insert CaseRole2;
                
                AuthorityAndDetail__c authRec = UthAuthorityAndDetail.updateRequiredDetailsForAuthorityDetailsOfPANew(caseRec.Id);

                Test.startTest();
                    caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_APPROVED;
                    caseRec.status = CaseDecorator.STATUS_STAGE_CLOSED;
                    caseRec.ClosureReason__c = 'Test reason';
                    update caseRec;
                Test.stopTest();
            }
            List<Advocate__c> advList = UthAdvocate.getAll();
            Assert.areEqual(1,advList.size(), 'Advocate record should be created');
            Assert.areEqual(contactList[0].Id,advList[0].AuthorisedBy__c, 'Tenant Id should be there');
            Assert.areEqual(contactList[1].Id,advList[0].AuthorisedTo__c, 'Inquirer Id should be there');
            Assert.areEqual(AdvocateDecorator.AUTHORIZATIONTYPE_POWER_OF_ATTORNEY,advList[0].AuthorisationType__c, 'Authorization type should be Power of Attorney');
            Assert.areEqual(System.today(),advList[0].StartDate__c, 'Start date should be there');
            Assert.areEqual(System.today(),advList[0].DocumentsValidFrom__c, 'Document Valid From Date should be Today');
    	}
        @isTest
        static void testDAAdvocateCreation(){
            List<Contact> contactList = UthContact.getAll();
            System.runAs(UthUser.setCustomerUser(UserInfo.getUserId())) {
                Case caseRec = UthCase.buildCustomerCase(contactList[0].Id);
                caseRec.CaseType__c = CaseDecorator.CASE_TYPE_DELEGATED_AUTHORITY_NEW;
                insert caseRec;

                CaseRole__c CaseRole2 = UthCaseRole.build(caseRec.Id,contactList[1].Id,CaseRoleDecorator.DA_INQUIRER_ROLE);
                insert CaseRole2;

                AuthorityAndDetail__c authRec = UthAuthorityAndDetail.updateRequiredDetailsForAuthorityDetailsOfDANew(caseRec.Id);

                Test.startTest();
                    caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_APPROVED;
                    caseRec.status = CaseDecorator.STATUS_STAGE_CLOSED;
                    caseRec.ClosureReason__c = 'Test reason';
                    update caseRec;
                Test.stopTest();
            }
        	List<Advocate__c> advList = UthAdvocate.getAll();
            Assert.areEqual(1,advList.size(), 'Advocate record should be created');
            Assert.areEqual(contactList[0].Id,advList[0].AuthorisedBy__c, 'Tenant Id should be there');
            Assert.areEqual(contactList[1].Id,advList[0].AuthorisedTo__c, 'Inquirer Id should be there');
            Assert.areEqual(AdvocateDecorator.AUTHORIZATIONTYPE_DELEGATED_AUTHORITY,advList[0].AuthorisationType__c, 'Authorization type should be Delegated Authority');
            Assert.areEqual(System.today(),advList[0].StartDate__c, 'Start date should be there');
    	    Assert.areEqual(System.today(),advList[0].DocumentsValidFrom__c, 'Document Valid From Date should be Today');
        }
        @isTest
        static void testPOAAdvocateDeactivation(){
            System.runAs(UthUser.setCustomerUser(UserInfo.getUserId())) {
                List<Contact> contactList = UthContact.getAll();
                Advocate__c advocate = UthAdvocate.build(contactList[0].Id,contactList[1].Id,AdvocateDecorator.AUTHORIZATIONTYPE_POWER_OF_ATTORNEY);
                advocate.StartDate__c = System.today().addDays(-1);
                insert advocate;

                Case caseRec = UthCase.buildCustomerCase(contactList[0].Id);
                caseRec.CaseType__c = CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_REMOVE;
                insert caseRec;

                CaseRole__c CaseRole2 = UthCaseRole.build(caseRec.Id,contactList[1].Id,CaseRoleDecorator.POA_ROLE);
                insert CaseRole2;
                
                AuthorityAndDetail__c authRec = UthAuthorityAndDetail.updateRequiredDetailsForAuthorityDetailsOfPARemove(caseRec.Id);

                Test.startTest();
                    caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_APPROVED;
                    caseRec.status = CaseDecorator.STATUS_STAGE_CLOSED;
                    caseRec.ClosureReason__c = 'Test reason';
                    update caseRec;
                Test.stopTest();
            }
            List<Advocate__c> advList = UthAdvocate.getAll();

            Assert.areEqual(System.today(),advList[0].EndDate__c, 'Advocate record end date should be changed');
    	}
        @isTest
        static void testPOAAdvocateDeactivationWithoutAdvocate(){
            String actualErrorMessage;
            String expectedErrorMessage = Label.AdvocateNotFoundError;
            System.runAs(UthUser.setCustomerUser(UserInfo.getUserId())) {
                List<Contact> contactList = UthContact.getAll();

                Case caseRec = UthCase.buildCustomerCase(contactList[0].Id);
                caseRec.CaseType__c = CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_REMOVE;
                insert caseRec;

                CaseRole__c CaseRole2 = UthCaseRole.build(caseRec.Id,contactList[1].Id,CaseRoleDecorator.POA_ROLE);
                insert CaseRole2;
                
                AuthorityAndDetail__c authRec = UthAuthorityAndDetail.updateRequiredDetailsForAuthorityDetailsOfPARemove(caseRec.Id);

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
            Assert.areEqual(true,actualErrorMessage.containsIgnoreCase(expectedErrorMessage), 'Exception message should be there');
    	}
        @isTest
        static void testMultiplePOAAdvocateCreation(){
        	System.runAs(UthUser.setCustomerUser(UserInfo.getUserId())) {
                List<Contact> contactList = UthContact.getAll();
                Case caseRec = UthCase.buildCustomerCase(contactList[0].Id);
                caseRec.CaseType__c = CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_NEW;
                insert caseRec;

                CaseRole__c tenantCaseRole;
                List<CaseRole__c> resultCaseRoles = UthCaseRole.getAll();
                for(CaseRole__c caseRole : resultCaseRoles){
                    if(caseRole.Role__c == CaseRoleDecorator.TENANT_ROLE){
                        tenantCaseRole = caseRole;
                    } 
                }

                CaseRole__c CaseRole2 = UthCaseRole.build(caseRec.Id,contactList[1].Id,CaseRoleDecorator.POA_INQUIRER_ROLE);
                insert CaseRole2;
                
                CaseRole__c CaseRole3 = UthCaseRole.build(caseRec.Id,contactList[2].Id,CaseRoleDecorator.POA_INQUIRER_ROLE);
                insert CaseRole3;

                AuthorityAndDetail__c authRec = UthAuthorityAndDetail.updateRequiredDetailsForAuthorityDetailsOfPANew(caseRec.Id);
                Test.startTest();
                     caseRec.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_APPROVED;
                     caseRec.status = CaseDecorator.STATUS_STAGE_CLOSED;
                     caseRec.ClosureReason__c = 'Test reason';
                     update caseRec;
                Test.stopTest();
            	List<Advocate__c> advList = UthAdvocate.getAll();

                Assert.areEqual(2,advList.size(), '2 Advocate records should be created');
                Assert.areEqual(tenantCaseRole.Contact__c,advList[0].AuthorisedBy__c, 'Tenant Id should be populated');
                Assert.areEqual(CaseRole2.Contact__c,advList[0].AuthorisedTo__c, 'Tenant Id should be populated');
                Assert.areEqual(tenantCaseRole.Contact__c,advList[1].AuthorisedBy__c, 'Inquirer Id should be populated');
                Assert.areEqual(CaseRole3.Contact__c,advList[1].AuthorisedTo__c, 'Inquirer Id should be populated');
                Assert.areEqual(AdvocateDecorator.AUTHORIZATIONTYPE_POWER_OF_ATTORNEY,advList[0].AuthorisationType__c, 'Authorization type should be Power of Attorney');
                Assert.areEqual(AdvocateDecorator.AUTHORIZATIONTYPE_POWER_OF_ATTORNEY,advList[1].AuthorisationType__c, 'Authorization type should be Power of Attorney');
                Assert.areEqual(System.today(),advList[0].StartDate__c, 'Start date should be there');
                Assert.areEqual(System.today(),advList[1].StartDate__c, 'Start date should be there');
            }
    	}
        @isTest
        static void testPOAAdvocateCreationWithActiveAdvocate(){
            String actualErrorMessage;
            String expectedErrorMessage = Label.ActiveAdvocateAlreadyExistsError;
            System.runAs(UthUser.setCustomerUser(UserInfo.getUserId())) {
                List<Contact> contactList = UthContact.getAll();
                Case caseRec = UthCase.buildCustomerCase(contactList[0].Id);

                Advocate__c advocate = UthAdvocate.build(contactList[0].Id,contactList[1].Id,AdvocateDecorator.AUTHORIZATIONTYPE_POWER_OF_ATTORNEY);
                insert advocate;

                caseRec.CaseType__c = CaseDecorator.CASE_TYPE_POWER_OF_ATTORNEY_NEW;
                insert caseRec;

                CaseRole__c CaseRole2 = UthCaseRole.build(caseRec.Id,contactList[1].Id,CaseRoleDecorator.POA_INQUIRER_ROLE);
                insert CaseRole2;
                
                AuthorityAndDetail__c authRec = UthAuthorityAndDetail.updateRequiredDetailsForAuthorityDetailsOfPANew(caseRec.Id);

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
            Assert.areEqual(true,actualErrorMessage.containsIgnoreCase(expectedErrorMessage), 'Exception message should be there');
    	}
        
}