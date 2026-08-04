public with sharing class CommunityPortalAccountController {
    
    @AuraEnabled(cacheable=true)
     public static String getCurrentUserName() {
        return [
            SELECT FirstName
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ].FirstName;

    }
 
}