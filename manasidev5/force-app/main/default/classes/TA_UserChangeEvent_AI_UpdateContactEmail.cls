public class TA_UserChangeEvent_AI_UpdateContactEmail implements TriggerAction.AfterInsert{
    
    @TestVisible
    private Set<Id> userIds = new Set<Id>();

    public void afterInsert(List<UserChangeEvent> newList){
        for(UserChangeEvent eventRec : newList) {
            EventBus.ChangeEventHeader header = eventRec.ChangeEventHeader;
            if(header != null){
                for (String recId : header.recordIds) {
                     if (header.changeType == UserChangeEventDecorator.CHANGETYPE_UPDATE && 
                            eventRec.Email != null && 
                            header.changedFields.contains(UserChangeEventDecorator.CHANGED_FIELD_EMAIL) ) {	
                        this.userIds.add((Id)recId);
                     }
                 }
            }
         }
 
         if (!this.userIds.isEmpty()) {
             List<Contact> contactsToUpdate = buildContactUpdates();
             if (!contactsToUpdate.isEmpty()) {
                update contactsToUpdate;
                System.enqueueJob(new UpdateUserNameOnUserQueuable(this.userIds));
             }
            

         }
    }
 
    private List<User> userlist {
        get{
            if(this.userlist == null && !this.userIds.isEmpty()){ 
                this.userlist = [SELECT Id, UserType, Profile.Name, ContactId, Email 
                                    FROM User 
                                    WHERE Id IN :this.userIds 
                                    AND Profile.Name =: UserDecorator.PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN];
            } 
            return this.userlist; 
        } 
        set; 
    }
    
    private List<Contact> buildContactUpdates() {
        List<Contact> contacts = new List<Contact>();
        for (User userRec : this.userlist) {
                contacts.add(new Contact(
                    Id = userRec.ContactId,
                    Email = userRec.Email
                ));
        }
        return contacts;
    }
    
}