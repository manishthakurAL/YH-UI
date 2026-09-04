public with sharing class AccountDecorator {

    public static final String FIELD_PERSON_NUMBER = 'YH_Person_Number__c';
    public static final String FIELD_IS_PERSON_ACCOUNT = 'IsPersonAccount';
    public static final String FIELD_DISTINCT_TENANT = 'Tenant';
    public static final String FIELD_DISTINCT_TENANT_MEMBERSHIP = 'DistinctActiveMembershipTypes__pc';

    public static final String RECORD_TYPE_PERSONACCOUNT = 'PersonAccount';
    public static final String DISABILITY_DEXTERITY_ISSUES = 'Dexterity issues';
    public static final String DISABILITY_MOBILITY_ISSUES = 'Mobility issues';
    public static final String DISABILITY_DEXT_MOB_ISSUES = 'Dexterity issues;Mobility issues';
    public static final String DISABILITY_HEAR_VIS_ISSUES = 'Hearing Impairment;Visual Impairment;';
    public static final String DISABILITY_PREFER_NOT_TO_SAY = 'Prefer not to say';
    public static final String DISABILITY_NO_DISABILITY = 'No disability';
    public static final String DISABILITY_IGNORE_AND_CONSIDER_BOTH = 'No disability;Prefer not to say;Dexterity issues;Mobility issues';

    public static final List<String> DISABILITY_TO_IGNORE_ALERTS = new List<String>{DISABILITY_PREFER_NOT_TO_SAY, DISABILITY_NO_DISABILITY};
    
    public static Map<String, Schema.RecordTypeInfo> accountRecordTypeInfoByDevName{
        get{
            if(accountRecordTypeInfoByDevName == null){
                accountRecordTypeInfoByDevName = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
            }
            return accountRecordTypeInfoByDevName;
        }
        set;
    }

    public static final Id RECORD_TYPE_ID_PERSONACCOUNT{
        get{
            if (RECORD_TYPE_ID_PERSONACCOUNT == null) {
                RECORD_TYPE_ID_PERSONACCOUNT = accountRecordTypeInfoByDevName.get(RECORD_TYPE_PERSONACCOUNT).getRecordTypeId();
            }
            return RECORD_TYPE_ID_PERSONACCOUNT;
        }
        set;
    }
}