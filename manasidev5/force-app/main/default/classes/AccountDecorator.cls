public with sharing class AccountDecorator {

    public static final String FIELD_DISTINCT_TENANT = 'Tenant';
    public static final String SOLE_TENANT = 'Sole Tenant';
    public static final String HOUSEHOLD_MEMBER = 'Household Member';
    public static final String RECORD_TYPE_PERSONACCOUNT = 'PersonAccount';
    public static final String DISABILITY_DEXTERITY_ISSUES = 'Dexterity issues';
    public static final String DISABILITY_MOBILITY_ISSUES = 'Mobility issues';
    public static final String DISABILITY_DEXT_MOB_ISSUES = 'Dexterity issues;Mobility issues';
    public static final String DISABILITY_HEAR_VIS_ISSUES = 'Hearing Impairment;Visual Impairment;';
    public static final String DISABILITY_PREFER_NOT_TO_SAY = 'Prefer not to say';
    public static final String DISABILITY_NO_DISABILITY = 'No disability';
    public static final String DISABILITY_IGNORE_AND_CONSIDER_BOTH = 'No disability;Prefer not to say;Dexterity issues;Mobility issues';

    public static final List<String> DISABILITY_TO_IGNORE_ALERTS = new List<String>{DISABILITY_PREFER_NOT_TO_SAY, DISABILITY_NO_DISABILITY};
    
    public static String FIELD_PERSON_NUMBER {
        get{
            if(FIELD_PERSON_NUMBER == null){
                FIELD_PERSON_NUMBER  = Account.YH_Person_Number__c.getDescribe().getName(); 
            }
            return FIELD_PERSON_NUMBER;
        }
        private set;
    }

    public static String FIELD_IS_PERSON_ACCOUNT {
        get{
            if(FIELD_IS_PERSON_ACCOUNT == null){
                FIELD_IS_PERSON_ACCOUNT = Account.IsPersonAccount.getDescribe().getName();
            }
            return FIELD_IS_PERSON_ACCOUNT;
        }
        private set;
    }

    public static String FIELD_DISTINCT_TENANT_MEMBERSHIP {
        get{
            if(FIELD_DISTINCT_TENANT_MEMBERSHIP == null){
                FIELD_DISTINCT_TENANT_MEMBERSHIP = Account.DistinctActiveMembershipTypes__pc.getDescribe().getName();
            }
             return FIELD_DISTINCT_TENANT_MEMBERSHIP;
       }
       private set;
    }

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