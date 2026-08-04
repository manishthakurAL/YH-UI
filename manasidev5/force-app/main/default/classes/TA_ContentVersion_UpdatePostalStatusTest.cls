@isTest
public with sharing class TA_ContentVersion_UpdatePostalStatusTest {
    
    @TestSetup
    static void makeData(){
        ContentVersion cv = UthContentVersion.build();
        insert cv;
    }

    @isTest 
    static void test_ContentVersionWithPostalStatus() {
        ContentVersion cv = UthContentVersion.getAll().get(0);

        Test.startTest();

        cv.CongaCustomField__c = 'Ready for Post;2nd';

        update cv;

        Test.stopTest();

        cv = UthContentVersion.getAll().get(0);

        Assert.areEqual('Ready for Post', cv.PostalStatus__c, 'Postal Status must be ready for post');
        Assert.areEqual('2nd', cv.MailClass__c, 'Mail class must be 2nd');
        Assert.areEqual(null, cv.CongaCustomField__c, 'cleanup must be done');

    }
}