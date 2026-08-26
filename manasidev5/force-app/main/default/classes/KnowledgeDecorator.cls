public with sharing class KnowledgeDecorator {
   public static String LANGUAGE_ENGLISH ='en_US';
   public static String PUBLISH_STATUS_ONLINE ='Online';
   public static String DATACATEGORY_AUDIENCE ='Audience';
   public static String DATACATEGORY_EXTERNALLOGGEDIN ='External_Logged_In__c';
   public static String DATACATEGORY_EXTERNALLOGGEDIN_LABEL ='External_Logged_In';
   public static String DATACATEGORY_DOMAIN ='Domain';
   public static String KNOWLEDGE_PUBLISH ='Online';
   public static final String PAYMENT_ARREARS_LABEL ='Payments and Arrears';
   public static final String PAYMENT_ARREARS_API ='PaymentsAndArrears__c';
   public static final String BREACH_AND_ANTISOCIAL_BEHAVIOUR_LABEL = 'Breach & Anti-social';
   public static final String BREACH_AND_ANTISOCIAL_BEHAVIOUR_API = 'BreachAndAntiSocialBehaviour__c';
   public static final String CASE_MANAGEMENT_INTENT = 'Case_Management__c';
   public static final String GENERAL_INFO = 'General_Info__c';
   public static final String REPAIRS_LABEL = 'Repairs';
   public static final String REPAIRS_API = 'Repairs__c';





   

   public static Map<String, String> dataCategoryLabelByDevName = new Map<String, String>();
   public static final Map<String, String>  DATA_CATEGORY_LABEL_BY_DEV_NAME{
        get{
            if (DATA_CATEGORY_LABEL_BY_DEV_NAME == null) {
                DATA_CATEGORY_LABEL_BY_DEV_NAME =  new Map<String, String>{
                    CaseDecorator.TYPE_COMPLIMENT => CaseDecorator.TYPE_COMPLIMENT + '__c',
                    CaseDecorator.TYPE_COMPLAINT => CaseDecorator.TYPE_COMPLAINT + '__c',
                    PAYMENT_ARREARS_LABEL => PAYMENT_ARREARS_API,
                    CaseDecorator.TYPE_TERMINATION => CaseDecorator.TYPE_TERMINATION + '__c',
                    CaseDecorator.TYPE_SUGGESTION => CaseDecorator.TYPE_SUGGESTION + '__c',
                    BREACH_AND_ANTISOCIAL_BEHAVIOUR_LABEL => BREACH_AND_ANTISOCIAL_BEHAVIOUR_API,
                    REPAIRS_LABEL => REPAIRS_API
                    
                };
            }
            return DATA_CATEGORY_LABEL_BY_DEV_NAME;
        }
        set;
    }

     public static final Map<String, String>  INTENT_BY_DOMAIN{
        get{
            if (INTENT_BY_DOMAIN == null) {
                INTENT_BY_DOMAIN =  new Map<String, String>{
                    CaseDecorator.TYPE_COMPLIMENT => CASE_MANAGEMENT_INTENT,
                    CaseDecorator.TYPE_COMPLAINT => CASE_MANAGEMENT_INTENT,
                    CaseDecorator.TYPE_TERMINATION => CASE_MANAGEMENT_INTENT,
                    CaseDecorator.TYPE_SUGGESTION => CASE_MANAGEMENT_INTENT,
                    BREACH_AND_ANTISOCIAL_BEHAVIOUR_LABEL => CASE_MANAGEMENT_INTENT,
                    REPAIRS_LABEL => GENERAL_INFO
                };
            }
            return INTENT_BY_DOMAIN;
        }
        set;
    }
}