@isTest
public with sharing class DraftFileCleanupBatchTest {
    @TestSetup
    static void makeData(){
        UthFeatureSwitches.enableCustomerRT();
        OrgSetting__c  setting = UthOrgSetting.build();
        setting.NoOfHoursForFileCleanup__c = -12;
        upsert setting;
        
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        TriggerBase.bypass('Case');

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact;

        Case caseRecord = UthCase.buildCustomerCase(UthContact.getAll()[0].Id);
        insert caseRecord;

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        TriggerBase.clearBypass('Case');
    }

    @isTest
    static void testDraftFileCleanupBatch(){
        List<DraftContainer__c> draftContainers = new List<DraftContainer__c>();
        for(Integer i=0; i<2; i++){
           draftContainers.add(UthDraftContainer.build(UthCase.getAll()[0].Id, UthContact.getAll()[0].Id));
        }
        insert draftContainers;
        List<ContentVersion> cvs = new List<ContentVersion>();
        for(Integer i=0; i < 2; i++){
            cvs.add(UthContentVersion.build());
        }
        insert cvs;
        cvs = UthContentVersion.getAll();
        insert UthContentDocumentLink.build(cvs[0].ContentDocumentId, draftContainers[0].Id );
        insert UthContentDocumentLink.build(cvs[1].ContentDocumentId, draftContainers[1].Id );
        for(DraftContainer__c draftRecord: draftContainers){
            Test.setCreatedDate(draftRecord.Id, Datetime.now() - 1);
        }
        TriggerBase.bypass('ContentDocument');
        Test.startTest();
        DraftFileCleanupBatch draftFileCleanupBatch = new DraftFileCleanupBatch();
        Database.executeBatch(draftFileCleanupBatch);
        Test.stopTest();
        TriggerBase.clearBypass('ContentDocument');
        for(DraftContainer__c draftRecord: UthDraftContainer.getAll()){
            Assert.areEqual(draftRecord.Status__c, DraftContainerDecorator.STATUS_CLEANUP_PROCESSED);
        }
        ASSERT.areEqual(0, UthContentDocumentLink.getAllLinked(new Set<Id>{draftContainers[0].Id, draftContainers[1].Id}).size(), 'Content Document Links should be deleted');
        Assert.areEqual(0, UthContentDocument.getAll().size(), 'Content Document Links should be deleted');
    }

      @isTest
    static void testDraftFileCleanupBatchFileNotDeleted(){
        List<DraftContainer__c> draftContainers = new List<DraftContainer__c>();
        for(Integer i=0; i<2; i++){
           draftContainers.add(UthDraftContainer.build(UthCase.getAll()[0].Id, UthContact.getAll()[0].Id));
        }
        insert draftContainers;
        List<ContentVersion> cvs = new List<ContentVersion>();
        for(Integer i=0; i < 2; i++){
            cvs.add(UthContentVersion.build());
        }
        insert cvs;
        cvs = UthContentVersion.getAll();
        insert UthContentDocumentLink.build(cvs[0].ContentDocumentId, draftContainers[0].Id );
        insert UthContentDocumentLink.build(cvs[1].ContentDocumentId, draftContainers[1].Id );
        TriggerBase.bypass('ContentDocument');
        Test.startTest();
        DraftFileCleanupBatch draftFileCleanupBatch = new DraftFileCleanupBatch();
        Database.executeBatch(draftFileCleanupBatch);
        Test.stopTest();
        TriggerBase.clearBypass('ContentDocument');

        for(DraftContainer__c draftRecord: UthDraftContainer.getAll()){
            Assert.areEqual(draftRecord.Status__c, DraftContainerDecorator.STATUS_DRAFT,'Status should not be changed');
        }
        ASSERT.areNotequal(0, UthContentDocumentLink.getAllLinked(new Set<Id>{draftContainers[0].Id, draftContainers[1].Id}).size(), 'Content Document Links should not be deleted');
        Assert.areNotequal(0, UthContentDocument.getAll().size(), 'Content Document should not be deleted');

    }
}