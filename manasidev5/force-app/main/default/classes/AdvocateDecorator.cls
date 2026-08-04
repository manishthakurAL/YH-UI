public with sharing class AdvocateDecorator {
    public static final String AUTHORIZATIONTYPE_DELEGATED_AUTHORITY = 'Delegated Authority';
    public static final String AUTHORIZATIONTYPE_POWER_OF_ATTORNEY = 'Power of Attorney';
    public static final List<String> AUTHORIZATIONTYPE_ALERT_LIST = new List<String>{AUTHORIZATIONTYPE_DELEGATED_AUTHORITY, AUTHORIZATIONTYPE_POWER_OF_ATTORNEY};
}