@isTest
private class TA_Account_BU_SynchIntegrationFieldsTest {

    @testSetup
    static void setupData() {
        Id roleId = UthUserRole.getUserRole(UserDecorator.ROLE_PLACE_MANAGER)?.Id;
        Id adminProfileId = UthProfile.getProfileUsingName(UserDecorator.PROFILE_SYSTEM_ADMINISTRATOR)[0]?.Id;
        User adminUser = UthUser.buildUser(roleId,adminProfileId,'fname1','lname1');
        insert adminUser;
        System.runAs(adminUser){
            Account aPerson = UthAccount.buildPersonAccount('Test', 'Test123','test788787878901test@test.com');
            insert aPerson;
        }
    }

    @isTest
    static void testSetIntegrationStatusReadyOnUpdate() {
        List<Account> allPersonAccounts = UthAccount.getAllPersonAccount();
        Test.startTest();
        for(Account aRecord: allPersonAccounts){
            aRecord.DistinctActiveMembershipTypes__pc = AccountDecorator.SOLE_TENANT;
        }
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);
        Test.stopTest();

        for(Account aRecord: UthAccount.getAllPersonAccount()){
            System.assertEquals(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY, aRecord.get(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD));
        }
    }

    @isTest
    static void testSetIntegrationStatusReadyOnUpdateNegative() {
        List<Account> allPersonAccounts = UthAccount.getAllPersonAccount();
        Test.startTest();
        for(Account aRecord: allPersonAccounts){
            aRecord.DistinctActiveMembershipTypes__pc = AccountDecorator.HOUSEHOLD_MEMBER;
        }
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);
        Test.stopTest();

        for(Account aRecord: UthAccount.getAllPersonAccount()){
            System.assertEquals(NULL, aRecord.get(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD));
        }
    }

    @isTest
    static void testSetIntegrationStatusFurtherUpdYHNumberNotSet() {
        List<Account> allPersonAccounts = UthAccount.getAllPersonAccount();
        
        for(Account aRecord: allPersonAccounts){
            aRecord.DistinctActiveMembershipTypes__pc = AccountDecorator.SOLE_TENANT;
            aRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_IN_PROGRESS;
        }
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);

        for(Account aRecord: allPersonAccounts){
            aRecord.lastName = 'lname2';
        }
        Test.startTest();
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);
        Test.stopTest();

        for(Account aRecord: UthAccount.getAllPersonAccount()){
            System.assertEquals(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_IN_PROGRESS_FURUPD, aRecord.get(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD));
        }
    }

    @isTest
    static void testSetIntegrationStatusFurtherUpdYHNumberNotSetNegative() {
        List<Account> allPersonAccounts = UthAccount.getAllPersonAccount();

        for(Account aRecord: allPersonAccounts){
            aRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_IN_PROGRESS;
        }
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);

        for(Account aRecord: allPersonAccounts){
            aRecord.lastName = 'Test123';
        }
        Test.startTest();
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);
        Test.stopTest();

        for(Account aRecord: UthAccount.getAllPersonAccount()){
            System.assertEquals(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_IN_PROGRESS, aRecord.get(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD));
        }
    }

    @isTest
    static void testSetIntegrationStatusFurtherUpdYHNumberSet() {
        List<Account> allPersonAccounts = UthAccount.getAllPersonAccount();
        for(Account aRecord: allPersonAccounts){
            aRecord.YH_Person_Number__c = '12345';
            aRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_IN_PROGRESS;
        }
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);

        for(Account aRecord: allPersonAccounts){
            aRecord.lastName = 'lname2';
        }
        Test.startTest();
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);
        Test.stopTest();

        for(Account aRecord: UthAccount.getAllPersonAccount()){
            System.assertEquals(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_IN_PROGRESS_FURUPD, aRecord.get(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD));
        }
    }

    @isTest
    static void testSetIntegrationStatusFurtherUpdYHNumberSetNegative() {
        List<Account> allPersonAccounts = UthAccount.getAllPersonAccount();
        for(Account aRecord: allPersonAccounts){
            aRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_IN_PROGRESS;
        }
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);

        for(Account aRecord: allPersonAccounts){
            aRecord.lastName = 'Test123';
        }
        Test.startTest();
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);
        Test.stopTest();

        for(Account aRecord: UthAccount.getAllPersonAccount()){
            System.assertEquals(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_IN_PROGRESS, aRecord.get(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD));
        }
    }    

     @isTest
    static void testSetIntegrationStatusSynchedAsynchSFStatusInProgress() {
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        List<Account> allPersonAccounts = UthAccount.getAllPersonAccount();
        for(Account aRecord: allPersonAccounts){
            aRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_IN_PROGRESS;
            aRecord.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_SF_TO_EXTERNAL_ASYNC;
        }
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);
        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');

       
        Test.startTest();
        for(Account aRecord: allPersonAccounts){
            aRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED;    
        }  
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);      
        Test.stopTest();

        for(Account aRecord: UthAccount.getAllPersonAccount()){
            System.assertEquals(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED, aRecord.get(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD));
        }
    }
    
     @isTest
    static void testSetIntegrationStatusSynchedAsynchSFStatusInProgressFurtherUpdate() {
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        List<Account> allPersonAccounts = UthAccount.getAllPersonAccount();
        for(Account aRecord: allPersonAccounts){
            aRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_IN_PROGRESS_FURUPD;
            aRecord.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_SF_TO_EXTERNAL_ASYNC;
        }
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);
        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');

       
        Test.startTest();
        for(Account aRecord: allPersonAccounts){
            aRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED;    
        }  
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);      
        Test.stopTest();

        for(Account aRecord: UthAccount.getAllPersonAccount()){
            System.assertEquals(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY, aRecord.get(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD));
        }
    }  
    
    @isTest
    static void testSetIntegrationStatusSynchAsynchSFStatusReady() {
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        List<Account> allPersonAccounts = UthAccount.getAllPersonAccount();
        for(Account aRecord: allPersonAccounts){
            aRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY;
            aRecord.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_SF_TO_EXTERNAL_ASYNC;
        }
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);
        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');

       
        Test.startTest();
       
            for(Account aRecord: allPersonAccounts){
                aRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_SYNCHED;    
            }  
            Database.saveResult[] results = Database.update(allPersonAccounts, false, AccessLevel.SYSTEM_MODE);   
            for (Database.SaveResult sr : results) {
                
                for (Database.Error err : sr.getErrors()) {
                    Assert.areEqual(Label.AsynchErrorMessage, err.getMessage());
                }
                  
            }   
        Test.stopTest(); 
    }  

     @isTest
    static void testSetIntegrationStatusErrorAsynchSFStatusInProgressFurtherUpdate() {
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        List<Account> allPersonAccounts = UthAccount.getAllPersonAccount();
        for(Account aRecord: allPersonAccounts){
            aRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_IN_PROGRESS_FURUPD;
            aRecord.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_SF_TO_EXTERNAL_ASYNC;
        }
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);
        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');

       
        Test.startTest();
        for(Account aRecord: allPersonAccounts){
            aRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_ERROR;    
        }  
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);      
        Test.stopTest();

        for(Account aRecord: UthAccount.getAllPersonAccount()){
            System.assertEquals(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY, aRecord.get(SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_FIELD));
        }
    }  
    
    @isTest
    static void testSetIntegrationStatusErrorsynchSFStatusReady() {
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        List<Account> allPersonAccounts = UthAccount.getAllPersonAccount();
        for(Account aRecord: allPersonAccounts){
            aRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_READY;
            aRecord.LastSynchDirection__c = SObjectRecordChangeDetectorDecorator.LAST_SYNCH_DIRECTION_SF_TO_EXTERNAL_ASYNC;
        }
        Database.update(allPersonAccounts, AccessLevel.SYSTEM_MODE);
        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');

       
        Test.startTest();
       
            for(Account aRecord: allPersonAccounts){
                aRecord.IntegrationStatus__c = SObjectRecordChangeDetectorDecorator.INTEGRATION_STATUS_ERROR;    
            }  
            Database.saveResult[] results = Database.update(allPersonAccounts, false, AccessLevel.SYSTEM_MODE);   
            for (Database.SaveResult sr : results) {
                
                for (Database.Error err : sr.getErrors()) {
                    Assert.areEqual(Label.AsynchErrorMessage, err.getMessage());
                }
                  
            }   
        Test.stopTest(); 
    }  
}