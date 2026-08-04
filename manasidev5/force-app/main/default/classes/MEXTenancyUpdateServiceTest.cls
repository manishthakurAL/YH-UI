@isTest
private class MEXTenancyUpdateServiceTest {

    @testSetup
    static void setUpTestData(){
        
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        UthFeatureSwitches.enableCaseChangesRT();
        TriggerBase.bypass('Account');
        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccount('fNameOne', 'lNameOne'));
        accountList.add(UthAccount.buildPersonAccount('fNameTwo', 'lNameTwo'));
        accountList.add(UthAccount.buildPersonAccount('fNameExt', 'lNameExt'));
        Insert accountList;

        Contact contactOne;
        Contact contactTwo;
        
        for(Contact contact : UthContact.getAll()){
            if(contact.LastName == 'lNameOne'){
                contactOne = contact;
            } else if(contact.LastName == 'lNameTwo'){
                contactTwo = contact;
            }
        }

        Case testCase = UthCase.buildMutualExchangeCase(contactOne.Id);
        Insert testCase;

        List<YH_Property__c> propList = new List<YH_Property__c>();
        propList.add(uthProperty.buildPropertyWithDesignAssumptions(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS,
            PropertyDecorator.AUTHCODE_E08000038,
            PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
            PropertyDecorator.RENT_TYPE_RENTTOBUY
            ));
        propList.add(uthProperty.buildPropertyWithDesignAssumptions(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS,
            PropertyDecorator.AUTHCODE_E08000038,
            PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT,
            PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL
            ));
        propList[0].Address__City__s = 'Test City 1';
        propList[0].Address__PostalCode__s = 'RM8 1YQ';
        propList[1].Address__City__s = 'Test City 3';
        propList[1].Address__PostalCode__s = 'RM8 3YQ';
            
        Insert propList;
        
        
        

        List<YH_Tenancy__c> tenancyList = new List<YH_Tenancy__c>();
        tenancyList.add(UthTenancy.build(propList[0].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO));
        tenancyList.add(UthTenancy.build(propList[1].Id, true, TenancyDecorator.TENANCY_TYPE_SOLO));
        Insert tenancyList;

        List<Member__c> memberList = new List<Member__c>();
        memberList.add(UthMember.build(contactOne.Id, tenancyList[0].Id, MemberDecorator.TYPE_SOLO));
        memberList.add(UthMember.build(contactTwo.Id, tenancyList[1].Id, MemberDecorator.TYPE_SOLO));
        Insert memberList;

        YH_Mutual_Exchange__c mexIncoming = UthMutualExchange.buildInternalPropertyWithSwapExchange(testCase.Id, null, propList[0].Id, MutualExchangeDecorator.TYPE_SOLE_TO_SOLE);
        Insert mexIncoming;
        YH_Mutual_Exchange__c mex = UthMutualExchange.buildInternalPropertyWithSwapExchange(testCase.Id, mexIncoming.Id, propList[1].Id, MutualExchangeDecorator.TYPE_SOLE_TO_SOLE);
        Insert mex;
        mexIncoming.ExchangeSwapNumber__c = mex.Id;
        Update mexIncoming;        

        MutualExchangeApplicant__c ma = UthMutualExchangeApplicant.build(mexIncoming.Id, contactOne.Id, MutualExchangeApplicantDecorator.TENENT_TYPE_SOLE_TENANT);
        Insert ma;
        MutualExchangeApplicant__c mb = UthMutualExchangeApplicant.build(mex.Id, contactTwo.Id, MutualExchangeApplicantDecorator.TENENT_TYPE_SOLE_TENANT);
        Insert mb;

        MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName()); 
        TriggerBase.clearBypass('Account');
    }

	@isTest
    static void caseClosureOutcomeCompleted(){
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        list<case> caseList = UthCase.getAll();
        map<Id, YH_Tenancy__c> existingTenancyList = new map<Id, YH_Tenancy__c>(UthTenancy.getAll());
        map<Id, Member__c> existingMemberList = new map<Id, Member__c>(UthMember.getAll());
        case caseCompletion = new case(Id=caseList[0].Id, Status=CaseDecorator.STATUS_STAGE_CLOSED, CaseOutcome__c=CaseDecorator.CASE_OUTCOME_COMPLETED, DeedofAssignmentDate__c=System.today()+1, ClosureReason__c='Closure', SecureRent__c='No', DateofMEXApprovalLetter__c=System.today()+1, ColleagueName__c='Ana');
        Test.startTest();
        Update caseCompletion;
        Test.stopTest();
        MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName()); 

        list<Id> personAccList = new list<Id>();
        for(Contact contact : UthContact.getAll()){
            if(contact.LastName == 'lNameOne'){
                personAccList.add(contact.Id);
            } else if(contact.LastName == 'lNameTwo'){
                personAccList.add(contact.Id);
            }
        }

        for(YH_Tenancy__c t : UthTenancy.getAll()){
            if(existingTenancyList.containskey(t.Id)){
                System.AssertEquals(system.today(), t.TenancyEndDate__c, 'Tenancy EndDate has not been populated.');
            }else{
                System.AssertEquals(system.today()+1, t.StartDate__c, 'Tenancy EndDate has not been populated.');                
            }
        }

        for(Member__c m : UthMember.getAll()){
            if(existingMemberList.containskey(m.Id)){
                System.AssertEquals(system.today(), m.OccupancyEndDate__c, 'Member EndDate has not been populated.');
            }else{
                System.AssertEquals(system.today()+1, m.DateOfOccupancy__c, 'Member StartDate has not been populated.');
                system.Assert(personAccList.contains(m.Contact__c), 'Member has not been added to the Tenancy');
            }
        }
    }

    @isTest
    static void caseClosureOutcomeRefused(){
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        list<case> caseList = UthCase.getAll();
        map<Id, YH_Tenancy__c> existingTenancyList = new map<Id, YH_Tenancy__c>(UthTenancy.getAll());
        map<Id, Member__c> existingMemberList = new map<Id, Member__c>(UthMember.getAll());
        case caseCompletion = new case(Id=caseList[0].Id, Status=CaseDecorator.STATUS_STAGE_CLOSED, CaseOutcome__c=CaseDecorator.CASE_OUTCOME_REFUSED, DeedofAssignmentDate__c=System.today()+1, ClosureReason__c='Closure', SecureRent__c='No', DateofMEXApprovalLetter__c=System.today()+1, ColleagueName__c='Ana');
        Test.startTest();
        Update caseCompletion;
        Test.stopTest();
        MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());         

        for(YH_Tenancy__c t : UthTenancy.getAll()){
            if(existingTenancyList.containskey(t.Id)){
                System.AssertEquals(null, t.TenancyEndDate__c, 'Tenancy EndDate should not be populated.');
            }else{
                System.AssertEquals(null, t.StartDate__c, 'Tenancy EndDate should not be populated.');                
            }
        }

        for(Member__c m : UthMember.getAll()){
            if(existingMemberList.containskey(m.Id)){
                System.AssertNotEquals(system.today(), m.OccupancyEndDate__c, 'Member EndDate should not be populated.');
            }else{
                System.AssertEquals(null, m.DateOfOccupancy__c, 'Member StartDate should not be populated.');
            }
        }
    }

    @isTest
    static void internalToExternalCaseClosureOutcomeCompleted(){
        list<case> caseList = UthCase.getAll();
        map<Id, YH_Tenancy__c> existingTenancyList = new map<Id, YH_Tenancy__c>(UthTenancy.getAll());
        map<Id, Member__c> existingMemberList = new map<Id, Member__c>(UthMember.getAll());
        YH_Mutual_Exchange__c mexExternalProperty = UthMutualExchange.buildExternalProperty(caseList[0].Id, '1232456');
        Insert mexExternalProperty;
        list<YH_Mutual_Exchange__c> mexList = UthMutualExchange.getAllInternalPropertyType();
        mexList[0].ExchangeSwapNumber__c = mexExternalProperty.Id;
        update mexList;
		mexExternalProperty.ExchangeSwapNumber__c = mexList[0].Id;
        update mexExternalProperty;
        Contact contactExt;
        
        for(Contact contact : UthContact.getAll()){
            if(contact.LastName == 'lNameExt'){
                contactExt = contact;
            }
       
        }

        MutualExchangeApplicant__c ma = UthMutualExchangeApplicant.build(mexExternalProperty.Id, contactExt.Id, MutualExchangeApplicantDecorator.TENENT_TYPE_SOLE_TENANT);
        Insert ma;
        
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        case caseCompletion = new case(Id=caseList[0].Id, Status=CaseDecorator.STATUS_STAGE_CLOSED, CaseOutcome__c=CaseDecorator.CASE_OUTCOME_COMPLETED, DeedofAssignmentDate__c=System.today()+1, ClosureReason__c='Closure', SecureRent__c='No', DateofMEXApprovalLetter__c=System.today()+1, ColleagueName__c='Ana');
        Test.startTest();
        Update caseCompletion;
        Test.stopTest();
        MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName()); 
        
        list<Id> personAccList = new list<Id>();
        for(Contact contact : UthContact.getAll()){
            if(contact.LastName == 'lNameOne'){
                personAccList.add(contact.Id);
            } else if(contact.LastName == 'lNameExt'){
                personAccList.add(contact.Id);
            }
        }

        for(YH_Tenancy__c t : UthTenancy.getAll()){
            if(existingTenancyList.containskey(t.Id)){
                System.AssertEquals(system.today(), t.TenancyEndDate__c, 'Tenancy EndDate has not been populated.');
            }else{
                System.AssertEquals(system.today()+1, t.StartDate__c, 'Tenancy EndDate has not been populated.');                
            }
        }

        for(Member__c m : UthMember.getAll()){
            if(existingMemberList.containskey(m.Id)){
                System.AssertEquals(system.today(), m.OccupancyEndDate__c, 'Member EndDate has not been populated.');
                
            }else{
                System.AssertEquals(system.today()+1, m.DateOfOccupancy__c, 'Member StartDate has not been populated.');
                system.Assert(personAccList.contains(m.Contact__c), 'Member has not been added to the Tenancy');
                system.AssertEquals(m.SynchPropertyAddressOnActivation__c, MutualExchangeDecorator.TYPE_MUTUAL_EXCHANGE ,'Synch Property Address flag should be populated');
            }
        }
    }
    @isTest
    static void threeMutualExchangesCaseClosureOutcomeCompleted(){
        list<case> caseList = UthCase.getAll();
        map<Id, YH_Tenancy__c> existingTenancyList = new map<Id, YH_Tenancy__c>(UthTenancy.getAll());
        map<Id, Member__c> existingMemberList = new map<Id, Member__c>(UthMember.getAll());
        list<YH_Mutual_Exchange__c> mexList = UthMutualExchange.getAll();
        YH_Mutual_Exchange__c mexExternalProperty = UthMutualExchange.buildExternalProperty(caseList[0].Id, null);
        Insert mexExternalProperty;
        mexList[0].ExchangeSwapNumber__c = mexExternalProperty.Id;
        mexList[1].ExchangeSwapNumber__c = mexList[0].Id;
        update mexList;
        mexExternalProperty.ExchangeSwapNumber__c = mexList[1].Id;
        update mexExternalProperty;
      
        Contact contactExt;
        Contact contactOne;
        Contact contactTwo;
        for(Contact contact : UthContact.getAll()){
            if(contact.LastName == 'lNameExt'){
                contactExt = contact;
            }
            if(contact.LastName == 'lNameOne'){
                contactOne = contact;
            } else if(contact.LastName == 'lNameTwo'){
                contactTwo = contact;
            }
        }
        
        MutualExchangeApplicant__c ma = UthMutualExchangeApplicant.build(mexExternalProperty.Id, contactExt.Id, MutualExchangeApplicantDecorator.TENENT_TYPE_SOLE_TENANT);
        Insert ma;
        
        MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        case caseCompletion = new case(Id=caseList[0].Id, Status=CaseDecorator.STATUS_STAGE_CLOSED, CaseOutcome__c=CaseDecorator.CASE_OUTCOME_COMPLETED, DeedofAssignmentDate__c=System.today()+1, ClosureReason__c='Closure', SecureRent__c='No', DateofMEXApprovalLetter__c=System.today()+1, ColleagueName__c='Ana');
        Test.startTest();
        Update caseCompletion;
        Test.stopTest();
        MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName()); 

        for(Member__c m : UthMember.getAll()){
            if(existingMemberList.containskey(m.Id)){
                System.AssertEquals(system.today(), m.OccupancyEndDate__c, 'Member EndDate has not been populated.');
                if(m.Contact__c == contactTwo.Id){
                    System.AssertEquals(m.SynchAddress__City__s, mexExternalProperty.ExternalAddress2__City__s, 'Synch Address should be populated.');
                    System.AssertEquals(m.SynchAddress__PostalCode__s, mexExternalProperty.ExternalAddress2__PostalCode__s, 'Synch Address should be populated.');
                    System.AssertEquals(m.SynchAddress__CountryCode__s,'GB' , 'Synch Address should be populated.');
                    System.AssertEquals(m.SynchPropertyAddressOnDeactivation__c, MutualExchangeDecorator.TYPE_MUTUAL_EXCHANGE ,'Synch Property Address flag should be populated');
                }
                
            }else{
                System.AssertEquals(system.today()+1, m.DateOfOccupancy__c, 'Member StartDate has not been populated.');
                system.AssertEquals(m.SynchPropertyAddressOnActivation__c, MutualExchangeDecorator.TYPE_MUTUAL_EXCHANGE ,'Synch Property Address flag should be populated');
                if(m.Contact__c == contactOne.Id){
                    System.AssertEquals(m.SynchAddress__City__s,'Test City 3', 'Synch Address should be populated.');
                    System.AssertEquals(m.SynchAddress__PostalCode__s,'RM8 3YQ' , 'Synch Address should be populated.');
                    System.AssertEquals(m.SynchAddress__CountryCode__s,'GB' , 'Synch Address should be populated.');
                    System.AssertEquals(m.SynchPropertyAddressOnActivation__c, MutualExchangeDecorator.TYPE_MUTUAL_EXCHANGE ,'Synch Property Address flag should be populated');
                } else if(m.Contact__c == contactExt.Id){
                    System.AssertEquals(m.SynchAddress__City__s,'Test City 1', 'Synch Address should be populated.');
                    System.AssertEquals(m.SynchAddress__PostalCode__s,'RM8 1YQ' , 'Synch Address should be populated.');
                    System.AssertEquals(m.SynchAddress__CountryCode__s,'GB' , 'Synch Address should be populated.');
                    System.AssertEquals(m.SynchPropertyAddressOnActivation__c, MutualExchangeDecorator.TYPE_MUTUAL_EXCHANGE ,'Synch Property Address flag should be populated');
                }
            }
        }
    }
}