public with sharing class ContactService {
    public  Contact setDateOfDeath(Id contactId, Date dateOfDeath) {
        return new Contact(
            Id = contactId,
            DateOfDeath__c = dateOfDeath
        );
    }
}