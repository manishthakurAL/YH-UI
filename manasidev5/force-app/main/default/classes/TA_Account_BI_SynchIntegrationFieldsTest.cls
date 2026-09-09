@isTest
private class TA_Account_BI_SynchIntegrationFieldsTest {

    @isTest
    static void testSetCreatedInSalesforceSystemOnInsert() {
        Account aPerson = UthAccount.buildPersonAccount('Test', 'Test123','test788787878901test@test.com');
        Test.startTest();
        insert aPerson;
        Test.stopTest();

        for(Account aRecord: UthAccount.getAllPersonAccount()){
            System.assertEquals(SObjectRecordChangeDetectorDecorator.CREATED_IN_SYSTEM_SALESFORCE, aRecord.get(SObjectRecordChangeDetectorDecorator.CREATED_IN_SYSTEM));
        }
    }

    @isTest
    static void testSetCreatedInOrchardSystemOnInsert() {
        Account aPerson = UthAccount.buildPersonAccountWithYHPersonNumber('Test', 'Test123','12345');
        Test.startTest();
        insert aPerson;
        Test.stopTest();
        
        for(Account aRecord: UthAccount.getAllPersonAccount()){
            System.assertEquals(SObjectRecordChangeDetectorDecorator.CREATED_IN_SYSTEM_ORCHARD, aRecord.get(SObjectRecordChangeDetectorDecorator.CREATED_IN_SYSTEM));
        }
    }
}