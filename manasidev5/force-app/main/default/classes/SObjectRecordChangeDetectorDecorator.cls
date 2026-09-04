public with sharing class SObjectRecordChangeDetectorDecorator {
    public static String INTEGRATION_STATUS_READY = 'Ready';
    public static String INTEGRATION_STATUS_SYNCHED = 'Synched';
    public static String INTEGRATION_STATUS_ERROR = 'Error';
    public static String INTEGRATION_STATUS_IN_PROGRESS = 'In Progress';
    public static String INTEGRATION_STATUS_IN_PROGRESS_FURUPD = 'In Progress and Further Updates';
    public static String INTEGRATION_STATUS_FIELD = 'IntegrationStatus__c';
    public static String LAST_SF_INT_STATUS_TS_IN_MS_FIELD = 'LastSalesforceIntStatusTSinMS__c';
    public static String LAST_MS_INT_STATUS_TS_IN_MS_FIELD = 'LastMuleSoftIntStatusTSinMS__c';
    public static String LAST_MS_SOFT_SYNCHED_TS_IN_MS_FIELD = 'LastMuleSoftSyncedTSinMS__c';
    public static String CREATED_IN_SYSTEM_SALESFORCE = 'SALESFORCE';
    public static String CREATED_IN_SYSTEM_ORCHARD = 'ORCHARD';
    public static String CREATED_IN_SYSTEM = 'CreatedInSystem__c';
    public static String LAST_SYNCH_DIRECTION ='LastSynchDirection__c';
    public static String LAST_SYNCH_DIRECTION_SF_TO_EXTERNAL ='Synch From Salesforce To External';
    public static String LAST_SYNCH_DIRECTION_EXTERNAL_TO_SF ='Synch From External To Salesforce';
    public static String WORK_ORDER_STATUS_FIELD ='Status';
}