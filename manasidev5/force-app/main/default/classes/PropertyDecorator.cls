public with sharing class PropertyDecorator {
        public static final String HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE = 'Housing for Older People';
        public static final String HOUSINGPURPOSE_GENERAL_NEEDS = 'General Needs';
        public static final String HOUSINGPURPOSE_SUPPORTED_HOUSING = 'Supported Housing';
        public static final String AUTHORITY_BARNSLEY = 'Barnsley';
        public static final String AUTHCODE_E08000038 = 'E08000038';
        public static final String RENT_TYPE_MARKET_RENT = 'Market Rent';
        public static final String RENT_TYPE_INTERMEDIATE_RENT = 'Intermediate Rent';
        public static final String RENT_TYPE_SOCIAL_RENT = 'Social Rent';
        public static final String RENT_TYPE_AFFORDABLE_RENT = 'Affordable Rent';
        public static final String PRODUCT_TYPE_MORTGAGE_RESCUE = 'Mortgage Rescue';
        public static final String PRODUCT_TYPE_TRY_BEFORE_YOU_BUY = 'Try Before You Buy';
        public static final String PRODUCT_TYPE_LOW_COST_RENTAL = 'Low Cost Rental';
        public static final String PRODUCT_TYPE_EXTRA_CARE = 'Extra Care';
        public static final String PROPERTY_TYPE_EXTERNAL = 'External';
        public static final String PROPERTY_TYPE_INTERNAL = 'Internal';
        public static final String PRODUCT_TYPE_SCHEMES_SOCIAL = 'Schemes - Social';
        public static final String PRODUCT_TYPE_SCHEMES_AFFORDABLE = 'Schemes - Affordable';
        public static final String PRODUCT_TYPE_EXTRA_CARE_SOCIAL = 'Extra Care - Social';
        public static final String PRODUCT_TYPE_EXTRA_CARE_AFFORDABLE = 'Extra Care - Affordable';
        public static final String PRODUCT_TYPE_SUPPORTEDHOUSING_SOCIAL = 'Supported Housing - Social';
        public static final String PRODUCT_TYPE_SUPPORTEDHOUSING_AFFORDABLE = 'Supported Housing - Affordable Rent';
        public static final String RENT_TYPE_RENTTOBUY = 'Rent To Buy';
        public static final String PRODUCT_TYPE_MARKETRENTAL = 'Market Rental';
        public static final String GARAGE_RENT = 'Garage Rent'; 
        public static final String NON_RESEDENTIAL_STOCK = 'Non-Residential Stock';
        public static final String GARAGE_ASSET_CLASS = 'Garage';
        public static final String GARAGE_PARKING_ASSET_CLASS = 'Garage / Parking Space';
        public static final String FLAT_ASSET_CLASS = 'Flat';
        public static final String HOUSE_ASSET_CLASS = 'House';
        public static final String ASBESTOS_ASSUMED = 'Asbestos Assumed';
        public static final String NO_ASBESTOS_ASSUMED = 'No Asbestos Assumed';
        public static final String RIGHT_TO_BUY = 'Right to Buy';
        public static final String RIGHT_TO_ACQUIRE = 'Right to Acquire';
        public static final String SECTION_20_YES = 'Yes';
        public static final String SECTION_20_NO = 'No'; 

    
        public static List<string> LIST_HOUSING_PURPOSE_GENERAL_SUPPORTED_ELDERLY = new List<String>{
                HOUSINGPURPOSE_GENERAL_NEEDS,
                HOUSINGPURPOSE_SUPPORTED_HOUSING,
                HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        };
    
        public static List<string> LIST_RENT_TYPE_INTERMEDIATE_SOCIAL_AFFORDABLE = new List<String>{
                RENT_TYPE_INTERMEDIATE_RENT,
                RENT_TYPE_SOCIAL_RENT,
                RENT_TYPE_AFFORDABLE_RENT
        };
    
        public static List<string> LIST_PRODUCT_TYPE_MORTGAGE_TRY_LOW_EXTRA = new List<String>{
                PRODUCT_TYPE_MORTGAGE_RESCUE,
                PRODUCT_TYPE_TRY_BEFORE_YOU_BUY,
                PRODUCT_TYPE_LOW_COST_RENTAL,
                PRODUCT_TYPE_EXTRA_CARE
        };

        public static List<string> SOCIAL_RENT = new List<String>{
                PropertyDecorator.RENT_TYPE_SOCIAL_RENT ,
		PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT,
                PropertyDecorator.PRODUCT_TYPE_SUPPORTEDHOUSING_SOCIAL,
		PropertyDecorator.PRODUCT_TYPE_SUPPORTEDHOUSING_AFFORDABLE,
                PropertyDecorator.PRODUCT_TYPE_SCHEMES_SOCIAL,
		PropertyDecorator.PRODUCT_TYPE_SCHEMES_AFFORDABLE,
                PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE_SOCIAL,
		PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE_AFFORDABLE
        };
        
        public static List<string> MARKET_RENT = new List<String>{
                PropertyDecorator.RENT_TYPE_MARKET_RENT ,
		PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
                PropertyDecorator.RENT_TYPE_RENTTOBUY
        };

    public static final String ASBESTOS_STATUS_FLD {
        get{
            if(String.isBlank(ASBESTOS_STATUS_FLD)){
                ASBESTOS_STATUS_FLD = YH_Property__c.AsbestosStatus__c.getDescribe().getName();
            }
            return ASBESTOS_STATUS_FLD;
        }
        set;
    }

    public static final String ASBESTOS_STATUS_START_DATE_FLD {
        get{
            if(String.isBlank(ASBESTOS_STATUS_START_DATE_FLD)){
                ASBESTOS_STATUS_START_DATE_FLD = YH_Property__c.AsbestosStatusStartDate__c.getDescribe().getName();
            }
            return ASBESTOS_STATUS_START_DATE_FLD;
        }
        set;
    }

    public static final String ASBESTOS_STATUS_END_DATE_FLD {
        get{
            if(String.isBlank(ASBESTOS_STATUS_END_DATE_FLD)){
                ASBESTOS_STATUS_END_DATE_FLD = YH_Property__c.AsbestosStatusEndDate__c.getDescribe().getName();
            }
            return ASBESTOS_STATUS_END_DATE_FLD;
        }
        set;
    }

    public static final String RIGHT_TO_BUY_STATUS_FLD {
        get{
            if(String.isBlank(RIGHT_TO_BUY_STATUS_FLD)){
                RIGHT_TO_BUY_STATUS_FLD = YH_Property__c.RightToBuyOrAcquire__c.getDescribe().getName();
            }
            return RIGHT_TO_BUY_STATUS_FLD;
        }
        set;
    }

    public static final String RIGHT_TO_BUY_START_DATE_FLD {
        get{
            if(String.isBlank(RIGHT_TO_BUY_START_DATE_FLD)){
                RIGHT_TO_BUY_START_DATE_FLD = YH_Property__c.RighttoBuyorAcquireStartDate__c.getDescribe().getName();
            }
            return RIGHT_TO_BUY_START_DATE_FLD;
        }
        set;
    }

    public static final String RIGHT_TO_BUY_END_DATE_FLD {
        get{
            if(String.isBlank(RIGHT_TO_BUY_END_DATE_FLD)){
                RIGHT_TO_BUY_END_DATE_FLD = YH_Property__c.RighttoBuyorAcquireEndDate__c.getDescribe().getName();
            }
            return RIGHT_TO_BUY_END_DATE_FLD;
        }
        set;
    }

    public static final String SECTION_20_STATUS_FLD {
        get{
            if(String.isBlank(SECTION_20_STATUS_FLD)){
                SECTION_20_STATUS_FLD = YH_Property__c.Section20ConsultationRequired__c.getDescribe().getName();
            }
            return SECTION_20_STATUS_FLD;
        }
        set;
    }

    public static final String SECTION_20_START_DATE_FLD {
        get{
            if(String.isBlank(SECTION_20_START_DATE_FLD)){
                SECTION_20_START_DATE_FLD = YH_Property__c.Section20ConsultationReqStartDate__c.getDescribe().getName();
            }
            return SECTION_20_START_DATE_FLD;
        }
        set;
    } 

    public static final String SECTION_20_END_DATE_FLD {
        get{
            if(String.isBlank(SECTION_20_END_DATE_FLD)){
                SECTION_20_END_DATE_FLD = YH_Property__c.Section20ConsultationReqEndDate__c.getDescribe().getName();
            }
            return SECTION_20_END_DATE_FLD;
        }
        set;
    }
}