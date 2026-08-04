public with sharing class TA_Account_AIU_ManageAlert implements TriggerAction.AfterUpdate, TriggerAction.AfterInsert{
    
    public void afterInsert(List<Account> newList){
        ManageAlertBasedOnSobjectFactory.getInstance(newList.getSObjectType())?.setUpAlerts(newList, null);
    }

    public void afterUpdate(List<Account> newList, List<Account> oldList){
        ManageAlertBasedOnSobjectFactory.getInstance(newList.getSObjectType())?.setUpAlerts(newList, oldList);
    }
}