public with sharing class UthProfile {
    public static List<Profile> getProfileUsingName(String profileName){
        return [SELECT Id 
            FROM Profile 
            WHERE Name = :profileName Limit 1 ];
    }
}