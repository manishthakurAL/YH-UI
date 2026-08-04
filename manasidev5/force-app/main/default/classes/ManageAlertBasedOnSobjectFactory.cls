public with sharing class ManageAlertBasedOnSobjectFactory {

    public static IManageAlertInterface getInstance(SObjectType type) {
        IManageAlertInterface handler;

        if (type == YH_Property__c.SObjectType) {
            handler = new ManageAlertPropertyImpl();
        } else if (type == Advocate__c.SObjectType) {
            handler = new ManageAlertAdvocateImpl();
        } else if (type == Account.SObjectType) {
            handler = new ManageAlertPersonAccountImpl();
        } else {
            throw new ManageAlertFactoryException('Class implementation not found for ' + type + ' object'); 
        }
        return handler;

    }
    
    public class ManageAlertFactoryException extends Exception {}
}