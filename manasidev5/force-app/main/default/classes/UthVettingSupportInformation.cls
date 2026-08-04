@isTest
public with sharing class UthVettingSupportInformation {
   public static VettingSupportingInfo__c buildVettingSupportInfo(Id vettingId){
        return new VettingSupportingInfo__c(
            Vetting__c = vettingId
        );
   }
}