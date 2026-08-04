@isTest
public with sharing class UthUserRole {

    public static UserRole getUserRole(String developerName){
        return [SELECT Id FROM UserRole WHERE DeveloperName = :developerName limit 1];
    }
}