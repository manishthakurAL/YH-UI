public with sharing class CongaService {

    public enum ActionType {CONGA_SAVE_ACTION, CONGA_EMAIL_ACTION, CONGA_POST_ACTION, CONGA_EMAIL_AND_POST_ACTION, CONGA_DOCU_SIGN_ACTION, CONGA_DOCU_SIGN_INPERSON_ACTION}

    public static final String MAIL_CLASS_2ND = '2nd';
    public static final String OPERATOR_EQUALS = '=';
    public static final String ENODE_UTF8 = 'UTF-8';
    public static final String OPERATOR_SEMICOLON = ';';
    public static final String POST_STATUS_READY_POST = 'Ready for Post';
    public static final String SALESFORCE_FILE = 'SalesforceFile';
    public static final String CONGA_PARAM_ID = 'Id';
    public static final String CONGA_PARAM_TEMPLATE_ID = 'TemplateId';
    public static final String CONGA_PARAM_QUERY_ID = 'QueryId';
    public static final String CONGA_PARAM_EMAIL_TEMPLATE_ID = 'CongaEmailTemplateId';
    public static final String CONGA_PARAM_DS7 = 'DS7';
    public static final String CONGA_PARAM_DS7_PREVIEW = 'DS7Preview';
    public static final String CONGA_PARAM_SC0 = 'SC0';
    public static final String CONGA_PARAM_SC1 = 'SC1';
    public static final String CONGA_PARAM_QMODE = 'QMode';
    public static final String CONGA_PARAM_WORKSPACE_ID = 'ContentWorkspaceId';
    public static final String CONGA_PARAM_CUSTOM_FIELD = 'ContentCustomFieldName';
    public static final String CONGA_PARAM_CUSTOM_FIELD_VALUE = 'ContentCustomFieldValue';
    public static final String CONGA_PARAM_DS7_DOCU_SIGN = '17';
    public static final String CONGA_PARAM_DS7_SF_FILE = '11';
    public static final String CONGA_PARAM_DS7_SF_EMAIL_FILE = '12';
    public static final String CONGA_PARAM_ENABLE = '1';
    public static final String CONGA_PARAM_QMODE_SEND_EMAIL = 'SendEmail';
    public static final String CONGA_PARAM_QMODE_DOCU_SIGN = 'DocuSign';
    public static final String CONGA_PARAM_CUSTOM_FIELD_API_NAME = 'CongaCustomField__c';
    public static final String EXPCEPTION_ENDPOINT_DOWN = 'Conga Trigger End Point is Down';
    public static final String EXPCEPTION_TEMPLATE_ID_MISSING = 'Conga Template Id is missing';
    public static final String EXPCEPTION_TEMPLATE_MISSING = 'Conga Template does not exist';
    public static final String EXPCEPTION_INVALID_PARAM = 'Invalid Conga Parameter ';
    public static final String EXPCEPTION_ACTION_TYPE_NOT_DEFINED = 'Conga Action Type is not defined';
    public static final String DOCU_SIGN_VISIBLE = 'DocuSignVisible';
    public static final String DOCU_SIGN_R1_TYPE = 'DocuSignR1Type';
    public static final String DOCU_SIGN_R1_ROLE = 'DocuSignR1Role';
    public static final String DOCU_SIGN_EMAIL_BODY = 'DocuSignEmailBody';
    public static final String DOCU_SIGN_EMAIL_SUBJECT = 'DocuSignEmailSubject';
    public static final String DOCU_SIGN_EMAIL_REMAIND_AGAIN_IN = 'DocuSignRemindIn';
    public static final String DOCU_SIGN_EMAIL_REMAIND_IN = 'DocuSignRemindAgainIn';
    public static final String DOCU_SIGNER = 'Signer';
    public static final String DOCU_SIGNER_1 = 'Signer+1';
    public static final String DOCU_SIGNER_NAME_START = 'DocusignR';
    public static final String DOCU_SIGNER_NAME_END = 'SIPName';
    public static final String DOCU_SIGNER_ID_END = 'Id';
    public static final String DOCU_SIGN_REMIND_2 = '2';
    public static final String DOCU_SIGN_END_POINT = 'DocuSignEndpoint';
    public static final String DOCU_SIGN_SEND_AS_USER_ID = 'DocuSignSendAsUserId';
    public static final String CONGA_OFN = 'OFN';
    public static final String OFN_FILE_PREFIX = ' Cover Letter';
 
    String[] CongaComposerVariables;
    
    public static CongaService get() {
        CongaService service = new CongaService();
        return service;
    }
    
    private CongaService() {
        CongaComposerVariables = new List<String>(); 
    }

    public String getCongaUrl(Id recordId, string templateName, ActionType type) {
        CongaDocumentGenerationSetting__mdt settings = [
            SELECT MasterLabel, DocuSignParams__c, CongaParams__c, MailClass__c, TemplateId__c,
            MergeQueryId__c, EmailTemplateId__c
            FROM CongaDocumentGenerationSetting__mdt 
            WHERE DeveloperName = :templateName Limit 1];
        if (settings == null) {
            throw (new CongaServiceException(EXPCEPTION_TEMPLATE_MISSING));
        }
        this.setRequiredParams(recordId,settings);
        this.setBackgroundMode(type, settings.MailClass__c, settings.MasterLabel);
        this.setAdditionalParams(recordId, settings.CongaParams__c, false);
        if (type == ActionType.CONGA_DOCU_SIGN_INPERSON_ACTION) {
            this.setAdditionalParams(recordId, settings.DocuSignParams__c,
                true
            );
        }
        return String.join(this.CongaComposerVariables, '&');
    }

    private void setRequiredParams(Id recordId, CongaDocumentGenerationSetting__mdt settings ) {
        this.CongaComposerVariables.add(getCongaBaseUrl());
        this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_ID,recordId));
        if (String.isEmpty(settings.TemplateId__c)) {
            throw (new CongaServiceException(EXPCEPTION_TEMPLATE_ID_MISSING));
        }

        if (String.isNotEmpty(settings.TemplateId__c)) {
            this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_TEMPLATE_ID, settings.TemplateId__c));
        }

        if (String.isNotEmpty(settings.MergeQueryId__c)) {
            this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_QUERY_ID, settings.MergeQueryId__c));
        }

        if (String.isNotEmpty(settings.EmailTemplateId__c)) {
            this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_EMAIL_TEMPLATE_ID, settings.EmailTemplateId__c));
        }
    }

    private void setAdditionalParams(String recordId, String params, Boolean isInPerson) {
        if (String.isEmpty(params)) {
             return;
        }
        String[] namevaluePairs = params.split('&');
        String[] additionalParams = new List<String>();
        for (String namevaluePair : namevaluePairs) {
            if (String.isNotEmpty(namevaluePair.trim())) {
                String[] fldvalue = namevaluePair.trim().split('=');
                Integer indexOfCurrentVariable = -1;
                for (Integer i=0; i<this.CongaComposerVariables.size(); ++i) {
                    if (this.CongaComposerVariables[i].startsWithIgnoreCase(fldvalue[0] + '=')) {
                        indexOfCurrentVariable = i;
                        break;
                    }
                }
                if (indexOfCurrentVariable > -1 && fldvalue.size() > 1 ) {
                    String paramValue = fldvalue[1];
                    if (isInPerson && fldvalue[0].startsWithIgnoreCase(DOCU_SIGNER_NAME_START) && 
                                fldvalue[0].endsWithIgnoreCase(DOCU_SIGNER_ID_END)) {
                            paramValue = UserInfo.getUserId();
                    }
                    this.CongaComposerVariables[indexOfCurrentVariable] = getFieldValuePair(fldvalue[0], paramValue);
                } else {
                    if (fldvalue.size() > 1) {
                        String paramValue = fldvalue[1];
                        if (isInPerson && fldvalue[0].startsWithIgnoreCase(DOCU_SIGNER_NAME_START) && 
                            fldvalue[0].endsWithIgnoreCase(DOCU_SIGNER_NAME_END)) {
                            paramValue = getInPersonSignerName(recordId, paramValue);
                        } else if (isInPerson && fldvalue[0].startsWithIgnoreCase(DOCU_SIGNER_NAME_START) && 
                                fldvalue[0].endsWithIgnoreCase(DOCU_SIGNER_ID_END)) {
                            paramValue = UserInfo.getUserId();
                        }
                        additionalParams.add(getFieldValuePair(fldvalue[0], paramValue));
                    } else if (indexOfCurrentVariable > -1) {
                        this.CongaComposerVariables.remove(indexOfCurrentVariable); 
                    }
                } 
            }
        }
        this.congaComposerVariables.addAll(additionalParams);
    }

    private void setBackgroundMode(ActionType type, String mailClass, String fileName) {
        String postalMailClass = String.isEmpty(mailClass) ? MAIL_CLASS_2ND : mailClass;
        switch on type {
            when CONGA_SAVE_ACTION {	
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_DS7, CONGA_PARAM_DS7_SF_FILE));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_SC0, CONGA_PARAM_ENABLE));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_SC1, SALESFORCE_FILE));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_QMODE, SALESFORCE_FILE));
            }	
            when CONGA_EMAIL_ACTION {	
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_DS7, CONGA_PARAM_DS7_SF_EMAIL_FILE));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_QMODE, CONGA_PARAM_QMODE_SEND_EMAIL));
            }
            when CONGA_POST_ACTION {	
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_DS7, CONGA_PARAM_DS7_SF_FILE));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_SC0, CONGA_PARAM_ENABLE));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_SC1, SALESFORCE_FILE));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_QMODE, SALESFORCE_FILE));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_WORKSPACE_ID, getWorkspaceId()));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_CUSTOM_FIELD, CONGA_PARAM_CUSTOM_FIELD_API_NAME));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_CUSTOM_FIELD_VALUE, getPostalStatus(postalMailClass)));
            }
            when CONGA_EMAIL_AND_POST_ACTION {	
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_DS7, CONGA_PARAM_DS7_SF_EMAIL_FILE));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_SC0, CONGA_PARAM_ENABLE));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_SC1, SALESFORCE_FILE));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_QMODE, CONGA_PARAM_QMODE_SEND_EMAIL));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_WORKSPACE_ID, getWorkspaceId()));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_CUSTOM_FIELD, CONGA_PARAM_CUSTOM_FIELD_API_NAME));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_CUSTOM_FIELD_VALUE, getPostalStatus(postalMailClass)));
            }
            when CONGA_DOCU_SIGN_ACTION, CONGA_DOCU_SIGN_INPERSON_ACTION {	
                this.CongaComposerVariables.add(getFieldValuePair(DOCU_SIGN_VISIBLE, CONGA_PARAM_ENABLE));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_PARAM_QMODE, CONGA_PARAM_QMODE_DOCU_SIGN));
                this.CongaComposerVariables.add(getFieldValuePair(DOCU_SIGN_R1_TYPE, DOCU_SIGNER));
                this.CongaComposerVariables.add(getFieldValuePair(DOCU_SIGN_R1_ROLE, DOCU_SIGNER_1));
                this.CongaComposerVariables.add(getFieldValuePair(DOCU_SIGN_EMAIL_REMAIND_AGAIN_IN, DOCU_SIGN_REMIND_2));
                this.CongaComposerVariables.add(getFieldValuePair(DOCU_SIGN_EMAIL_REMAIND_IN, DOCU_SIGN_REMIND_2));
                this.CongaComposerVariables.add(getFieldValuePair(DOCU_SIGN_EMAIL_SUBJECT, getDocuSignEmailSubject()));
                this.CongaComposerVariables.add(getFieldValuePair(DOCU_SIGN_EMAIL_BODY, getDocuSignEmailBody()));
                this.CongaComposerVariables.add(getFieldValuePair(DOCU_SIGN_END_POINT, getDocuSignEndpoint()));
                this.CongaComposerVariables.add(getFieldValuePair(DOCU_SIGN_SEND_AS_USER_ID, getDocuSignUser()));
                this.CongaComposerVariables.add(getFieldValuePair(CONGA_OFN, formatFileName(fileName)));   
            }

        }
    }

    private String formatFileName(String title) {
        return EncodingUtil.urlEncode(title + OFN_FILE_PREFIX, ENODE_UTF8);
    }

    private DocuSignSettings__c getDocuSignSettings() {
        return DocuSignSettings__c.getOrgDefaults();
    }

    private String getDocuSignEmailSubject() {
        return getDocuSignSettings().EmailSubject__c;
    }

    private String getDocuSignEmailBody() {
        return getDocuSignSettings().EmailBody__c;
    }

    private String getDocuSignEndpoint() {
        return getDocuSignSettings().DocuSignEndpoint__c;
    }

    private String getDocuSignUser() {
        return getDocuSignSettings().DocuSignSendAsUserId__c;
    }

    private String getCongaBaseUrl(){
        return String.format(System.Label.CongaBaseUrl, new List<String>{
            Url.getOrgDomainUrl().toExternalForm(),
            UserInfo.getOrganizationId()
        });
    }

    private String getInPersonSignerName(String recordId, String congaQueryKey) {
        Map<String, Object> bindParams = new Map<String, Object>{
            'recordId' => recordId,
            'currentUserId' => UserInfo.getUserId()
        }; 
        String queryKey, fieldName = 'Name';
        String[] congaQueryKeyParts = congaQueryKey.contains('|')?congaQueryKey.split('\\|'):new List<String>{congaQueryKey};
        queryKey = congaQueryKeyParts[0].trim();
        if (congaQueryKeyParts.size() == 2) {
            fieldName = congaQueryKeyParts[1].trim();
        }
        String queryString = getQueryString(queryKey);
        List<SObject> queryResult = ((List<SObject>)Database.queryWithBinds(
            queryString,
            bindParams,
            AccessLevel.SYSTEM_MODE
        ));
        return (String)getSObjectFieldValue(queryResult[0], fieldName);

    }

    private Object getSObjectFieldValue(SObject record, String fieldName) {
        Object value;
        SObject currentSObject = record;
        String[] parentFieldNames = fieldName.split('\\.');
        String fieldApiName = parentFieldNames.get(parentFieldNames.size()-1);
        for(String currentField:parentFieldNames) {
            if (currentField.equals(fieldApiName)) {
                value = currentSObject.get(currentField);
            } else {
                currentSObject = currentSObject.getSObject(currentField);
            } 
        }
        return value;
    }

    private String getQueryString(String congaQueryKey) {
        return [SELECT APXTConga4__Query__c 
                FROM   APXTConga4__Conga_Merge_Query__c 
                WHERE  APXTConga4__Key__c = :congaQueryKey 
                LIMIT 1].APXTConga4__Query__c;
    }

    private String getFieldValuePair(String fieldName, String value) {
        return fieldName + OPERATOR_EQUALS + EncodingUtil.urlEncode(String.isNotEmpty(value)?value:'', ENODE_UTF8);
    }

    private String getPostalStatus(String mailClass) {
        return POST_STATUS_READY_POST + OPERATOR_SEMICOLON + mailClass;
    }

    private String getWorkspaceId() {
        return OrgSetting__c.getOrgDefaults().ContentWorkspaceId__c;
    }

    public class CongaServiceException extends Exception {} 


}