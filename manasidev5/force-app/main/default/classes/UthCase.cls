@isTest
public with sharing class UthCase {
    
    public static Case build(Id contactId){
        Case caseRecord = new Case(
            ContactId = contactId
        );
        caseRecord = setCreatedvianewMCCFlow(caseRecord);
        return caseRecord;
    }

    public static Case setCreatedvianewMCCFlow(Case caseRecord){
        caseRecord.CaseFeatureSwitches__c = CaseDecorator.CASEFEATURE_NEW_MCC_FLOW;
        return caseRecord;
    }

    public static Case buildLettingsCase(Id contactId, Id accountId, Id tenancyId){
        Case caseRecord = build(contactId);
        caseRecord.AccountId = accountId;
        caseRecord.Tenancy__c = tenancyId;
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_LETTINGS;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.TYPE_LETTING;
        caseRecord.RecordType__c = 'Letting';
        caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_LETTING;
        return caseRecord;
    }

    public static Case buildCustomerCase(Id contactId){
        Case caseRecord = build(contactId);
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_CUSTOMER;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.TYPE_CUSTOMER;
        caseRecord.RecordType__c = CaseDecorator.RECORD_TYPE_CUSTOMER;
        caseRecord.CaseType__c = CaseDecorator.TYPE_CHANGE_CUSTOMER_DETAILS;
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildCustomerCaseWithTenancyAndReporter(Id contactId, Id tenancyId, Id reporterId){
        Case caseRecord = buildCustomerCase(contactId);
        caseRecord.Tenancy__c = tenancyId;
        caseRecord.Reporter__c = reporterId;
        return caseRecord;
    }

    public static Case buildComplaintCase(Id contactId){
        Case caseRecord = new Case(
            ContactId = contactId,
            RecordTypeId = CaseDecorator.RECORD_TYPE_ID_COMPLAINTS,
            Status = CaseDecorator.STATUS_INITIAL_COMPLAINT,
            Type = CaseDecorator.TYPE_COMPLAINT,
            SubStatus__c = '',
            OriginalReceivedDateTime__c = System.now()
        );
        setRequiredFields(caseRecord);
        return caseRecord;
    }

    public static Case buildLettingsCase(Id contactId){
        Case caseRecord = new Case(
            ContactId = contactId,
            RecordTypeId = CaseDecorator.RECORD_TYPE_ID_LETTINGS,
            Status = CaseDecorator.STATUS_NEW,
            Type = CaseDecorator.TYPE_LETTING_TERMINATION,
            SubStatus__c = ''
        );
        setRequiredFields(caseRecord);
        return caseRecord;
    }

    public static Case buildMoneyCoachingCase(Id contactId){
        Case caseRecord = build(contactId);
        caseRecord.ContactId = contactId;
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_MONEY_COACHING;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.TYPE_COMPLAINT;
        caseRecord.OriginalReceivedDateTime__c = System.now();
        caseRecord.Priority = CaseDecorator.PRIORITY_HIGH;
        caseRecord.PriorityChangeReason__c = CaseDecorator.PRIORITY_CHANGE_REASON_TIME_SPENT_ON_WAITING_LIST;
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildMoneyCoachingCaseWithTenancyAndReporterAndType(Id contactId, Id tenancyId, Id reporterId, String caseType){
        Case caseRecord = buildMoneyCoachingCase(contactId);
        caseRecord.CaseType__c = caseType;
        caseRecord.Tenancy__c = tenancyId;
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildCustomerFeedbackCase(Id contactId){
        Case caseRecord = new Case(
            ContactId = contactId,
            RecordTypeId = CaseDecorator.RECORD_TYPE_ID_CUSTOMER_FEEDBACK,
            Status = CaseDecorator.STATUS_NEW,
            Type = CaseDecorator.TYPE_COMPLIMENT,
            OriginalReceivedDateTime__c = System.now(),
            Reporter__c = contactId
        );
        return caseRecord;
    }

    public static Case buildOmbudsmanFirstRequestForActionCase(Id contactId, Id accountId){
        Case caseRecord = build(contactId);
        caseRecord.AccountId = accountId;
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_OMBUDSMAN_FIRSTREQFORACTION;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.TYPE_OMBUDSMAN_FIRSTREQFORACTION;
        caseRecord.RecordType__c = 'OmbudsmanFirstRequestForAction';
        caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_OMBUDSMAN_FIRSTREQFORACTION;
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildTenancyCoachingCase(Id contactId){
        Case caseRecord = new Case(
            ContactId = contactId,
            RecordTypeId = CaseDecorator.RECORD_TYPE_ID_TENANCY_COACHING,
            Status = CaseDecorator.STATUS_NEW,
            Type = CaseDecorator.TYPE_COMPLAINT,
            OriginalReceivedDateTime__c = System.now(),
            Reporter__c = contactId
        );
        return caseRecord;
    }


    public static Case buildSchemeCase(Id contactId){
        Case caseRecord = new Case(
            ContactId = contactId,
            RecordTypeId = CaseDecorator.RECORD_TYPE_ID_SCHEMES,
            Status = CaseDecorator.STATUS_NEW,
            Type = CaseDecorator.TYPE_SCHEMES,
            OriginalReceivedDateTime__c = System.now(),
            Reporter__c = contactId
        );
        return caseRecord;
    }
    
    public static Case buildTenancyCase(Id contactId){
        Case caseRecord = build(contactId);
        caseRecord.ContactId = contactId;
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_TENANCY;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.TYPE_TENANCY;
        caseRecord.OriginalReceivedDateTime__c = System.now();
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildTenancyCase(Id contactId, Id propertyId){
        Case caseRecord = build(contactId);
        caseRecord.ContactId = contactId;
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_TENANCY;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.TYPE_TENANCY;
        caseRecord.OriginalReceivedDateTime__c = System.now();
        caseRecord.Reporter__c = contactId;
        caseRecord.Property__c = propertyId;
        return caseRecord;
    }

    public static Case buildTenancyCase(Id contactId, Id propertyId, String caseType){
        Case caseRecord = buildTenancyCase(contactId, propertyId);
        caseRecord.CaseType__c = caseType;
        return caseRecord;
    }

    public static Case buildTenancyCaseWithCaseType(Id contactId, String caseType){
        Case caseRecord = buildTenancyCase(contactId);
        caseRecord.CaseType__c = caseType;
        return caseRecord;
    }

    public static Case buildTenancyCaseWithTenancyAndReporter(Id contactId, Id tenancyId, Id reporterId){
        Case caseRecord = buildTenancyCase(contactId);
        caseRecord.Tenancy__c = tenancyId;
        caseRecord.Reporter__c = reporterId;
        return caseRecord;
    }

    public static Case buildTenancyCaseWithTenancyAndReporterAndType(Id contactId, Id tenancyId, Id reporterId, String caseType){
        Case caseRecord = buildTenancyCaseWithCaseType(contactId, caseType);
        caseRecord.Tenancy__c = tenancyId;
        caseRecord.Reporter__c = reporterId;
        return caseRecord;
    }

    public static Case buildSafeguardingCase(Id contactId){
        Case caseRecord = build(contactId);
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_SAFEGUARDING;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.TYPE_SAFEGUARING;
        caseRecord.CaseType__c = CaseDecorator.TYPE_SAFEGUARING;
        caseRecord.Reporter__c = contactId;
        caseRecord.ReporterType__c = CaseDecorator.REPORTER_TYPE_PERSONATRISK;
        return caseRecord;
    }

    public static Case buildSafeguardingCaseWithTenancyAndReporter(Id contactId, Id tenancyId, Id reporterId){
        Case caseRecord = buildSafeguardingCase(contactId);
        caseRecord.Tenancy__c = tenancyId;
        caseRecord.Reporter__c = reporterId;
        return caseRecord;
    }
    
    public static Case buildPlaceCase(Id contactId){
        Case caseRecord = build(contactId);
        caseRecord.ContactId = contactId;
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_PLACE;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.TYPE_PLACE;
        caseRecord.Reporter__c = contactId;
        caseRecord.OriginalReceivedDateTime__c = System.now();
        return caseRecord;
    }

    public static Case buildPlaceWithTypeCase(Id contactId, String caseType){
        Case caseRecord = buildPlaceCase(contactId);
        caseRecord.CaseType__c = caseType;
        return caseRecord;
    }

    public static Case buildPlaceWithCaseTypeTenancyAndReporter(Id contactId, Id tenancyId, Id reporterId, String caseType){
        Case caseRecord = buildPlaceWithTypeCase(contactId, caseType);
        caseRecord.Tenancy__c = tenancyId;
        caseRecord.Reporter__c = reporterId;
        return caseRecord;
    }

    public static Case buildFakeCaseWithType(Id fakeCaseId, Id contactId, Id ownerId, String caseType, String recordTypeId){
        Case caseRecord = build(contactId);
        caseRecord.Id = fakeCaseId;
        caseRecord.OwnerId = ownerId;
        caseRecord.RecordTypeId = recordTypeId;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.CaseType__c = caseType;
        caseRecord.Type = caseType;
        return caseRecord;
    }

    public static Case buildBreachAndASBCase(Id contactId){
        Case caseRecord = build(contactId);
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_BREACH_ASB;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_BREACH_AND_ANTISOCIAL;
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildBreachAndASBCaseWithTenancyAndReporter(Id contactId, Id tenancyId, Id reporterId){
        Case caseRecord = buildBreachAndASBCase(contactId);
        caseRecord.Tenancy__c = tenancyId;
        caseRecord.Reporter__c = reporterId;
        return caseRecord;
    }

    public static Case buildBreachAndASBCaseWithoutAccusedParty(Id tenancyId, Id reporterId){
        Case caseRecord = new Case();
        caseRecord.CaseFeatureSwitches__c = CaseDecorator.CASEFEATURE_NEW_MCC_FLOW;
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_BREACH_ASB;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_BREACH_AND_ANTISOCIAL;
        caseRecord.Tenancy__c = tenancyId;
        caseRecord.Reporter__c = reporterId;
        return caseRecord;
    }

    public static Case buildBreachAndASBCaseWithStatusClosed(Case caseRecord){
        caseRecord.OriginalReceivedDateTime__c = Datetime.now();
        caseRecord.CaseOutcome__c = CaseDecorator.CASE_OUTCOME_RESOLVED;
        caseRecord.Status = CaseDecorator.STATUS_STAGE_CLOSED;
        caseRecord.ClosureReason__c = 'Test';
        caseRecord.BreachOrASBIssuesResolved__c = CaseDecorator.BREACH_OR_ASB_ISSUES_RESOLVED;
        return caseRecord;
    }

    public static Case buildBreachASBCaseForCustomerPortal(String firstName, String lastName, String tenantAdressStreet, String tenantAdressCity, String tenantAddressPostalCode, Id contactId){
        Case caseRecord = new Case(
            CaseType__c = CaseDecorator.CASE_TYPE_BREACH_AND_ANTISOCIAL,
            RecordTypeId = CaseDecorator.RECORD_TYPE_ID_BREACH_ASB,
            Status = CaseDecorator.STATUS_NEW,
            Type = CaseDecorator.CASE_TYPE_BREACH_AND_ANTISOCIAL,
            SubStatus__c = '',
            Origin = CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL,
            FirstName__c = firstName,
            LastName__c = lastName,
            AccusedPartysAddress__Street__s = tenantAdressStreet,
            AccusedPartysAddress__city__s = tenantAdressCity,
            AccusedPartysAddress__Postalcode__s = tenantAddressPostalCode,
            Reporter__c = contactId
        );
        setRequiredFields(caseRecord);
        return caseRecord;
    }

    public static Case buildPermissionCase(Id contactId, Id tenancyId){
        Case caseRecord = build(contactId);
        caseRecord.ContactId = contactId;
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_PERMISSION;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.TYPE_PERMISSION;
        caseRecord.Tenancy__c = tenancyId;
        caseRecord.OriginalReceivedDateTime__c = System.now();
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildPermissionCaseWithCaseType(Id contactId, Id tenancyId, String caseType){
        Case caseRecord = buildPermissionCase(contactId, tenancyId);
        caseRecord.CaseType__c = caseType;
        return caseRecord;
    }

    public static Case buildPermissionCaseWithTypeAndTenancyAndReporter(Id contactId, Id tenancyId, Id reporterId, String caseType){
        Case caseRecord = buildPermissionCaseWithCaseType(contactId, tenancyId, caseType);
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildPermissionCaseWithSharingReason(Id contactId, Id tenancyId, String caseType, String reason){
        Case caseRecord = buildPermissionCaseWithCaseType(contactId, tenancyId, caseType);
        caseRecord.CustomerSharingReasons__c = reason;
        return caseRecord;
    }

    public static Case buildChangesCase(Id contactId){
        Case caseRecord = build(contactId);
        caseRecord.ContactId = contactId;
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_CHANGES;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.TYPE_CHANGES;
        caseRecord.OriginalReceivedDateTime__c = System.now();
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildChangesCase(Id contactId, String caseType, Id tenancyId){
        Case caseRecord = buildChangesCase(contactId);
        caseRecord.Tenancy__c = tenancyId;
        caseRecord.CaseType__c = caseType;
        return caseRecord;
    }

    public static Case buildChangesCaseWithTypeAndTenancyAndReporter(Id contactId, Id tenancyId, Id reporterId, String caseType){
        Case caseRecord = buildChangesCase(contactId, caseType, tenancyId);
        caseRecord.Reporter__c = reporterId;
        return caseRecord;
    }

    public static Case buildMutualExchangeCase(Id contactId){
        Case caseRecord = build(contactId);
        caseRecord.ContactId = contactId;
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_CHANGES;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.TYPE_CHANGES;
        caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_MUTUAL_EXCHANGE;
        caseRecord.OriginalReceivedDateTime__c = System.now();
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildMutualExchangeCaseWithTypeAndTenancyAndReporter(Id contactId, Id tenancyId, Id reporterId){
        Case caseRecord = buildMutualExchangeCase(contactId);
        caseRecord.Tenancy__c = tenancyId;
        caseRecord.Reporter__c = reporterId;
        return caseRecord;
    }

    public static Case buildSchemesCase(Id contactId){
        Case caseRecord = build(contactId);
        caseRecord.ContactId = contactId;
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_SCHEMES;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.TYPE_SCHEMES;
        caseRecord.CaseType__c = CaseDecorator.TYPE_INDEPENDENCE_PLAN;
        caseRecord.OriginalReceivedDateTime__c = System.now();
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildSchemesCaseWithType(Id contactId, String caseType){
        Case caseRecord = buildSchemesCase(contactId);
        caseRecord.CaseType__c = caseType;
        return caseRecord;
    }

    public static Case buildSchemesCaseWithTypeAndTenancyAndReporter(Id contactId, Id tenancyId, Id reporterId, String caseType){
        Case caseRecord = buildSchemesCaseWithType(contactId, caseType);
        caseRecord.Tenancy__c = tenancyId;
        caseRecord.Reporter__c = reporterId;
        return caseRecord;
    }

    public static Case buildJointToSoleCase(Id contactId){
        Case caseRecord = build(contactId);
        caseRecord.ContactId = contactId;
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_CHANGES;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.CASE_TYPE_JOINT_TO_SOLE;
        caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_JOINT_TO_SOLE;
        caseRecord.OriginalReceivedDateTime__c = System.now();
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildSoleToJointCase(Id contactId){
        Case caseRecord = build(contactId);
        caseRecord.ContactId = contactId;
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_CHANGES;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.CASE_TYPE_SOLE_TO_JOINT;
        caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_SOLE_TO_JOINT;
        caseRecord.OriginalReceivedDateTime__c = System.now();
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildJointToSoleCaseWithTenancyandReporter(Id contactId, Id tenancyId, Id reporterId){
        Case caseRecord = buildJointToSoleCase(contactId);
        caseRecord.Tenancy__c = tenancyId;
        caseRecord.Reporter__c = reporterId;
        return caseRecord;
    }

    public static Case buildDeathOfTenantSurvivor(Id contactId){
        Case caseRecord = build(contactId);
        caseRecord.ContactId = contactId;
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_CHANGES;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_SURVIVOR;
        caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_SURVIVOR;
        caseRecord.OriginalReceivedDateTime__c = System.now();
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildDeathOfTenantSurvivorWithTenancyAndReporter(Id contactId, Id tenancyId, Id reporterId){
        Case caseRecord = buildDeathOfTenantSurvivor(contactId);
        caseRecord.Tenancy__c = tenancyId;
        caseRecord.Reporter__c = reporterId;
        return caseRecord;
    }

    public static Case buildDeathOfTenantSuccessor(Id contactId){
        Case caseRecord = build(contactId);
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_CHANGES;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_SUCCESSOR;
        caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_SUCCESSOR;
        caseRecord.OriginalReceivedDateTime__c = System.now();
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildDeathOfTenantNoSuccessor(Id contactId){
        Case caseRecord = build(contactId);
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_CHANGES;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_NO_SUCCESSOR;
        caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_DEATH_OF_TENENT_NO_SUCCESSOR;
        caseRecord.OriginalReceivedDateTime__c = System.now();
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildAbandonedPropertiesCase(Id contactId){
        Case caseRecord = build(contactId);
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_TENANCY;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.Type = CaseDecorator.CASE_TYPE_ABANDONED_PROPERTIES;
        caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_ABANDONED_PROPERTIES;
        caseRecord.OriginalReceivedDateTime__c = System.now();
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildManagedMoveCase(Id contactId){
        Case caseRecord = build(contactId);
        caseRecord.ContactId = contactId;
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_MANAGED_MOVE;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.OriginalReceivedDateTime__c = System.now();
        caseRecord.Reporter__c = contactId;
        caseRecord.CaseType__c = CaseDecorator.CASE_TYPE_MANAGED_MOVE;
        return caseRecord;
    }

    public static Case buildManagedMoveCaseWithTenancyAndReporter(Id contactId, Id tenancyId, Id reporterId){
        Case caseRecord = buildManagedMoveCase(contactId);
        caseRecord.Tenancy__c = tenancyId;
        caseRecord.Reporter__c = reporterId;
        return caseRecord;
    }

    public static Case buildTerminationCase(Id contactId, Id tenancyId){
        Case caseRecord = new Case(
            ContactId = contactId,
            Tenancy__c = tenancyId,
            CaseType__c = CaseDecorator.TYPE_TERMINATION,
            RecordTypeId = CaseDecorator.RECORD_TYPE_ID_TERMINATION,
            Status = CaseDecorator.STATUS_NEW,
            Type = CaseDecorator.TYPE_LETTING_TERMINATION,
            SubStatus__c = ''
        );
        setRequiredFields(caseRecord);
        return caseRecord;
    }

    public static Case buildTerminationGuestPortalCase(){
        Case caseRecord = new Case(
            CaseType__c = CaseDecorator.TYPE_TERMINATION,
            RecordTypeId = CaseDecorator.RECORD_TYPE_ID_TERMINATION,
            Status = CaseDecorator.STATUS_NEW,
            Type = CaseDecorator.TYPE_LETTING_TERMINATION,
            Origin = CaseDecorator.CASE_ORIGIN_GUEST_PORTAL,
            TerminationNoticeReceived__c = System.today(),
            PrimaryReasonForLeaving__c = CaseDecorator.PRIMARY_REASON_FOR_LEAVING_NEEDSMALLHOME,
            SubStatus__c = ''
        );
        return caseRecord;
    }

    public static Case buildTerminationCustomerPortalCase(Id contactId, Id tenancyId, Id contactId2){
        Case caseRecord = buildTerminationCase(contactId, tenancyId);
        caseRecord.Origin = CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL;
        caseRecord.TerminationNoticeReceived__c = System.today();
        caseRecord.PrimaryReasonForLeaving__c = CaseDecorator.PRIMARY_REASON_FOR_LEAVING_NEEDSMALLHOME;
        caseRecord.SubStatus__c = '';
        caseRecord.Reporter__c = contactId2;
        return caseRecord;
    }

    public static Case buildTerminationCaseForSharing(Id contactId, Id tenancyId, String sharingReason){
        Case caseRecord = buildTerminationCase(contactId, tenancyId);
        caseRecord.CustomerSharingReasons__c = sharingReason;
        return caseRecord;
    }
    
    public static Case buildCustomerFeedbackCaseGuestPortal(){
        Case caseRecord = new Case(
            RecordTypeId = CaseDecorator.RECORD_TYPE_ID_CUSTOMER_FEEDBACK,
            Status = CaseDecorator.STATUS_NEW,
            Type = CaseDecorator.TYPE_COMPLIMENT,
            OriginalReceivedDateTime__c = System.now(),
            Origin = CaseDecorator.CASE_ORIGIN_GUEST_PORTAL
        );
        return caseRecord;
    }

    public static Case buildEmailResponseCase(Id contactId){
        Case caseRecord = build(contactId);
        caseRecord.RecordTypeId = CaseDecorator.RECORD_TYPE_ID_EMAILRESPONSE;
        caseRecord.Status = CaseDecorator.STATUS_NEW;
        caseRecord.OriginalReceivedDateTime__c = System.now();
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildGeneralEnquiryCase(Id contactId, Id tenancyId){
        Case caseRecord = new Case(
            ContactId = contactId,
            Tenancy__c = tenancyId,
            RecordTypeId = CaseDecorator.RECORD_TYPE_ID_GENERAL_ENQUIRY,
            Status = CaseDecorator.STATUS_NEW,
            Type = CaseDecorator.CASE_TYPE_DEVELOPMENT
        );
        setRequiredFields(caseRecord);
        return caseRecord;
    }

    public static Case buildGeneralEnquiryOriginPortalCase(Id contactId, Id tenancyId){
        Case caseRecord = buildGeneralEnquiryCase(contactId, tenancyId);
        caseRecord.Origin = CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL;
        return caseRecord;
    }

    public static Case buildAwaabsLawCase(Id contactId, Id tenancyId){
        Case caseRecord = new Case(
            ContactId = contactId,
            Tenancy__c = tenancyId,
            RecordTypeId = CaseDecorator.RECORD_TYPE_ID_AWAABSLAW,
            RecordType__c = CaseDecorator.RECORD_TYPE_AWAABSLAW,
            Status = CaseDecorator.STATUS_NEW,
            Priority = CaseDecorator.PRIORITY_SLIGHT,
            CaseType__c = CaseDecorator.CASE_TYPE_DAMP_AND_MOULD
        );
        return caseRecord;
    }

    public static Case buildAwaabsLawCase(Id contactId, Id tenancyId, DateTime InitialContactDateTime, String Priority, String EntitlementId){
        Case caseRecord = new Case(
            ContactId = contactId,
            Tenancy__c = tenancyId,
            RecordTypeId = CaseDecorator.RECORD_TYPE_ID_AWAABSLAW,
            RecordType__c = CaseDecorator.RECORD_TYPE_AWAABSLAW,
            Status = CaseDecorator.STATUS_NEW,
            CaseType__c = CaseDecorator.CASE_TYPE_DAMP_AND_MOULD,
            InitialContactDateTime__c = InitialContactDateTime,
            Priority = Priority,
            EntitlementId = EntitlementId
        );
        return caseRecord;
    }

    public static Case createAwaabsLawCase(Id contactId, Id tenancyId){
        Case acase = buildAwaabsLawCase(contactId, tenancyId);
        insert acase; 
        return acase;
    }

    public static Case buildAwaabsLawCaseWthOrcahrdJobNumber(Id contactId, Id tenancyId, String orchardNumber, String furtherWorks){
        Case caseRecord = new Case(
            ContactId = contactId,
            Tenancy__c = tenancyId,
            RecordTypeId = CaseDecorator.RECORD_TYPE_ID_AWAABSLAW,
            RecordType__c = CaseDecorator.RECORD_TYPE_AWAABSLAW,
            Status = CaseDecorator.STATUS_NEW,
            Priority = CaseDecorator.PRIORITY_SLIGHT,
            CaseType__c = CaseDecorator.CASE_TYPE_DAMP_AND_MOULD,
            FurtherWorksJobNumber__c = furtherWorks,
            OrchardJobNumber__c = orchardNumber

        );
        return caseRecord;
    }
    
    public static Case buildFake(Id fakeCaseId, Id contactId, Id ownerId){
        Case caseRecord = build(contactId);
        caseRecord.Id = fakeCaseId;
        caseRecord.OwnerId = ownerId;
        caseRecord.Reporter__c = contactId;
        return caseRecord;
    }

    public static Case buildTerminationCaseForGuestPortal(String firstName, String lastName, String jointFirstName, String jointLastName, String tenantAdressStreet, String tenantAdressCity, String tenantAddressPostalCode){
        Case caseRecord = new Case(
            CaseType__c = CaseDecorator.TYPE_TERMINATION,
            RecordTypeId = CaseDecorator.RECORD_TYPE_ID_TERMINATION,
            Status = CaseDecorator.STATUS_NEW,
            Type = CaseDecorator.TYPE_LETTING_TERMINATION,
            SubStatus__c = '',
            Origin = CaseDecorator.CASE_ORIGIN_GUEST_PORTAL,
            FirstName__c = firstName,
            LastName__c = lastName,
            FirstNameofJointTenant__c = jointFirstName,
            LastNameOfJointTenant__c = jointLastName,
            TenantsAddress__Street__s = tenantAdressStreet,
            TenantsAddress__city__s = tenantAdressCity,
            TenantsAddress__Postalcode__s = tenantAddressPostalCode
        );
        setRequiredFields(caseRecord);
        return caseRecord;
    }

    public static Case buildBreachASBCaseForGuestPortal(String firstName, String lastName, String tenantAdressStreet, String tenantAdressCity, String tenantAddressPostalCode){
        Case caseRecord = new Case(
            CaseType__c = CaseDecorator.CASE_TYPE_BREACH_AND_ANTISOCIAL,
            RecordTypeId = CaseDecorator.RECORD_TYPE_ID_BREACH_ASB,
            Status = CaseDecorator.STATUS_NEW,
            Type = CaseDecorator.CASE_TYPE_BREACH_AND_ANTISOCIAL,
            SubStatus__c = '',
            Origin = CaseDecorator.CASE_ORIGIN_GUEST_PORTAL,
            FirstName__c = firstName,
            LastName__c = lastName,
            AccusedPartysAddress__Street__s = tenantAdressStreet,
            AccusedPartysAddress__city__s = tenantAdressCity,
            AccusedPartysAddress__Postalcode__s = tenantAddressPostalCode
        );
        setRequiredFields(caseRecord);
        return caseRecord;
    }

     public static Case buildComplaintsForGuestPortal(String firstName, String lastName, String reporterAdrerepossStreet, String reporterAdrerepossCity, String reporterAdrerepossPostalCode){
        Case caseRecord = new Case(
            CaseType__c = CaseDecorator.TYPE_COMPLAINT,
            RecordTypeId = CaseDecorator.RECORD_TYPE_ID_COMPLAINTS,
            Status = CaseDecorator.STATUS_NEW,
            Type = CaseDecorator.TYPE_COMPLAINT,
            SubStatus__c = '',
            Origin = CaseDecorator.CASE_ORIGIN_GUEST_PORTAL,
            ReporterFirstName__c = firstName,
            ReporterSurname__c = lastName,
            ReporterAddress__Street__s = reporterAdrerepossStreet,
            ReporterAddress__City__s = reporterAdrerepossCity,
            ReporterAddress__Postalcode__s = reporterAdrerepossPostalCode
        );
        setRequiredFields(caseRecord);
        return caseRecord;
    }

    public static List<Case> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(Case.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM Case ' + 
			' ORDER BY Id'
		);
    }

    public static Case get(Id caseId){
        return Database.query('SELECT '+
			String.join(new List<String>(Case.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
                        //add more feilds from related object as and wehn required
			' FROM Case ' + 
            ' WHERE Id = \'' + caseId + '\'' +
			' ORDER BY Id'
		);
    }

    public static void setRequiredFields(Case caseRecord) {
        caseRecord.Stage1LessonsLearned__c = CaseDecorator.STAGE_ONE_LESSON_LEARNED_IMPROVE_CUSTOMER_COMMUNICATION;
        caseRecord.Stage2LessonsLearned__c = CaseDecorator.STAGE_TWO_COMPLAINT_LESSON_LEARNED_IMPROVE_CUSTOMER_COMMUNICATION;
        caseRecord.OmbudsmanLessonsLearned__c = CaseDecorator.OMBUDSMAN_LESSON_LEARNED_IMPROVE_CUSTOMER_COMMUNICATION;
        caseRecord.Stage1LessonsLearnedDetails__c = 'Test';
        caseRecord.Stage2LessonsLearnedDetails__c = 'Test';
        caseRecord.OmbudsmanLessonsLearnedDetails__c = 'Test';
        caseRecord.ReasonForEscalationToStage1__c = 'Test';
        caseRecord.DesiredOutcomeForStage1__c = 'Test';
        caseRecord.ReasonForEscalationToStage2__c = 'Test';
        caseRecord.DesiredOutcomeForStage2__c = 'Test';
        caseRecord.ReasonForEscalationToOmbudsman__c = 'Test';
        caseRecord.DesiredOutcomeForOmbudsman__c = 'Test';
        caseRecord.StageOmbudsmanRequestedDate__c = System.now();
        caseRecord.HOCaseReference__c = '1234343';
        caseRecord.EmailSubject__c = 'Test';
        caseRecord.OmbudsmanComplaintCategory__c = 'Enquiry';
        caseRecord.OmbudsmanDeadlineDate__c = System.today().addDays(10);
        // caseRecord.DateContactReceived__c = System.today();
        caseRecord.ReasonForContactingOmbudsman__c = 'Test';
        caseRecord.Stage1Decision__c = 'Test';
        caseRecord.Stage2Decision__c = 'Test';
    }
    public static void initializeComplaintInitialContactWithEscalatedOutcome(Case caseRecord, DateTime startDateTime){
        caseRecord.OriginalReceivedDateTime__c = startDateTime;
        caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_COMPLETED;
        caseRecord.InitialComplaintOutcome__c = CaseDecorator.INITIAL_COMPLAINT_OUTCOME_ESCALATED;
    }

    public static void assignComplaintStageOneCreateAndUpdatePermission() {
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_CREATE_STAGE1).Id;
        Id currentUserId = UserInfo.getUserId();
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_COMPLAINT_CASE_UPDATE_STAGE1).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
    }

    public static void createCaseShareRecords(Id caseId, Id currentUserId, String accessLevel,String rowCause){
        CaseShare cseShare= new CaseShare();
        cseShare.CaseId = caseId;
        cseShare.CaseAccessLevel= accessLevel;
        cseShare.UserOrGroupId = currentUserId;
        cseShare.RowCause= rowCause;
        Database.SaveResult sr = Database.insert(cseShare,false);
    }    

}