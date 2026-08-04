public with sharing class CaseDecorator {
    
    public static final String SOBJECT_TYPE_CASE = 'Case';
    public static final String RECORD_TYPE_AWAABSLAW = 'CaseAwaabsLawRT';
    public static final String RECORD_TYPE_COMPLAINTS = 'CaseComplaintsRT';
    public static final String RECORD_TYPE_SCHEMES = 'CaseSchemesRT';
    public static final String RECORD_TYPE_LETTINGS = 'CaseLettingRT';
    public static final String RECORD_TYPE_MONEY_COACHING = 'CaseMoneyCoachingRT';
    public static final String RECORD_TYPE_TENANCY_COACHING = 'CaseTenancyCoachingRT';
    public static final String RECORD_TYPE_OMBUDSMAN_FIRSTREQFORACTION = 'CaseOmbudsmanFirstRequestForActionRT';
    public static final String RECORD_TYPE_CUSTOMER_FEEDBACK = 'CustomerFeedbackRT';
    public static final String RECORD_TYPE_CUSTOMER = 'CustomerRT';
    public static final String RECORD_TYPE_SAFEGUARDING = 'CaseSafeguardingRT';
    public static final String RECORD_TYPE_PLACE = 'CasePlaceRT';
    public static final String RECORD_TYPE_BREACH = 'CaseBreachAntiSocialBehaviourRT';
    public static final String RECORD_TYPE_PERMISSION = 'CasePermissionRT';
    public static final String RECORD_TYPE_TENANCY = 'CaseTenancyRT';
    public static final String RECORD_TYPE_CHANGES = 'CaseChangesRT';
    public static final String RECORD_TYPE_MANAGED_MOVE = 'CaseManagedMoveRT';
    public static final String RECORD_TYPE_TERMINATION_MOVE = 'CaseTerminationRT';
    public static final String RECORD_TYPE_GENERAL_ENQUIRY = 'CaseGeneralEnquiryRT';
    public static final String PRIORITY_HIGH = 'High';
    public static final String PRIORITY_LOW = 'Low';
    public static final String TYPE_COMPLAINT = 'Complaint';
    public static final String TYPE_SUGGESTION = 'Suggestion';
    public static final String TYPE_CUSTOMER = 'Customer';
    public static final String TYPE_LETTING_TERMINATION = 'Letting - Termination';
    public static final String TYPE_COMPLIMENT = 'Compliment';
    public static final String TYPE_SAFEGUARING = 'Safeguarding';
    public static final String TYPE_TENANCY = 'Tenancy';
    public static final String STATUS_NEW = 'New';
    public static final String STATUS_IN_PROGRESS = 'In progress';
    public static final String STATUS_PRE_CASE_CLOSURE = 'Pre Case Closure';
    public static final String STATUS_COMPLETE_CASE = 'Complete case';
    public static final String TYPE_LETTING = 'Letting';
    public static final String TYPE_SCHEMES = 'Schemes';
    public static final String TYPE_PLACE = 'Place';
    public static final String TYPE_ABANDONED_GOODS = 'Abandoned goods';	
    public static final String TYPE_ABANDONED_PROPERTIES = 'Abandoned properties';
    public static final String TYPE_RIGHT_To_RENT = 'Right to rent';
    public static final String TYPE_PERMISSION = 'Permission';
    public static final String TYPE_CHANGES = 'Changes';
    public static final String CASE_TYPE_MONEY_COACHING = 'Money Coaching';
    public static final String CASE_TYPE_TENANCY_COACHING = 'Tenancy Coaching';
    public static final String TYPE_OMBUDSMAN_FIRSTREQFORACTION = 'Ombudsman - First Request for Action';
    public static final String TYPE_MONITORING_FORM = 'Monitoring Form';
    public static final String TYPE_INDEPENDENCE_PLAN = 'Independence Plan';
    public static final String TYPE_CHANGE_CUSTOMER_DETAILS = 'Change of Customer Details';
    public static final String STATUS_STAGE_CLOSED = 'Closed';
    public static final String STATUS_STAGE_ONE = 'Stage 1';
    public static final String STATUS_STAGE_TWO = 'Stage 2';
    public static final String ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE = 'Stage 1';
    public static final String ACKNOWLEDGEMENT_SENT_FOR_STAGE_TWO = 'Stage 2';
    public static final String STATUS_STAGE_OMBUDSMAN = 'Ombudsman';
    public static final String STATUS_INITIAL_COMPLAINT = 'Initial Contact';
    public static final String STATUS_ADMINISTRATION = 'Administration';
    public static final String STATUS_AWAITING_DOCUMENTATION = 'Awaiting Documentation';

    public static final String EXTERNAL_STATUS_INPROGRESS = 'In Progress';
    public static final String EXTERNAL_STATUS_CLOSED = 'Closed';
    public static final String STATUS_EMAIL_RESPONSE_RECEIVED = 'E-Mail Response Received';
    public static final String SUB_STATUS_NEW = 'New';
    public static final String SUB_STATUS_IN_PROGRESS = 'In Progress';
    public static final String SUB_STATUS_COMPLETED = 'Completed';
    public static final String SUB_STATUS_ON_HOLD = 'On Hold';
    public static final String SUB_STATUS_REVIEW = 'Review';
    public static final String INITIAL_COMPLAINT_LESSON_LEARNED_IMPROVE_CUSTOMER_COMMUNICATION = 'Improve customer communication';
    public static final String STAGE_ONE_LESSON_LEARNED_IMPROVE_CUSTOMER_COMMUNICATION = 'Improve customer communication';
    public static final String STAGE_TWO_COMPLAINT_LESSON_LEARNED_IMPROVE_CUSTOMER_COMMUNICATION = 'Improve customer communication';
    public static final String OMBUDSMAN_LESSON_LEARNED_IMPROVE_CUSTOMER_COMMUNICATION = 'Improve customer communication';
    public static final Integer COMPLAINTS_CASE_INITIAL_STAGE_SLA_BASELINE_HOUR = 13;
    public static final Integer COMPLAINTS_CASE_STAGE_ONE_ON_HOLD_MAX_DAYS = 10;
    public static final Integer COMPLAINTS_CASE_STAGE_TWO_ON_HOLD_MAX_DAYS = 20;
    public static final Integer MONEY_COACHING_CASE_HIGH_PRIORITY_DAYS = 3;
    public static final Integer MONEY_COACHING_CASE_LOW_PRIORITY_DAYS = 30;
    public static final String CASE_TYPE_LETTING = 'Letting';
    public static final String CUSTOMER_EXPERIENCE_QUEUE = 'Customer_Experience_Centre';
    public static final String CASE_TYPE_OMBUDSMAN_FIRSTREQFORACTION = 'Ombudsman - First Request for Action';
    public static final String SUBJECT_MONITORING_FORM = 'Monitoring Form';
    public static final String SUBJECT_INDEPENDENCE_PLAN = 'Independence Plan';
    public static final String INITIAL_COMPLAINT_OUTCOME_ESCALATED = 'Escalated';
    public static final String PRIORITY_CHANGE_REASON_TIME_SPENT_ON_WAITING_LIST = 'Time spent on waiting list';  
    public static final String STATUS_TRIAGE = 'Triage';
    public static final Integer TENANCY_COACHING_CASE_URGENT_PRIORITY_DAYS = 1; 
    public static final Integer TENANCY_COACHING_CASE_ROUTINE_PRIORITY_DAYS = 5;
    public static final Integer TENANCY_COACHING_CASE_RESOLUTION_DAYS = 80;
    public static final String PRIORITY_URGENT = 'Urgent';
    public static final String PRIORITY_ROUTINE = 'Routine';
    public static final String COMPLAINT_STAGE_ONE_QUEUE = 'Complaint_Handler_Stage_One';
    public static final String COMPLAINT_STAGE_TWO_QUEUE = 'Complaint_Handler_Stage_Two';
    public static final String CASE_TYPE_SOLE_TO_JOINT = 'Sole to joint';
    public static final String CASE_OUTCOME_APPROVED = 'Approved';
    public static final String CASE_OUTCOME_COMPLETED = 'Completed';
    public static final String CASE_OUTCOME_ABANDONED = 'Abandoned';
    public static final String CASE_OUTCOME_RESOLVED = 'Resolved';
    public static final String BREACH_OR_ASB_ISSUES_RESOLVED = 'All Issues Resolved';
    public static final String CASE_OUTCOME_REFUSED = 'Refused';
    public static final String BREACH_ASB_ISSUE_CRIMINAL_DAMAGE = 'Criminal Damage';
    public static final String CASE_OUTCOME_TENANCY_ENDED = 'Tenancy Ended'; 
    public static final String CASE_TYPE_POWER_OF_ATTORNEY_NEW = 'Power of Attorney new';
    public static final String CASE_TYPE_DELEGATED_AUTHORITY_NEW = 'Delegated Authority New';
    public static final String CASE_TYPE_POWER_OF_ATTORNEY_REMOVE = 'Power of Attorney remove';
    public static final String CASE_TYPE_DELEGATED_AUTHORITY_REMOVE = 'Delegated Authority Remove';
    public static final String CASE_TYPE_JOINT_TO_SOLE = 'Joint to sole';
    public static final String CASE_TYPE_DEATH_OF_TENENT_NO_SUCCESSOR = 'Death of a tenant (no successor)';
    public static final String CASE_TYPE_DEATH_OF_TENENT_SUCCESSOR = 'Death of a tenant (successor)';
    public static final String CASE_TYPE_DEATH_OF_TENENT_SURVIVOR = 'Death of a tenant (survivor)';
    public static final String YES = 'Yes';
    public static final String NO = 'No';
    public static final String REPORTER_TYPE_PERSONATRISK = 'Person at Risk';
    public static final String CASE_OUTCOME_RESOLVEDATFIRSTPOINTOFCONTACT = 'Resolved at first point of contact';
    public static final Integer PLACE_CASE_URGENT_PRIORITY_DAYS = 1;
    public static final String CASE_TYPE_PLACE = 'Place';
    public static final String CASE_TYPE_ABANDONED_VEHICLES = 'Abandoned vehicles';
    public static final String CASE_TYPE_ABANDONED_PROPERTIES = 'Abandoned properties';
    public static final String CASE_TYPE_ABANDONED_GOODS = 'Abandoned goods';
    public static final String CASE_TYPE_MANAGED_MOVE = 'Managed Move';

    public static final String CASE_TYPE_MUTUAL_EXCHANGE = 'Mutual Exchange';
    public static final Integer CASE_MUTUALEXCHANGE_RESOLUTION_DAYS = 80;
    public static final Integer TENANCY_ABANDONED_GOODS_CASE_SLA_DAYS = 20;
    public static final Integer TENANCY_ABANDONED_PROPERTY_CASE_SLA_DAYS = 60;
    public static final Integer TENANCY_RIGHT_TO_RENT_CASE_SLA_DAYS = 30;
    public static final String TENANCY_DECANT_CASE_TYPE_TEMPORARY = 'Temporary';
    public static final String TENANCY_DECANT_CASE_TYPE_PERMANENT = 'Permanent';
    public static final Integer TENANCY_FIRSTCONTACT_TEMPORARY_DECANT_CASE_SLA_DAYS = 1;
    public static final Integer TENANCY_FIRSTCONTACT_CASE_SLA_DAYS = 5;
    public static final String ORIGIN_SYSTEM = 'System';
    public static final String CASE_INITIAL_CONTACT_SERVICE_RECOVERED = 'Service Recovered';
    public static final String CASE_TYPE_LAND_DISPUTES = 'Land disputes';
    public static final Integer PLACE_ABANDONED_VEHICLES_CASE_SLA_DAYS = 60;
    public static final Integer PLACE_LAND_DISPUTES_CASE_SLA_DAYS = 40;
    public static final String CASE_TYPE_BREACH_AND_ANTISOCIAL = 'Breach & Anti-social';
    public static final String RECORD_TYPE_TERMINATION = 'CaseTerminationRT';
    public static final String TYPE_TERMINATION = 'Termination';
    public static final String PRIORITY_SLIGHT = 'Slight';
    
    public static final String CASE_TYPE_DAMP_AND_MOULD = '01: Damp and mould growth';
    public static final String CASE_TYPE_PERMISSION_FOR_A_LoDGER_OR_SUBLET = 'Permission for a lodger or sublet';
    public static final String CASE_TYPE_PERMISSION_FOR_CARAVAN_MOTORHOME_BOAT = 'Permission for caravan, motorhome, boat';
    public static final String CASE_TYPE_PERMISSION_FOR_MOBILITY_SCOOTER = 'Permission for mobility scooter';
    public static final String CASE_TYPE_PERMISSION_FOR_PET_ANIMAL = 'Permission for pet/animal';
    public static final String CASE_TYPE_PERMISSION_TO_RUN_A_BUSINESS_FROM_HOME = 'Permission to run a business from home';
    public static final Integer PERMISSION_CASE_RESOLUTION_DAYS = 20;
    public static final Integer RESOLUTION_20_DAYS = 20;
    public static final Integer RESOLUTION_40_DAYS = 40;
    public static final Integer CUSTOMER_CONTACT_5_DAYS = 5;
    public static final Integer CUSTOMER_CONTACT_10_DAYS = 10;
    public static final String CASE_TYPE_UNAUTHORISED_OCCUPIER = 'Unauthorised occupier';
    public static final String CASE_TYPE_PERMISSION_DISABLED_PARKING = 'Request for a disabled parking bay';
    public static final Integer DISABLED_PARKING_PERMISSION_CASE_60_RESOLUTION_DAYS = 60;
    public static final Integer TENANCY_CASE_60_RESOLUTION_DAYS = 60;
    public static final String CASE_RECORDTYPE_TENANCYRT = 'TenancyRT';
    public static final String CASEFEATURE_NEW_MCC_FLOW = 'Created via new MCC Flow';
    public static final Integer CASE_MUTUALEXCHANGE_DECISION_DAYS = 42;
    public static final String CASE_REOPEN_REASON_BREACH_RESUMED = 'Breach & Anti Social Behaviour has resumed';
    public static final String CASE_OUTCOME_DEFER = 'Defer';
    public static final String CASE_OUTCOME_EXTEND = 'Extend';
    public static final String CASETYPE_STARTERTENANCY12MONTHREVIEW = 'Starter Tenancy 12 month review (at 9 months)';
    public static final String CASETYPE_STARTERTENANCY18MONTHREVIEW = 'Starter Tenancy 18 month review (at 15 months)';
    public static final String CASE_OUTCOME_CONSENT_NOT_GIVE = 'Customer refused to give consent';
    public static final String CASETYPE_DECANT = 'Decant';
    public static final String PRIMARY_REASON_FOR_LEAVING_NEEDSMALLHOME = 'Need a smaller home';
    public static final String RECORD_TYPE_EMAILRESPONSE = 'CaseEmailResponseRT';
    public static final String CASE_CLOSURE_REASON = 'No Customer Response';
    public static final String CASE_CLOSURE_REASON_TENANCY_ENDED = 'Tenancy Ended';
    public static final String CASE_OUTCOME_SYSTEM_AUTOMATED_CLOSURE = 'System Automated Closure';
    public static final String STATUS_AWAITING_INFORMATION = 'Awaiting Information';
    public static final String CASE_GENERAL_ENQUIRY_OWNER_FEED_MSG = 'Case Re-assignment Reason : ';
    public static final String CASE_TYPE_DEVELOPMENT = 'Development';
    public static final Integer EMAIL_CASE_ENTITLEMENT_DAYS = 2;
    public static final String CASE_TYPE_CUSTOMER_EXPERIENCE_CENTRE = 'Customer Experience Centre';
    public static final String CASE_ORIGIN_EMAIL_CEC = 'Email - CEC';
    public static final String CASE_ORIGIN_EMAIL_WEBREPAIRS = 'Email - Customer Services';
    public static final String CASE_ORIGIN_EMAIL_CUSTOMERSERVICES = 'Email - Web Repairs';
    public static final String CASE_ORIGIN_OPERATIVE_REPAIRS = 'Operative Repairs';
    public static final String CASE_STAGE_EMAILRESPONSERECIEVED = 'E-Mail Response Received';
    public static final String CASE_TYPE_EMAILRESPONSE = 'Email Response';
    public static final String CASE_OUTCOME_CONVERT = 'Convert';
    public static final String CASEFEATURE_CREATED_BY_SCHEDULED_FLOW = 'Created via scheduled automated flow';
    public static final String CASE_OUTCOME_CLOSED_WITH_DISPUTE = 'Closed with Dispute';
    public static final String CASE_AWAABS_LAW_EDIT_ERROR_AFTER_CLOSURE = 'Only Orchard Job Number, Further Works Job Number can be changed once the case is closed';
    public static final String CASE_AWAABS_LAW_EDIT_ERROR_AFTER_CLOSURE_TL = 'Only certain fields can be changed once the case is closed';
    public static final String CASE_STATUS_AWAAB_ACTION = 'Action';
    public static final String REASONPRIORITYCHANGE_INACCURATE_INFORMATION_PROVIDED = 'Inaccurate information provided during triage	';	
    public static final String PRIORITY_EMERGENCY = 'Emergency';
    public static final String PRIORITY_SIGNIFICANT = 'Significant';
    public static final String CASESHARINGREASON_TENANT = 'Tenant';
    public static final String CASESHARINGREASON_ACCUSEDPARTY = 'Accused Party';
    public static final String CASE_ORIGIN_CUSTOMER_PORTAL = 'Customer Portal';
    public static final String CASE_ORIGIN_GUEST_PORTAL = 'Guest Portal';
    public static final String FIELD_CONTACT = 'ContactId';
    public static final String FIELD_REPORTER = 'Reporter__c';
    public static final String FIELD_TENANCY = 'Tenancy__c';
    public static final String CASE_TYPE_GAS_REPAIR = 'Gas Repair';
    public static final String CASE_CUSTOMER_TYPE_OUTSTANDING_REPAIR = 'An outstanding repair';
    public static final String CASE_CUSTOMER_INQUIRY_CHANGE_TIME = 'I want to change my appointment date or time';
    public static final String CASE_CUSTOMER_INQUIRY_NO_LONGER_NEED = 'I no longer need this repair';
    public static final String CASE_TYPE_BUILDING_ELECTRICAL = 'Building Services and Electrical';
    public static final String CASE_INQUIRY_APPOINTMENT_AMENDMENT = 'Appointment Amendment';
    public static final String CASE_INQUIRY_CANCELLED = 'Cancelled Appointment';
    public static final String CASE_MILESTONE_BREACH_CUSTOMER_AVAILABILITY = 'Customer availability';
    public static final String CASE_PRIORITY_CHANGE_REASSESSED = 'Reassessed by DMC team';
    public static final String CASE_FIELD_ORCHARD_JOBNUMBER = 'OrchardJobNumber__c';
    public static final String CASE_FIELD_FURTHERWORKS_JOBNUMBER = 'FurtherWorksJobNumber__c';
    public static final String CASE_CATEGORY_BREACH_ASB = 'Breach & ASB';
    public static final String CASE_CATEGORY_BREACH = 'Breach';
    public static final String CASE_CATEGORY_ASB = 'ASB';
    public static final String CASE_ISSUE_TYPE_ARSON = 'Arson';
    public static final String CASE_ISSUE_TYPE_NO_ACCESS = 'No Access';



    
    public static final Id RECORD_TYPE_ID_COMPLAINTS{
        get{
            if (RECORD_TYPE_ID_COMPLAINTS == null) {
                RECORD_TYPE_ID_COMPLAINTS = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_COMPLAINTS);
            }
            return RECORD_TYPE_ID_COMPLAINTS;
        }
        set;
    }

    public static final Id RECORD_TYPE_ID_SCHEMES{
        get{
            if (RECORD_TYPE_ID_SCHEMES == null) {
                RECORD_TYPE_ID_SCHEMES = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_SCHEMES);
            }
            return RECORD_TYPE_ID_SCHEMES;
        }
        set;
    }

    public static final Id RECORD_TYPE_ID_LETTINGS{
        get{
            if (RECORD_TYPE_ID_LETTINGS == null) {
                RECORD_TYPE_ID_LETTINGS = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_LETTINGS);
            }
            return RECORD_TYPE_ID_LETTINGS;
        }
        set;
    }

    public static final Id RECORD_TYPE_ID_MONEY_COACHING{
        get{
            if (RECORD_TYPE_ID_MONEY_COACHING == null) {
                RECORD_TYPE_ID_MONEY_COACHING = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_MONEY_COACHING);
            }
            return RECORD_TYPE_ID_MONEY_COACHING;
        }
        set;
    }

    public static final Id RECORD_TYPE_ID_TENANCY_COACHING{
        get{
            if (RECORD_TYPE_ID_TENANCY_COACHING == null) {
                RECORD_TYPE_ID_TENANCY_COACHING = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_TENANCY_COACHING);
            }
            return RECORD_TYPE_ID_TENANCY_COACHING;
        }
        set;
    }

    
    public static final Id RECORD_TYPE_ID_OMBUDSMAN_FIRSTREQFORACTION{
        get{
            if (RECORD_TYPE_ID_OMBUDSMAN_FIRSTREQFORACTION == null) {
                RECORD_TYPE_ID_OMBUDSMAN_FIRSTREQFORACTION = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_OMBUDSMAN_FIRSTREQFORACTION);
            }
            return RECORD_TYPE_ID_OMBUDSMAN_FIRSTREQFORACTION;
        }
        set;
    }

    public static final Id RECORD_TYPE_ID_CUSTOMER{
        get{
            if (RECORD_TYPE_ID_CUSTOMER == null) {
                RECORD_TYPE_ID_CUSTOMER = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_CUSTOMER);
            }
            return RECORD_TYPE_ID_CUSTOMER;
        }
        set;
    }
    
    public static final Id RECORD_TYPE_ID_CUSTOMER_FEEDBACK{
        get{
            if (RECORD_TYPE_ID_CUSTOMER_FEEDBACK == null) {
                RECORD_TYPE_ID_CUSTOMER_FEEDBACK = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_CUSTOMER_FEEDBACK);
            }
            return RECORD_TYPE_ID_CUSTOMER_FEEDBACK;
        }
        set;
    }

    public static final Id RECORD_TYPE_ID_SAFEGUARDING{
        get{
            if (RECORD_TYPE_ID_SAFEGUARDING == null) {
                RECORD_TYPE_ID_SAFEGUARDING = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_SAFEGUARDING);
            }
            return RECORD_TYPE_ID_SAFEGUARDING;
        }
        set;
    }
    public static final Id RECORD_TYPE_ID_TENANCY{
        get{
            if (RECORD_TYPE_ID_TENANCY == null) {
                RECORD_TYPE_ID_TENANCY = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_TENANCY);
            }
            return RECORD_TYPE_ID_TENANCY;
        }
        set;
    }

    public static final Id RECORD_TYPE_ID_PLACE{
        get{
            if (RECORD_TYPE_ID_PLACE == null) {
                RECORD_TYPE_ID_PLACE = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_PLACE);
            }
            return RECORD_TYPE_ID_PLACE;
        }
        set;
    }

    public static final Id RECORD_TYPE_ID_BREACH_ASB{
        get{
            if (RECORD_TYPE_ID_BREACH_ASB == null) {
                RECORD_TYPE_ID_BREACH_ASB = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_BREACH);
            }
            return RECORD_TYPE_ID_BREACH_ASB;
        }
        set;
    }
    
    public static final Id RECORD_TYPE_ID_PERMISSION{
        get{
            if (RECORD_TYPE_ID_PERMISSION == null) {
                RECORD_TYPE_ID_PERMISSION = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_PERMISSION);
            }
            return RECORD_TYPE_ID_PERMISSION;
        }
        set;
    }

    public static final Id RECORD_TYPE_ID_CHANGES{
        get{
            if (RECORD_TYPE_ID_CHANGES == null) {
                RECORD_TYPE_ID_CHANGES = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_CHANGES);
            }
            return RECORD_TYPE_ID_CHANGES;
        }
        set;
    }

    public static final Id RECORD_TYPE_ID_MANAGED_MOVE {
        get{
            if (RECORD_TYPE_ID_MANAGED_MOVE == null) {
                RECORD_TYPE_ID_MANAGED_MOVE = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_MANAGED_MOVE);
            }
            return RECORD_TYPE_ID_MANAGED_MOVE;
        }
        set;
    }
    
    public static final Id RECORD_TYPE_ID_TERMINATION {
        get{
            if (RECORD_TYPE_ID_TERMINATION == null) {
                RECORD_TYPE_ID_TERMINATION = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_TERMINATION_MOVE);
            }
            return RECORD_TYPE_ID_TERMINATION;
        }
        set;
    }

    public static final Id RECORD_TYPE_ID_GENERAL_ENQUIRY {
        get{
            if (RECORD_TYPE_ID_GENERAL_ENQUIRY == null) {
                RECORD_TYPE_ID_GENERAL_ENQUIRY = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_GENERAL_ENQUIRY);
            }
            return RECORD_TYPE_ID_GENERAL_ENQUIRY;
        }
        set;
    }

    public static final Id RECORD_TYPE_ID_EMAILRESPONSE {
        get{
            if (RECORD_TYPE_ID_EMAILRESPONSE == null) {
                RECORD_TYPE_ID_EMAILRESPONSE = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_EMAILRESPONSE);
            }
            return RECORD_TYPE_ID_EMAILRESPONSE;
        }
        set;
    }

    public static final Id RECORD_TYPE_ID_AWAABSLAW {
        get{
            if (RECORD_TYPE_ID_AWAABSLAW == null) {
                RECORD_TYPE_ID_AWAABSLAW = RecordTypeUtility.getRecordTypeIdByDeveloperName(SOBJECT_TYPE_CASE, RECORD_TYPE_AWAABSLAW);
            }
            return RECORD_TYPE_ID_AWAABSLAW;
        }
        set;
    }

    public static String FIRST_NAME_FIELD{
        get{
            if(FIRST_NAME_FIELD == null){
                FIRST_NAME_FIELD = Case.FirstName__c.getDescribe().getName();
            }
            return FIRST_NAME_FIELD;
        }
        set;
    }

    public static String LAST_NAME_FIELD{
        get{
            if(LAST_NAME_FIELD == null){
                LAST_NAME_FIELD = Case.LastName__c.getDescribe().getName();
            }
            return LAST_NAME_FIELD;
        }
        set;
    }
     public static String REPORTER_FIRST_NAME_FIELD{
        get{
            if(REPORTER_FIRST_NAME_FIELD == null){
                REPORTER_FIRST_NAME_FIELD = Case.ReporterFirstName__c.getDescribe().getName();
            }
            return REPORTER_FIRST_NAME_FIELD;
        }
        set;
    }

    public static String REPORTER_LAST_NAME_FIELD{
        get{
            if(REPORTER_LAST_NAME_FIELD == null){
                REPORTER_LAST_NAME_FIELD = Case.ReporterSurname__c.getDescribe().getName();
            }
            return REPORTER_LAST_NAME_FIELD;
        }
        set;
    }


    public static String TENANT_ADDRESS_STREET_FIELD{
        get{
            if(TENANT_ADDRESS_STREET_FIELD == null){
                TENANT_ADDRESS_STREET_FIELD = Case.TenantsAddress__Street__s.getDescribe().getName();
            }
            return TENANT_ADDRESS_STREET_FIELD;
        }
        set;
    }

    public static String TENANT_ADDRESS_CITY_FIELD{
        get{
            if(TENANT_ADDRESS_CITY_FIELD == null){
                TENANT_ADDRESS_CITY_FIELD = Case.TenantsAddress__City__s.getDescribe().getName();
            }
            return TENANT_ADDRESS_CITY_FIELD;
        }
        set;
    }

    public static String TENANT_ADDRESS_POSTALCODE_FIELD{
        get{
            if(TENANT_ADDRESS_POSTALCODE_FIELD == null){
                TENANT_ADDRESS_POSTALCODE_FIELD = Case.TenantsAddress__Postalcode__s.getDescribe().getName();
            }
            return TENANT_ADDRESS_POSTALCODE_FIELD;
        }
        set;
    }

    public static String REPORTER_ADDRESS_STREET_FIELD{
        get{
            if(REPORTER_ADDRESS_STREET_FIELD == null){
                REPORTER_ADDRESS_STREET_FIELD = Case.ReporterAddress__Street__s.getDescribe().getName();
            }
            return REPORTER_ADDRESS_STREET_FIELD;
        }
        set;
    }

    public static String REPORTER_ADDRESS_CITY_FIELD{
        get{
            if(REPORTER_ADDRESS_CITY_FIELD == null){
                REPORTER_ADDRESS_CITY_FIELD = Case.ReporterAddress__City__s.getDescribe().getName();
            }
            return REPORTER_ADDRESS_CITY_FIELD;
        }
        set;
    }

    public static String REPORTER_ADDRESS_POSTALCODE_FIELD{
        get{
            if(REPORTER_ADDRESS_POSTALCODE_FIELD == null){
                REPORTER_ADDRESS_POSTALCODE_FIELD = Case.ReporterAddress__Postalcode__s.getDescribe().getName();
            }
            return REPORTER_ADDRESS_POSTALCODE_FIELD;
        }
        set;
    }

    public static String ACCUSED_ADDRESS_STREET_FIELD{
        get{
            if(ACCUSED_ADDRESS_STREET_FIELD == null){
                ACCUSED_ADDRESS_STREET_FIELD = Case.AccusedPartysAddress__Street__s.getDescribe().getName();
            }
            return ACCUSED_ADDRESS_STREET_FIELD;
        }
        set;
    }

    public static String ACCUSED_ADDRESS_CITY_FIELD{
        get{
            if(ACCUSED_ADDRESS_CITY_FIELD == null){
                ACCUSED_ADDRESS_CITY_FIELD = Case.AccusedPartysAddress__City__s.getDescribe().getName();
            }
            return ACCUSED_ADDRESS_CITY_FIELD;
        }
        set;
    }

    public static String ACCUSED_ADDRESS_POSTALCODE_FIELD{
        get{
            if(ACCUSED_ADDRESS_POSTALCODE_FIELD == null){
                ACCUSED_ADDRESS_POSTALCODE_FIELD = Case.AccusedPartysAddress__Postalcode__s.getDescribe().getName();
            }
            return ACCUSED_ADDRESS_POSTALCODE_FIELD;
        }
        set;
    }

    public static Set<String> CASE_AWAABS_EDIT_TL_ALLOWED{
        get{
            if(CASE_AWAABS_EDIT_TL_ALLOWED == null){
                CASE_AWAABS_EDIT_TL_ALLOWED = new Set<String>{'Priority', 'PriorityChangeReason__c', 'ReasonforMilestoneBreach__c', 'DatetimeInspectionCompleted__c', 'DateandTimeEmergencyWorkStarted__c', 'DateReportSentToCustomer__c', 'OrchardJobNumber__c', 'FurtherWorksJobNumber__c', 'FurtherWorksRequired__c', 'DateSafetyWorksCompleted__c',
                                        'DateRepairBookedWithCustomer__c'};
            }
            return CASE_AWAABS_EDIT_TL_ALLOWED;
        }
        set;
    }

    public static Set<String> CASE_AWAABS_EDIT_TL_IGNORE_FOMRULA{
        get{
            if(CASE_AWAABS_EDIT_TL_IGNORE_FOMRULA == null){
                CASE_AWAABS_EDIT_TL_IGNORE_FOMRULA = new Set<String>{'ALInspectionDoneIn3WDs__c', 'ALInspectionCompleted__c', 'LastModifiedDate', 'SystemModstamp'};
            }
            return CASE_AWAABS_EDIT_TL_IGNORE_FOMRULA;
        }
        set;
    }

}