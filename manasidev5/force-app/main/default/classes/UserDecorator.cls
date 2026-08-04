public class UserDecorator {
    public static final String PROFILE_CUSTOMER_SUCCESS = 'Customer Success';
    public static final String ROLE_CUSTOMER_EXPERIENCE_MANAGER = 'CustomerExperienceManager';
    public static final String ROLE_CUSTOMER_EXPERIENCE_ADVISOR = 'CustomerExperienceAdvisor';
    public static final String ROLE_MONEY_COACH = 'Money Coach';
    public static final String ROLE_PLACE_OFFICER = 'PlaceOfficer';
    public static final String ROLE_PLACE_MANAGER = 'PlaceManager';
    public static final String ROLE_SAFEGUARDING_OFFICER = 'SafeguardingOfficer';
    public static final String PROFILE_SYSTEM_ADMINISTRATOR = 'System Administrator';
    public static final String PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN = 'YH Customer Community Plus Login';
    public static final String PROFILE_YH_CUSTOMER_GUEST = 'YH Customer Portal Profile';
    public static final String ROLE_OPERATIVE = 'Operative';
    public static final String PROFILE_FS_SERVICE_RESOURCE = 'FS Service Resource';
    public static final Id PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN_ID{
        get{
            if(PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN_ID == null){
                PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN_ID = [SELECT Id 
                    FROM Profile 
                    WHERE Name = :PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN Limit 1][0].Id;
            }
            return PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN_ID;
        }
        set;
    }
}