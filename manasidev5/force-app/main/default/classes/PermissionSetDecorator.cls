public with sharing class PermissionSetDecorator {
    public static final String PS_CAN_UPDATE_COMPLAINT_CASE_STAGE1 = 'CanUpdateComplaintsCaseAtStage1PS';
    public static final String PS_CAN_CREATE_COMPLAINT_CASE_STAGE1 = 'CanCreateComplaintsCaseAtStage1PS';
    public static final String PS_CAN_UPDATE_COMPLAINT_CASE_STAGE2 = 'CanUpdateComplaintsCaseAtStage2PS';
    public static final String PS_CAN_CREATE_COMPLAINT_CASE_STAGE2 = 'CanCreateComplaintsCaseAtStage2PS';
    public static final String PS_CAN_UPDATE_COMPLAINT_CASE_OMBUDSMAN = 'CanUpdateComplaintsCaseAtOmbudsmanPS';
    public static final String PS_CAN_CREATE_COMPLAINT_CASE_OMBUDSMAN = 'CanCreateComplaintsCaseAtOmbudsmanPS';
    public static final String PS_CAN_CREATE_LETTINGS_CASE = 'CanCreateLettingsCasePS';
    public static final String PS_CAN_UPDATE_LETTINGS_CASE = 'CanUpdateLettingsCasePS';
    public static final String PS_CAN_CREATE_MONEY_COACHING_CASE = 'CanCreateMoneyCoachingCasePS';
    public static final String PS_CAN_UPDATE_MONEY_COACHING_CASE = 'CanUpdateMoneyCoachingCasePS';
    public static final String PS_CAN_CREATE_TENANCY_COACHING_CASE = 'CanCreateTenancyCoachingCasePS';
    public static final String PS_CAN_UPDATE_TENANCY_COACHING_CASE = 'CanUpdateTenancyCoachingCasePS';
    public static final String PS_CAN_CREATE_OMBUDSMAN_FIRSTREQACTION_CASE = 'CanCreateOmbudsmanFirstReqActionCasePS';
    public static final String PS_CAN_UPDATE_OMBUDSMAN_FIRSTREQACTION_CASE = 'CanUpdateOmbudsmanFirstReqActionCasePS';
    public static final String PS_CAN_CREATE_CUSTOMER_FEEDBACK_CASE = 'CanCreateCustomerFeedbackCasePS';
    public static final String PS_CAN_UPDATE_CUSTOMER_FEEDBACK_CASE = 'CanUpdateCustomerFeedbackCasePS';
    public static final String PSG_INCOME_MONEY_COACH_USER = 'IncomeMoneyCoachPSG';
    public static final String PS_CAN_CREATE_CEC_CASE = 'CanCreateCECCasePS';
    public static final String PS_CAN_UPDATE_CEC_CASE= 'CanUpdateCECCasePS';
    public static final String PS_CAN_UPDATE_CEC_CASE_AT_NEW = 'CanUpdateCECCaseAtStageNewPS'; 
    public static final String PS_CAN_CREATE_CEC_CASE_AT_NEW = 'CanCreateCECCaseAtStageNewPS';
    public static final String PS_CAN_UPDATE_SAFEGUARDING_CASE = 'CanUpdateSafeguardingCasePS';
    public static final String PS_CAN_UPDATE_PLACE_CASE= 'CanUpdatePlaceCasePS';
    public static final String PS_CAN_CREATE_PLACE_CASE_AT_NEW = 'CanCreatePlaceCaseAtNewStagePS'; 
    public static final String PS_CAN_UPDATE_PLACE_CASE_AT_NEW = 'CanUpdatePlaceCaseAtNewStagePS';
    public static final String PS_CAN_CREATE_BREACH_CASE_AT_NEW = 'CanCreateBreachASBCaseAtNewStagePS'; 
    public static final String PS_CAN_UPDATE_BREACH_CASE_AT_NEW = 'CanUpdateBreachASBCaseAtNewStagePS'; 
    public static final String PS_CAN_UPDATE_BREACH_CASE= 'CanUpdateBreachASBCasePS';
    public static final String PS_CAN_UPDATE_PERMISSION_CASE= 'CanUpdatePermissionCasePS';
    public static final String PS_CAN_CREATE_PERMISSION_CASE_AT_NEW = 'CanCreatePermissionCaseAtNewStagePS'; 
    public static final String PS_CAN_UPDATE_PERMISSION_CASE_AT_NEW = 'CanUpdatePermissionCaseAtNewStagePS'; 
    public static final String PS_CAN_UPDATE_TENANCY_CASE= 'CanUpdateTenancyCasePS';
    public static final String PS_CAN_CREATE_TENANCY_CASE_AT_NEW = 'CanCreateTenancyCaseAtNewStagePS'; 
    public static final String PS_CAN_UPDATE_TENANCY_CASE_AT_NEW = 'CanUpdateTenancyCaseAtNewStagePS';
    public static final String PS_CAN_UPDATE_CHANGES_CASE= 'CanUpdateChangesCasePS';
    public static final String PS_CAN_CREATE_CHANGES_CASE_AT_NEW = 'CanCreateChangesCaseAtNewStagePS'; 
    public static final String PS_CAN_UPDATE_CHANGES_CASE_AT_NEW = 'CanUpdateChangesCaseAtNewStagePS'; 
    public static final String PS_CAN_UPDATE_SCHEME_CASE = 'CanUpdateSchemesCasePS'; 
    public static final String PS_CAN_CREATE_SCHEME_CASE = 'CanCreateSchemesCasePS'; 
    public static final String PS_CAN_DELETE_CONTENT_DOCUMENT = 'CanDeleteContentDocumentPS';
    public static final String PS_CAN_UPDATE_TERMINATION = 'CanUpdateTerminationCasePS'; 
    public static final String PS_CAN_CREATE_TERMINATION_AT_NEW = 'CanCreateTerminationCaseAtNewPS'; 
    public static final String PS_CAN_CREATE_MANAGEDMOVE_CASE = 'CanCreateManagedMoveCasePS'; 
    public static final String PS_CAN_UPDATE_MANAGEDMOVE_CASE = 'CanUpdateManagedMoveCasePS'; 
    public static final String PS_ALLOW_TO_CHANGE_CLOSED_DMCCASE = 'AllowToChangeClosedDMCCasePS'; 
    public static final String PS_BYPASS_CP_Case_TF_BIU_SETAWAITINGINFORMATIONCHANGEDATETIME = 'BypassCPCaseTFBIUSetAwaitingInformationChangeDatetimePS';
    public static final String FSL_RESOURCE_LICENSE = 'FSL_Resource_License'; 
    public static final String FSL_RESOURCE_PERMISSIONS = 'FSL_Resource_Permissions'; 
    public static final String YH_CUSTOMERPORTAL_PSG = 'YHCustomerPortalUserPSG'; 
    public static final String YH_CUSTOMERCOMMUNITY_USER_PS = 'FunctionalYHCustomerCommunityUserPS';

    public static final Id YH_CUSTOMERPORTAL_PSG_ID{
        get{
            if(YH_CUSTOMERPORTAL_PSG_ID == null){
                YH_CUSTOMERPORTAL_PSG_ID = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = :PermissionSetDecorator.YH_CUSTOMERPORTAL_PSG LIMIT 1][0].Id;
            }
            return YH_CUSTOMERPORTAL_PSG_ID;
        }
        set;
    }
    public static final String STATUS_UPDATED = 'Updated';

}