public with sharing class MemberDecorator {
    public static final String TYPE_SOLO = 'Sole Tenant';
    public static final String TYPE_JOINT = 'Joint Tenant';
    public static final String TYPE_HOUSEHOLD_MEMBER = 'Household Member';
    public static final String SYNCH_DEACTIVATION_TERMINATION = 'Termination';
    public static final Set<String> MONITORING_FORM_APPLICABLE_TYPE = new Set<String>{'Sole Tenant','Joint Tenant'};
    public static final Set<String> TENANT_APPLICABLE_TYPE = new Set<String>{'Sole Tenant','Joint Tenant'};
}