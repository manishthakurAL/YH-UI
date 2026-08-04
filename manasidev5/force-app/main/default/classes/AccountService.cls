public with sharing class AccountService {

    public Account buildPersonAccount(String fname, String lname, String Street, String City, String postalCode ){
        return new Account(
            FirstName = fname,
            LastName = lname,
            RecordTypeId = AccountDecorator.RECORD_TYPE_ID_PERSONACCOUNT,
            PersonMailingStreet = Street,
            PersonMailingCity   = City,
            PersonMailingPostalCode = postalCode,
            PersonMailingCountry = 'United Kingdom'
        );
    }

}