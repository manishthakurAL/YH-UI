@isTest
public with sharing class RecordLookupControllerTest {
   
    @TestSetup
    static void makeData(){
        Account pAccount = UthAccount.build();
        insert pAccount;

        Contact pContact = UthContact.build(
            new Map<String, Object> {
                'AccountId' => pAccount.Id,
                'FirstName' => 'John',
                'LastName' => 'me',
                'MailingStreet' => 'Street 1',
                'MailingCity' => 'City 1',
                'MailingPostalCode' => 'CR0 5JQ',
                'MailingCountry' => 'GB'
            }
        );
        insert pContact;

    }

    @isTest
    static void test_fetchRecentRecords() {
        RecordLookupController.SearchWrapper inputWrapper = new RecordLookupController.SearchWrapper(
            JSON.serialize(new Map<String, Object>{
                'objectApiName' => 'Contact',
                'fieldApiName' => 'Name',
                'otherFieldApiName' => 'MailingStreet,MailingCity,MailingPostalCode',
                'searchFieldApiName' => 'MailingStreet,MailingCity,MailingPostalCode',
                'searchString' => 'John',
                'sortByField' => 'CreatedDate Desc'
            })
        );
        Test.startTest();
        RecordLookupController.ResultWrapper[] results = RecordLookupController.fetchRecentRecords(inputWrapper);
        //Assert.areEqual(1, results.size(), 'Must return 1 contact record.');
        Test.stopTest(); 

    }

    @isTest
    static void test_fetchRecordsBySOQL() {
        RecordLookupController.SearchWrapper inputWrapper = new RecordLookupController.SearchWrapper(
            JSON.serialize(new Map<String, Object>{
                'enableSOSL' => false,
                'objectApiName' => 'Contact',
                'fieldApiName' => 'Name',
                'otherFieldApiName' => 'MailingStreet,MailingCity,MailingPostalCode',
                'searchFieldApiName' => 'Name,MailingStreet,MailingCity,MailingPostalCode',
                'searchString' => 'John',
                'sortByField' => 'CreatedDate Desc'
            })
        );
        Test.startTest();
        RecordLookupController.ResultWrapper[] results = RecordLookupController.fetchRecords(inputWrapper);
        Assert.areEqual(1, results.size(), 'Must return 1 contact record.');
        Test.stopTest(); 

    }

    @isTest
    static void test_fetchRecordsBySOSL() {
        RecordLookupController.SearchWrapper inputWrapper = new RecordLookupController.SearchWrapper(
        JSON.serialize(new Map<String, Object>{
            'enableSOSL' => true,
            'objectApiName' => 'Contact',
            'fieldApiName' => 'Name',
            'otherFieldApiName' => 'MailingStreet,MailingCity,MailingPostalCode',
            'searchFieldApiName' => 'Name,MailingStreet,MailingCity,MailingPostalCode',
            'searchString' => 'John',
            'sortByField' => 'CreatedDate Desc'
        }));

        Test.startTest();
        Test.setFixedSearchResults(new List<Id>{UthContact.getAll()[0].Id});
        RecordLookupController.ResultWrapper[] results = RecordLookupController.fetchRecords(inputWrapper);
        Assert.areEqual(1, results.size(), 'Must return 1 contact record.');
        Test.stopTest(); 

    }


}