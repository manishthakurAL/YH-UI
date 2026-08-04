@isTest
public with sharing class TA_DraftContainer_BU_SubmitProcessTest {
   @TestSetup
   static void makeData(){
        UthFeatureSwitches.enableCustomerRT();
        
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
   static void testDraftContainerSubmit(){
        DraftContainer__c draftRecord = UthDraftContainer.build(UthCase.getAll()[0].Id, UthContact.getAll()[0].Id);
        insert draftRecord;
        List<ContentVersion> cvs = new List<ContentVersion>();
        for(Integer i=0; i < 2; i++){
            cvs.add(UthContentVersion.build());
        }
        insert cvs;
        cvs = UthContentVersion.getAll();
        insert UthContentDocumentLink.build(cvs[0].ContentDocumentId, draftRecord.Id );
        insert UthContentDocumentLink.build(cvs[1].ContentDocumentId, draftRecord.Id );
        Task aTask = UthTask.build(UthCase.getAll()[0].Id);
        aTask.ActivityDate = Date.today();
        insert aTask;
        Test.startTest();
            draftRecord.Status__c = DraftContainerDecorator.STATUS_SUBMITTED;
            update draftRecord;
        Test.stopTest();
        
        Assert.areEqual(DraftContainerDecorator.STATUS_PROCESSED, UthDraftContainer.getAll()[0].Status__c, 'Draft Container Status should be  Processed');
        Assert.areEqual(0, UthContentDocumentLink.getAllLinked(new Set<Id>{draftRecord.Id}).size(), 'Content Document Links should be deleted');
        Assert.areEqual(2, UthContentDocumentLink.getAllLinked(new Set<Id>{UthCase.getAll()[0].Id}).size(), 'Content Document Links should be created for case');
        Assert.areEqual(0, UthContentDocumentLink.getAllLinked(new Set<Id>{aTask.Id}).size(), 'Content Document Links should not be created for task');
   }

    @isTest
   static void testDraftContainerSubmitWithTask(){
        Task aTask = UthTask.build(UthCase.getAll()[0].Id);
        aTask.ActivityDate = Date.today();
        insert aTask;
        DraftContainer__c draftRecord = UthDraftContainer.buildWithTaskId(UthCase.getAll()[0].Id, UthContact.getAll()[0].Id, aTask.Id);
        insert draftRecord;
        List<ContentVersion> cvs = new List<ContentVersion>();
        for(Integer i=0; i < 2; i++){
            cvs.add(UthContentVersion.build());
        }
        insert cvs;
        cvs = UthContentVersion.getAll();
        insert UthContentDocumentLink.build(cvs[0].ContentDocumentId, draftRecord.Id );
        insert UthContentDocumentLink.build(cvs[1].ContentDocumentId, draftRecord.Id );
       
        Test.startTest();
            draftRecord.Status__c = DraftContainerDecorator.STATUS_SUBMITTED;
            update draftRecord;
        Test.stopTest();
        
        Assert.areEqual(DraftContainerDecorator.STATUS_PROCESSED, UthDraftContainer.getAll()[0].Status__c, 'Draft Container Status should be  Processed');
        Assert.areEqual(0, UthContentDocumentLink.getAllLinked(new Set<Id>{draftRecord.Id}).size(), 'Content Document Links should be deleted');
        Assert.areEqual(2, UthContentDocumentLink.getAllLinked(new Set<Id>{UthCase.getAll()[0].Id}).size(), 'Content Document Links should be created for case');
        Assert.areEqual(2, UthContentDocumentLink.getAllLinked(new Set<Id>{aTask.Id}).size(), 'Content Document Links should  be created for task');
   }

    @isTest
   static void testDraftContainerSubmitBulk(){
        List<DraftContainer__c> containers = new List<DraftContainer__c>();    
        Task aTask = UthTask.build(UthCase.getAll()[0].Id);
        aTask.ActivityDate = Date.today();
        insert aTask;
        DraftContainer__c draftRecord = UthDraftContainer.build(UthCase.getAll()[0].Id, UthContact.getAll()[0].Id);
        containers.add(draftRecord);
        DraftContainer__c draftRecord1 = UthDraftContainer.buildWithTaskId(UthCase.getAll()[0].Id, UthContact.getAll()[0].Id, aTask.Id);
        containers.add(draftRecord1);
        insert containers;
        
        List<ContentVersion> cvs = new List<ContentVersion>();
        for(Integer i=0; i < 2; i++){
            cvs.add(UthContentVersion.build());
        }
        insert cvs;
        cvs = UthContentVersion.getAll();
        insert UthContentDocumentLink.build(cvs[0].ContentDocumentId, UthDraftContainer.getAll()[0].Id );
        insert UthContentDocumentLink.build(cvs[1].ContentDocumentId, UthDraftContainer.getAll()[1].Id );
        Test.startTest();
            for(DraftContainer__c adraftRecord: containers){
                adraftRecord.Status__c = DraftContainerDecorator.STATUS_SUBMITTED;
            }
            update containers;
        Test.stopTest();
        Set<Id> draftIds = new Set<Id>();
        for(DraftContainer__c adraftRecord: UthDraftContainer.getAll()){
            draftIds.add(adraftRecord.Id);
            Assert.areEqual(DraftContainerDecorator.STATUS_PROCESSED, adraftRecord.Status__c, 'Draft Container Status should be  Processed');
        }

        Assert.areEqual(0, UthContentDocumentLink.getAllLinked(draftIds).size(), 'Content Document Links should be deleted');
        Assert.areEqual(2, UthContentDocumentLink.getAllLinked(new Set<Id>{UthCase.getAll()[0].Id}).size(), 'Content Document Links should be created for case');
        Assert.areEqual(1, UthContentDocumentLink.getAllLinked(new Set<Id>{aTask.Id}).size(), 'Content Document Links should  be created for task');
   }
}