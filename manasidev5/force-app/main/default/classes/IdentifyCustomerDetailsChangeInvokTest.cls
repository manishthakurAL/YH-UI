@isTest
public with sharing class IdentifyCustomerDetailsChangeInvokTest {

    static CustomerDetailsInput myDetails;
    
    static {
        myDetails = new CustomerDetailsInput();
        myDetails.title = CustomerDetailsDecorator.TITLE_MR;
        myDetails.firstName = 'Mohd';
        myDetails.lastName = 'Test';
        myDetails.middleName = 'Middle';
        myDetails.birthdate = Date.newInstance(1980,01,01);
        myDetails.genderIdentity = CustomerDetailsDecorator.GENDER_MALE;
        myDetails.email = 'test@example.com';
        myDetails.mobilePhone = '0123456789';
        myDetails.pronouns = CustomerDetailsDecorator.PRONOUNS_HE_THEY;
        myDetails.homePhone = '0123456789';
        myDetails.OtherPhone = '0123456789';
        myDetails.yhReligionOrBelief = CustomerDetailsDecorator.RELIGION_MUSLIM;
        myDetails.yhMainLanguage = CustomerDetailsDecorator.MAIN_LANG_ENGLISH;
        myDetails.yhDisability = CustomerDetailsDecorator.DISABILITY_NO;
        myDetails.mailingAddress = 'Streeet, Town, ZZ1 1ZZ';
        myDetails.yhMaritalStatus = CustomerDetailsDecorator.MARITAL_STATUS_MARRIED;
        myDetails.yhEthnicity = CustomerDetailsDecorator.ETHINICITY_INDIAN;
    }


    @isTest
    static void test_compareCustomerDetailsNameChanges(){
        CustomerDetailsInput myNewDetails = (CustomerDetailsInput) JSON.deserialize(JSON.serialize(myDetails), CustomerDetailsInput.class);
        myNewDetails.firstName = 'New First Name';
        myNewDetails.lastName = 'New Last Name';
        List<CustomerDetailsChangeResult> results;
        Test.startTest();
        IdentifyCustomerChangesInput myInput = new IdentifyCustomerChangesInput();
        myInput.oldCustomerDetails = myDetails;
        myInput.newCustomerDetails = myNewDetails;
        results = IdentifyCustomerDetailsChangeInvocable.identifyChanges(
            new List<IdentifyCustomerChangesInput>{myInput}
        );
        Test.stopTest();
        Assert.areEqual(false, results[0].isTitleChanged, 'Title changed must be false');
        Assert.areEqual(true, results[0].isFNChanged, 'First Name changed must be true');
        Assert.areEqual(false, results[0].isMNChanged, 'Middle Name changed must be false');
        Assert.areEqual(true, results[0].isLNChanged, 'Last Name changed must be false');
        Assert.areEqual(false, results[0].isDOBChanged, 'DOB changed must be false');
        Assert.areEqual(false, results[0].isEmailChanged, 'Email changed must be false');
        Assert.areEqual(false, results[0].isGenderChanged, 'Gender changed must be false');
        Assert.areEqual(false, results[0].isMobileChanged, 'Mobile changed must be false');
        Assert.areEqual(false, results[0].isDisabilityChanged, 'Disability changed must be false');
        Assert.areEqual(false, results[0].isNameAndTitleChanged, 'Name Title changed must be false');
        Assert.areEqual(false, results[0].isNameAndGenderChanged, 'Name Gender changed must be false');
        Assert.areEqual(true, results[0].hasNameChanges, 'Name changes should be true');
        Assert.areEqual(false, results[0].hasOtherChanges, 'Other changes should be false');
        Assert.areEqual(true, String.isBlank(results[0].otherChangeDetails), 'Other changes must be empty');
    }

    @isTest
    static void test_compareCustomerDetailsBirthDateChanges(){
        CustomerDetailsInput myNewDetails = (CustomerDetailsInput) JSON.deserialize(JSON.serialize(myDetails), CustomerDetailsInput.class);
        myNewDetails.birthdate = Date.newInstance(1981,01,01);
        List<CustomerDetailsChangeResult> results;
        Test.startTest();
        IdentifyCustomerChangesInput myInput = new IdentifyCustomerChangesInput();
        myInput.oldCustomerDetails = myDetails;
        myInput.newCustomerDetails = myNewDetails;
        results = IdentifyCustomerDetailsChangeInvocable.identifyChanges(
            new List<IdentifyCustomerChangesInput>{myInput}
        );
        Test.stopTest();
        Assert.areEqual(true, results[0].isDOBChanged, 'Birthdate changes should be true');
        Assert.areEqual(false, results[0].hasNameChanges, 'Only Name changes should be false');
        Assert.areEqual(false, results[0].hasOtherChanges, 'Other changes should be false');
        Assert.areEqual(false, results[0].isTitleChanged, 'Title changed must be false');
        Assert.areEqual(false, results[0].isFNChanged, 'First Name changed must be false');
        Assert.areEqual(false, results[0].isMNChanged, 'Middle Name changed must be false');
        Assert.areEqual(false, results[0].isLNChanged, 'Last Name changed must be false');
        Assert.areEqual(false, results[0].isEmailChanged, 'Email changed must be false');
        Assert.areEqual(false, results[0].isGenderChanged, 'Gender changed must be false');
        Assert.areEqual(false, results[0].isMobileChanged, 'Mobile changed must be false');
        Assert.areEqual(false, results[0].isDisabilityChanged, 'Disability changed must be false');
        Assert.areEqual(false, results[0].isNameAndTitleChanged, 'Name Title changed must be false');
        Assert.areEqual(false, results[0].isNameAndGenderChanged, 'Name Gender changed must be false');
        Assert.areEqual(true, String.isBlank(results[0].otherChangeDetails), 'Other changes must be empty');
    }

    @isTest
    static void test_compareCustomerDetailsOtherChanges(){
        CustomerDetailsInput myNewDetails = (CustomerDetailsInput) JSON.deserialize(JSON.serialize(myDetails), CustomerDetailsInput.class);
        myNewDetails.mailingAddress = 'New Street, New Town, ZZ1 1ZZ';
        List<CustomerDetailsChangeResult> results;
        Test.startTest();
        IdentifyCustomerChangesInput myInput = new IdentifyCustomerChangesInput();
        myInput.oldCustomerDetails = myDetails;
        myInput.newCustomerDetails = myNewDetails;
        results = IdentifyCustomerDetailsChangeInvocable.identifyChanges(
            new List<IdentifyCustomerChangesInput>{myInput}
        );
        Test.stopTest();
        Assert.areEqual(false, results[0].isDOBChanged, 'Birthdate changes should be false');
        Assert.areEqual(false, results[0].hasNameChanges, 'Only Name changes should be true');
        Assert.areEqual(true, results[0].hasOtherChanges, 'Other changes should be true');
        Assert.areEqual(false, results[0].isTitleChanged, 'Title changed must be false');
        Assert.areEqual(false, results[0].isFNChanged, 'First Name changed must be true');
        Assert.areEqual(false, results[0].isMNChanged, 'Middle Name changed must be false');
        Assert.areEqual(false, results[0].isLNChanged, 'Last Name changed must be false');
        Assert.areEqual(false, results[0].isDOBChanged, 'DOB changed must be false');
        Assert.areEqual(false, results[0].isEmailChanged, 'Email changed must be false');
        Assert.areEqual(false, results[0].isGenderChanged, 'Gender changed must be false');
        Assert.areEqual(false, results[0].isMobileChanged, 'Mobile changed must be false');
        Assert.areEqual(false, results[0].isDisabilityChanged, 'Disability changed must be false');
        Assert.areEqual(false, results[0].isNameAndTitleChanged, 'Name Title changed must be false');
        Assert.areEqual(false, results[0].isNameAndGenderChanged, 'Name Gender changed must be false');
        Assert.areEqual(false, results[0].hasNameChanges, 'Name changes should be true');
        Assert.areEqual(true, results[0].otherChangeDetails.containsIgnoreCase('mailingAddress'), 'Other changes must contains Mailingaddress');
    }

    @isTest
    static void test_compareCustomerDetailsTitleAndNameChanges(){
        CustomerDetailsInput myNewDetails = (CustomerDetailsInput) JSON.deserialize(JSON.serialize(myDetails), CustomerDetailsInput.class);
        myNewDetails.title = CustomerDetailsDecorator.TITLE_DR;
        myNewDetails.firstName = 'New First Name';
        List<CustomerDetailsChangeResult> results;
        Test.startTest();
        IdentifyCustomerChangesInput myInput = new IdentifyCustomerChangesInput();
        myInput.oldCustomerDetails = myDetails;
        myInput.newCustomerDetails = myNewDetails;
        results = IdentifyCustomerDetailsChangeInvocable.identifyChanges(
            new List<IdentifyCustomerChangesInput>{myInput}
        );
        Test.stopTest();
        Assert.areEqual(true, results[0].hasNameChanges, 'Only Name changes should be true');
        Assert.areEqual(false, results[0].hasOtherChanges, 'Only Name changes should be  and other changes should be false');
        Assert.areEqual(true, results[0].isTitleChanged, 'Title changed must be false');
        Assert.areEqual(true, results[0].isFNChanged, 'First Name changed must be true');
        Assert.areEqual(false, results[0].isMNChanged, 'Middle Name changed must be false');
        Assert.areEqual(false, results[0].isLNChanged, 'Last Name changed must be false');
        Assert.areEqual(false, results[0].isDOBChanged, 'DOB changed must be false');
        Assert.areEqual(false, results[0].isEmailChanged, 'Email changed must be false');
        Assert.areEqual(false, results[0].isGenderChanged, 'Gender changed must be false');
        Assert.areEqual(false, results[0].isMobileChanged, 'Mobile changed must be false');
        Assert.areEqual(false, results[0].isDisabilityChanged, 'Disability changed must be false');
        Assert.areEqual(true, results[0].isNameAndTitleChanged, 'Name Title changed must be false');
        Assert.areEqual(false, results[0].isNameAndGenderChanged, 'Name Gender changed must be false');
        Assert.areEqual(true, results[0].hasNameChanges, 'Name changes should be true');
        Assert.areEqual(true, String.isBlank(results[0].otherChangeDetails), 'Other changes must be blank');
    }

    @isTest
    static void test_compareCustomerDetailsTitleAndOtherChanges(){
        CustomerDetailsInput myNewDetails = (CustomerDetailsInput) JSON.deserialize(JSON.serialize(myDetails), CustomerDetailsInput.class);
        myNewDetails.title = CustomerDetailsDecorator.TITLE_DR;
        myNewDetails.mailingAddress = 'New Street, New Town, ZZ1 1ZZ';
        List<CustomerDetailsChangeResult> results;
        Test.startTest();
        IdentifyCustomerChangesInput myInput = new IdentifyCustomerChangesInput();
        myInput.oldCustomerDetails = myDetails;
        myInput.newCustomerDetails = myNewDetails;
        results = IdentifyCustomerDetailsChangeInvocable.identifyChanges(
            new List<IdentifyCustomerChangesInput>{myInput}
        );
        Test.stopTest();
        Assert.areEqual(false, results[0].hasNameChanges, 'Only Other changes should be true');
        Assert.areEqual(true, results[0].isTitleChanged, 'Other changes should be true');
        Assert.areEqual(true, results[0].hasOtherChanges, 'Name changes should be false and other changes should be true');
        Assert.areEqual(true, results[0].otherChangeDetails.startsWith('TITLE'), 'Title must be present in the other change details');
        Assert.areEqual(false, results[0].isFNChanged, 'First Name changed must be true');
        Assert.areEqual(false, results[0].isMNChanged, 'Middle Name changed must be false');
        Assert.areEqual(false, results[0].isLNChanged, 'Last Name changed must be false');
        Assert.areEqual(false, results[0].isDOBChanged, 'DOB changed must be false');
        Assert.areEqual(false, results[0].isEmailChanged, 'Email changed must be false');
        Assert.areEqual(false, results[0].isGenderChanged, 'Gender changed must be false');
        Assert.areEqual(false, results[0].isMobileChanged, 'Mobile changed must be false');
        Assert.areEqual(false, results[0].isDisabilityChanged, 'Disability changed must be false');
        Assert.areEqual(false, results[0].isNameAndTitleChanged, 'Name Title changed must be false');
        Assert.areEqual(false, results[0].isNameAndGenderChanged, 'Name Gender changed must be false');
        Assert.areEqual(false, results[0].hasNameChanges, 'Name changes should be true');
    }

    @isTest
    static void test_compareCustomerDetailsTitleNameAndOtherChanges(){
        CustomerDetailsInput myNewDetails = (CustomerDetailsInput) JSON.deserialize(JSON.serialize(myDetails), CustomerDetailsInput.class);
        myNewDetails.title = CustomerDetailsDecorator.TITLE_DR;
        myNewDetails.lastName = 'New Last Name';
        myNewDetails.mailingAddress = 'New Street, New Town, ZZ1 1ZZ';
        List<CustomerDetailsChangeResult> results;
        Test.startTest();
        IdentifyCustomerChangesInput myInput = new IdentifyCustomerChangesInput();
        myInput.oldCustomerDetails = myDetails;
        myInput.newCustomerDetails = myNewDetails;
        results = IdentifyCustomerDetailsChangeInvocable.identifyChanges(
            new List<IdentifyCustomerChangesInput>{myInput}
        );
        Test.stopTest();
        Assert.areEqual(true, results[0].hasNameChanges, 'Only Other changes should be true');
        Assert.areEqual(true, results[0].isTitleChanged, 'Other changes should be true');
        Assert.areEqual(true, results[0].hasOtherChanges, 'Name changes should be false and other changes should be true');
        Assert.areEqual(false, results[0].otherChangeDetails.startsWith('TITLE'), 'Title must be present in the other change details');
        Assert.areEqual(false, results[0].isFNChanged, 'First Name changed must be true');
        Assert.areEqual(false, results[0].isMNChanged, 'Middle Name changed must be false');
        Assert.areEqual(true, results[0].isLNChanged, 'Last Name changed must be false');
        Assert.areEqual(false, results[0].isDOBChanged, 'DOB changed must be false');
        Assert.areEqual(false, results[0].isEmailChanged, 'Email changed must be false');
        Assert.areEqual(false, results[0].isGenderChanged, 'Gender changed must be false');
        Assert.areEqual(false, results[0].isMobileChanged, 'Mobile changed must be false');
        Assert.areEqual(false, results[0].isDisabilityChanged, 'Disability changed must be false');
        Assert.areEqual(true, results[0].isNameAndTitleChanged, 'Name Title changed must be false');
        Assert.areEqual(false, results[0].isNameAndGenderChanged, 'Name Gender changed must be false');
    }

    @isTest
    static void test_compareCustomerDetailsGenderAndNameChanges(){
        CustomerDetailsInput myNewDetails = (CustomerDetailsInput) JSON.deserialize(JSON.serialize(myDetails), CustomerDetailsInput.class);
        myNewDetails.genderIdentity = CustomerDetailsDecorator.GENDER_FEMALE;
        myNewDetails.firstName = 'New First Name';
        List<CustomerDetailsChangeResult> results;
        Test.startTest();
        IdentifyCustomerChangesInput myInput = new IdentifyCustomerChangesInput();
        myInput.oldCustomerDetails = myDetails;
        myInput.newCustomerDetails = myNewDetails;
        results = IdentifyCustomerDetailsChangeInvocable.identifyChanges(
            new List<IdentifyCustomerChangesInput>{myInput}
        );
        Test.stopTest();
        Assert.areEqual(true, results[0].hasNameChanges, 'Name changes should be true');
        Assert.areEqual(true, results[0].isGenderChanged, 'Gender changes should be true');
        Assert.areEqual(true, results[0].isNameAndGenderChanged, 'isNameAndGenderChanged changes should be true');
        Assert.areEqual(false, results[0].hasOtherChanges, 'Other changes should be false');
        Assert.areEqual(true, results[0].isFNChanged, 'First Name changed must be true');
        Assert.areEqual(false, results[0].isMNChanged, 'Middle Name changed must be false');
        Assert.areEqual(false, results[0].isLNChanged, 'Last Name changed must be false');
        Assert.areEqual(false, results[0].isDOBChanged, 'DOB changed must be false');
        Assert.areEqual(false, results[0].isEmailChanged, 'Email changed must be false');
        Assert.areEqual(false, results[0].isMobileChanged, 'Mobile changed must be false');
        Assert.areEqual(false, results[0].isDisabilityChanged, 'Disability changed must be false');
        Assert.areEqual(false, results[0].isNameAndTitleChanged, 'Name Title changed must be false');
        Assert.areEqual(false, results[0].otherChangeDetails.containsIgnoreCase('GENDER'), 'Gender must be present in the other change details');

    }

    @isTest
    static void test_compareCustomerDetailsGenderAndOtherChanges(){
        CustomerDetailsInput myNewDetails = (CustomerDetailsInput) JSON.deserialize(JSON.serialize(myDetails), CustomerDetailsInput.class);
        myNewDetails.genderIdentity = CustomerDetailsDecorator.GENDER_FEMALE;
        myNewDetails.mailingAddress = 'New Street, New Town, ZZ1 1ZZ';
        List<CustomerDetailsChangeResult> results;
        Test.startTest();
        IdentifyCustomerChangesInput myInput = new IdentifyCustomerChangesInput();
        myInput.oldCustomerDetails = myDetails;
        myInput.newCustomerDetails = myNewDetails;
        results = IdentifyCustomerDetailsChangeInvocable.identifyChanges(
            new List<IdentifyCustomerChangesInput>{myInput}
        );
        Test.stopTest();
        Assert.areEqual(false, results[0].hasNameChanges, 'Name changes should be true');
        Assert.areEqual(true, results[0].isGenderChanged, 'Gender changes should be true');
        Assert.areEqual(false, results[0].isNameAndGenderChanged, 'isNameAndGenderChanged changes should be true');
        Assert.areEqual(true, results[0].hasOtherChanges, 'Other changes should be false');
        Assert.areEqual(false, results[0].isFNChanged, 'First Name changed must be true');
        Assert.areEqual(false, results[0].isMNChanged, 'Middle Name changed must be false');
        Assert.areEqual(false, results[0].isLNChanged, 'Last Name changed must be false');
        Assert.areEqual(false, results[0].isDOBChanged, 'DOB changed must be false');
        Assert.areEqual(false, results[0].isEmailChanged, 'Email changed must be false');
        Assert.areEqual(false, results[0].isMobileChanged, 'Mobile changed must be false');
        Assert.areEqual(false, results[0].isDisabilityChanged, 'Disability changed must be false');
        Assert.areEqual(false, results[0].isNameAndTitleChanged, 'Name Title changed must be false');
        Assert.areEqual(true, results[0].otherChangeDetails.containsIgnoreCase('GENDER'), 'Gender must be present in the other change details');

    }


    @isTest
    static void test_negativeCustomerDetailsChanges(){
        List<CustomerDetailsChangeResult> results;
        String expected = 'Both instances must be non-null.';
        String actual;
        Test.startTest();
        IdentifyCustomerChangesInput myInput = new IdentifyCustomerChangesInput();
        myInput.oldCustomerDetails = myDetails;
        myInput.newCustomerDetails = null;
        try {
            results = IdentifyCustomerDetailsChangeInvocable.identifyChanges(
                new List<IdentifyCustomerChangesInput>{myInput}
            );
        }catch(Exception exp) {
            actual=exp.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(expected, actual, 'Exception must be throw at this point');
    }

    @isTest
    static void test_yhdisablityChanges(){
        CustomerDetailsInput myDetailsdisability = new CustomerDetailsInput();
        myDetailsdisability.yhDisability = 'a;b;c';
        myDetailsdisability.mailingAddress = 'Streeet, Town, ZZ1 1ZZ';
        myDetailsdisability.yhMaritalStatus = CustomerDetailsDecorator.MARITAL_STATUS_MARRIED;
        myDetailsdisability.yhEthnicity = CustomerDetailsDecorator.ETHINICITY_INDIAN;
        CustomerDetailsInput myNewDetails = (CustomerDetailsInput) JSON.deserialize(JSON.serialize(myDetailsdisability), CustomerDetailsInput.class);
        myNewDetails.yhDisability = 'c;a;b';
        List<CustomerDetailsChangeResult> results;
        String expected = 'Both instances must be non-null.';
        String actual;
        Test.startTest();
        IdentifyCustomerChangesInput myInput = new IdentifyCustomerChangesInput();
        myInput.oldCustomerDetails = myDetailsdisability;
        myInput.newCustomerDetails = myNewDetails;
        try {
            results = IdentifyCustomerDetailsChangeInvocable.identifyChanges(
                new List<IdentifyCustomerChangesInput>{myInput}
            );
        }catch(Exception exp) {
            actual=exp.getMessage();
        }
        Test.stopTest();
        Assert.isNull(actual, 'Exception should be null');
        Assert.areEqual(false, results[0].isDisabilityChanged, 'Disability changed must be false');
    }
    
}