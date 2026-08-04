@isTest
public with sharing class UthAccount {

    public static Account build(){
        return new Account(
            Name = 'Test Account'
        );
    }

    public static Account buildPersonAccount(){
        return new Account(
            FirstName = 'fname',
            LastName = 'lname',
            RecordTypeId = AccountDecorator.RECORD_TYPE_ID_PERSONACCOUNT
        );
    }
    
    public static Account buildPersonAccount(String fname, String lname ){
        return new Account(
            FirstName = fname,
            LastName = lname,
            RecordTypeId = AccountDecorator.RECORD_TYPE_ID_PERSONACCOUNT
        );
    }

    public static Account buildPersonAccount(String fname, String lname, String email ){
        return new Account(
            FirstName = fname,
            LastName = lname,
            RecordTypeId = AccountDecorator.RECORD_TYPE_ID_PERSONACCOUNT,
            PersonEmail = email
        );
    }

    public static Account buildPersonAccount(String fname, String lname, String email, String phonenumber, String Street, String City, String postalCode ){
        return new Account(
            RecordTypeId = AccountDecorator.RECORD_TYPE_ID_PERSONACCOUNT,
            FirstName = fname,
            LastName = lname,
            Phone = phonenumber,
            PersonOtherPhone = phonenumber,
            PersonHomePhone = phonenumber,
            PersonEmail = email,
            PersonMailingStreet = Street,
            PersonMailingCity   = City,
            PersonMailingPostalCode = postalCode
        );
    }

    public static Account buildPersonAccount(String fname, String lname, String Street, String City, String postalCode ){
        return new Account(
            FirstName = fname,
            LastName = lname,
            RecordTypeId = AccountDecorator.RECORD_TYPE_ID_PERSONACCOUNT,
            PersonMailingStreet = Street,
            PersonMailingCity   = City,
            PersonMailingPostalCode = postalCode
        );
    }

    public static Account buildPersonAccount(String fname, String lname, Date dob){
        return new Account(
            FirstName = fname,
            LastName = lname,
            PersonBirthDate = dob,
            RecordTypeId = AccountDecorator.RECORD_TYPE_ID_PERSONACCOUNT
        );
    }

    public static Account buildPersonAccount(String fname, String lname, String email, String phonenumber, Date dob, String postalCode ){
        return new Account(
            RecordTypeId = AccountDecorator.RECORD_TYPE_ID_PERSONACCOUNT,
            FirstName = fname,
            LastName = lname,
            Phone = phonenumber,
            PersonOtherPhone = phonenumber,
            PersonHomePhone = phonenumber,
            PersonMobilePhone = phonenumber,
            PersonEmail = email,
            PersonBirthDate = dob,
            PersonMailingPostalCode = postalCode
        );
    }

    public static Account buildPersonAccountDisability(String fname, String lname, String disability){
        return new Account(
            FirstName = fname,
            LastName = lname,
            YH_Disability__pc = disability,
            RecordTypeId = AccountDecorator.RECORD_TYPE_ID_PERSONACCOUNT
        );
    }

    public static List<Account> getAll(){
        return Database.query('SELECT '+
                String.join(new List<String>(Account.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM Account');
    }

    public static List<Account> getAllPersonAccount(){
        return Database.query('SELECT '+
                String.join(new List<String>(Account.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM Account WHERE isPersonAccount = true');
    }
}