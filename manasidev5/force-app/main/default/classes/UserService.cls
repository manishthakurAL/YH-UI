public with sharing class UserService {
    
    public static Id customerPortalProfileId{
        get{
            if(customerPortalProfileId == null){
                customerPortalProfileId = [SELECT Id 
                    FROM Profile 
                    WHERE Name =: UserDecorator.PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN].Id;
            }
            return customerPortalProfileId;
        }
        set;
    }

    public static Id yhCustomerProfileGuest{
        get{
            if(yhCustomerProfileGuest == null){
                yhCustomerProfileGuest = [SELECT Id 
                    FROM Profile 
                    WHERE Name =: UserDecorator.PROFILE_YH_CUSTOMER_GUEST].Id;
            }
            return yhCustomerProfileGuest;
        }
        set;
    }
}