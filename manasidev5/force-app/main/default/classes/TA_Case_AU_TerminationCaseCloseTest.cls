@isTest
public with sharing class TA_Case_AU_TerminationCaseCloseTest {
    @TestSetup
    static void makeData(){
        UthFeatureSwitches.enableAllRT();
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        Account account = UthAccount.build();
        insert account;
        
        
        Contact contact = UthContact.build(account.Id);
        insert contact;

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        
    }

    @isTest
    static void testUpdateForwardingAddressProcess(){
        Id userId = UserInfo.getUserId();
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
        UthFeatureSwitches.enableCaseTerminationRT(); 
        UthFeatureSwitches.enableCaseLettingRT();
        TriggerBase.bypass('Account');
        Account account1 = UthAccount.buildPersonAccount();
        insert account1;
        TriggerBase.clearBypass('Account');      
        YH_Property__c aproperty = uthProperty.buildPropertyWithDesignAssumptions(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE,
            PropertyDecorator.AUTHCODE_E08000038,
            PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
            PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE
            );
        insert aproperty;
        YH_Tenancy__c tenancy = UthTenancy.build(aproperty.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        insert tenancy;
        Member__c aMember = UthMember.build(UthContact.getAll()[0].Id, tenancy.Id, MemberDecorator.TYPE_SOLO);
        aMember.IsActiveValue__c = true;
        insert aMember;
        Contact contact = UthContact.getAll().get(0);
        
        System.runAs(new User(Id = userId)) {
          
            Case caseRecord = UthCase.buildTerminationCase(contact.Id, tenancy.Id);
            caseRecord.ReporterType__c = CaseRoleDecorator.TENANT_ROLE;
            insert caseRecord;
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());

            MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Termination_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_InspectionCheck_BU_CheckPermission.class.getName());
            Test.startTest();
            YH_Inspection_Checklist__c inspectionChecklist = UthInspectionChecklist.getAll()[0];
            inspectionChecklist.InspectionType__c = 'Pre Term';
            inspectionChecklist.PreTermInspectionCompleted__c = CaseDecorator.YES;
            update inspectionChecklist;
            Termination__c terminationRecord = UthTermination.getAll()[0];
            UthTermination.setForwardingAddress(terminationRecord);
            update terminationRecord;
            caseRecord.status = CaseDecorator.STATUS_COMPLETE_CASE;
            caseRecord.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_TENANCY_ENDED;
            update caseRecord;
            MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Termination_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BU_CheckPermission.class.getName());
            Test.stopTest();            
        }
        aMember = UthMember.getAll()[0];
        Assert.areEqual('Test Street',amember.SynchAddress__Street__s);
        aMember.IsActiveValue__c = false;
        update aMember;
        contact = UthContact.getAll()[0];
        Assert.isNotNull(contact.MailingAddress);
        Assert.isNotNull(contact.MailingAddress__c);
        Assert.areEqual('Test Street',contact.MailingStreet);
    }

    @isTest
    static void testUpdateForwardingAddressProcessJoint(){
        Id userId = UserInfo.getUserId();
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.bypass(TA_Termination_BI_CheckPermission.class.getName());
        MetadataTriggerHandler.bypass(TA_InspectionCheck_BI_CheckPermission.class.getName());
        UthFeatureSwitches.enableCaseTerminationRT(); 
        UthFeatureSwitches.enableCaseLettingRT();
        TriggerBase.bypass('Account');
        Account account1 = UthAccount.build();
        insert account1;
        Contact jointContact = UthContact.build(account1.Id);
        insert jointContact;
        TriggerBase.clearBypass('Account');     
        YH_Property__c aproperty = uthProperty.buildPropertyWithDesignAssumptions(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE,
            PropertyDecorator.AUTHCODE_E08000038,
            PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
            PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE
            );
        insert aproperty;
        YH_Tenancy__c tenancy = UthTenancy.build(aproperty.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT);
        insert tenancy;
        Member__c aMember = UthMember.build(UthContact.getAll()[0].Id, tenancy.Id, MemberDecorator.TYPE_SOLO);
        aMember.IsActiveValue__c = true;
        insert aMember;
        aMember = UthMember.build(jointContact.Id, tenancy.Id, MemberDecorator.TYPE_JOINT);
        aMember.IsActiveValue__c = true;
        insert aMember;
        System.runAs(new User(Id = userId)) {
          
            Case caseRecord = UthCase.buildTerminationCase(UthContact.getAll()[0].Id, tenancy.Id);
            caseRecord.ReporterType__c = CaseRoleDecorator.TENANT_ROLE;
            insert caseRecord;
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Termination_BI_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BI_CheckPermission.class.getName());

            MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.bypass(TA_Termination_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.bypass(TA_InspectionCheck_BU_CheckPermission.class.getName());
            Test.startTest();
            YH_Inspection_Checklist__c inspectionChecklist = UthInspectionChecklist.getAll()[0];
            inspectionChecklist.InspectionType__c = 'Pre Term';
            inspectionChecklist.PreTermInspectionCompleted__c = CaseDecorator.YES;
            update inspectionChecklist;
            Termination__c terminationRecord = UthTermination.getAll()[0];
            UthTermination.setForwardingAddress(terminationRecord);
            update terminationRecord;
            caseRecord.status = CaseDecorator.STATUS_COMPLETE_CASE;
            caseRecord.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_TENANCY_ENDED;
            update caseRecord;
            MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_Termination_BU_CheckPermission.class.getName());
            MetadataTriggerHandler.clearBypass(TA_InspectionCheck_BU_CheckPermission.class.getName());
            Test.stopTest();            
        }
        aMember = UthMember.getAll()[0];
        Assert.areEqual('Test Street',amember.SynchAddress__Street__s);
        aMember.IsActiveValue__c = false;
        update aMember;
        Contact mainCaseContact = UthContact.getAll()[0];
        Assert.isNotNull(mainCaseContact.MailingAddress);
        Assert.isNotNull(mainCaseContact.MailingAddress__c);
        Assert.areEqual('Test Street',mainCaseContact.MailingStreet);
        aMember = UthMember.getAll()[1];
        Assert.areNotEqual('Test Street',amember.SynchAddress__Street__s);
        aMember.IsActiveValue__c = false;
        update aMember;
        jointContact = UthContact.getAll()[1];
        Assert.areNotEqual('Test Street',jointContact.MailingStreet);
    }
}