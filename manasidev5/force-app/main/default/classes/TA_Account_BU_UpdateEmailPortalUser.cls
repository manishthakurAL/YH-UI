public with sharing class TA_Account_BU_UpdateEmailPortalUser implements TriggerAction.BeforeUpdate  {
   public void beforeUpdate(List<Account> newList, List<Account> oldList){  
     Map<Id, Account> oldAccountMap = new Map<Id, Account>(oldList);
        Map<Id, Account> newAccountMap = new Map<Id, Account>(newList);
        Map<Id, Account> accountByContactId = new Map<Id, Account>();
        for (Account acc : newList) {
            Account oldAcc = oldAccountMap.get(acc.Id);
            if (acc.IsPersonAccount) {
                String oldEmail = oldAcc.PersonEmail;
                String newEmail = acc.PersonEmail;
                if ( String.isBlank(newEmail) && oldEmail != newEmail ) {
                    accountByContactId.put(acc.PersonContactId, acc);
                }
            }
        }
        if( !accountByContactId.isEmpty() ){
            checkIfCustomerUserExists(accountByContactId);
        }
    }

    private void checkIfCustomerUserExists(Map<Id,Account> accountByContactId){
        List<User> users = [SELECT Id, ContactId FROM User WHERE ContactId IN :accountByContactId.keySet() AND ProfileId =: UserDecorator.PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN_ID];
        if( !users.isEmpty() ){
            for(User aUser: users){
               if(accountByContactId.containsKey(aUser.ContactId)){
                    accountByContactId.get(aUser.ContactId).addError(Label.PersonAccountEmailNotBlankForPortalUser);
               }
            }
        }
    }
}