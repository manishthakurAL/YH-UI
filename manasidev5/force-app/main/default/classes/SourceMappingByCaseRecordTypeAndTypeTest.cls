@isTest
public with sharing class SourceMappingByCaseRecordTypeAndTypeTest {
   @TestSetup
   static void makeData(){
    
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        Account personAcc = UthAccount.buildPersonAccount();
        insert personAcc;
        Account account = UthAccount.build();
        insert account;
        Contact contact = UthContact.build(account.Id);
        insert contact;
        TriggerBase.clearBypass('Contact');
        TriggerBase.clearBypass('Account');
   }



   @isTest
   static void testCheckWithCaseTypeRecordType(){
        List<SourceMappingbyCaseRTandType__mdt> testSourceMappingConfig =
            (List<SourceMappingbyCaseRTandType__mdt>) JSON.deserialize('[{"RecordType":"Tenancy","CreateFromSObject__c":"Contact","RelationoftheRecordtoCase__c":"Reporter", "DeveloperName" :"TenancyRT"}]' 
        ,List<SourceMappingbyCaseRTandType__mdt>.class);
        List<SourceMappingbyCaseRTandTypeDetail__mdt> testSourceMappingDetainConfig =
        (List<SourceMappingbyCaseRTandTypeDetail__mdt>) JSON.deserialize('[{ "CreateFromSObject__c":"PersonAccount","RelationoftheRecordtoCase__c":"Tenant","CaseType__c":"Abandoned goods"}]' 
            ,List<SourceMappingbyCaseRTandTypeDetail__mdt>.class);
        SourceMappingByCaseRecordTypeAndType.mappingRecord = testSourceMappingConfig;
        SourceMappingByCaseRecordTypeAndType.mappingDetails = testSourceMappingDetainConfig;
        List<SourceMappingByCaseRecordTypeAndType.Request> inputs = new List<SourceMappingByCaseRecordTypeAndType.Request>();
        SourceMappingByCaseRecordTypeAndType.Request input = new SourceMappingByCaseRecordTypeAndType.Request();
        input.recordId = UthAccount.getAllPersonAccount()[0].Id;
        input.caseType = CaseDecorator.TYPE_ABANDONED_GOODS;
        input.recordType = CaseDecorator.CASE_RECORDTYPE_TENANCYRT;
        input.validateIdWithCreateFromSobject = true;
        inputs.add(input);
        Test.startTest();
        List<SourceMappingByCaseRecordTypeAndType.Response> outputs = SourceMappingByCaseRecordTypeAndType.fetchTheRelevantCaseSourceDetails(inputs);
        Test.stopTest();
        Assert.areEqual(outputs[0].isAllowedToCreateCaseFromRecord, true);
        Assert.isTrue(outputs[0].relationOfRecordToCase.contains(CaseRoleDecorator.TENANT_ROLE));
   } 

   @isTest
   static void testCheckWithCaseTypeRecordTypeNotAllowedToCreateFromContact(){
        List<SourceMappingbyCaseRTandTypeDetail__mdt> testSourceMappingDetainConfig =
        (List<SourceMappingbyCaseRTandTypeDetail__mdt>) JSON.deserialize('[{ "CreateFromSObject__c":"PersonAccount","RelationoftheRecordtoCase__c":"Tenant","CaseType__c":"Abandoned goods"}]' 
            ,List<SourceMappingbyCaseRTandTypeDetail__mdt>.class);
        List<SourceMappingbyCaseRTandType__mdt> testSourceMappingConfig =
            (List<SourceMappingbyCaseRTandType__mdt>) JSON.deserialize('[{"RecordType":"Tenancy","CreateFromSObject__c":"Contact","RelationoftheRecordtoCase__c":"Reporter", "DeveloperName" :"TenancyRT"}]' 
        ,List<SourceMappingbyCaseRTandType__mdt>.class);   
        SourceMappingByCaseRecordTypeAndType.mappingRecord = testSourceMappingConfig;
        SourceMappingByCaseRecordTypeAndType.mappingDetails = testSourceMappingDetainConfig;
        List<SourceMappingByCaseRecordTypeAndType.Request> inputs = new List<SourceMappingByCaseRecordTypeAndType.Request>();
        SourceMappingByCaseRecordTypeAndType.Request input = new SourceMappingByCaseRecordTypeAndType.Request();
        input.recordId = UthContact.getAll()[0].Id;
        input.caseType = CaseDecorator.TYPE_ABANDONED_GOODS;
        input.recordType = CaseDecorator.CASE_RECORDTYPE_TENANCYRT;
        input.validateIdWithCreateFromSobject = true;
        inputs.add(input);
        Test.startTest();
        List<SourceMappingByCaseRecordTypeAndType.Response> outputs = SourceMappingByCaseRecordTypeAndType.fetchTheRelevantCaseSourceDetails(inputs);
        Test.stopTest();
        Assert.areEqual(outputs[0].isAllowedToCreateCaseFromRecord, false);
        Assert.isTrue(outputs[0].relationOfRecordToCase.contains(CaseRoleDecorator.TENANT_ROLE));
   } 

   @isTest
   static void testCheckWitBlankCaseType(){
    List<SourceMappingbyCaseRTandType__mdt> testSourceMappingConfig =
    (List<SourceMappingbyCaseRTandType__mdt>) JSON.deserialize('[{"RecordType":"Safeguarding","CreateFromSObject__c":"Contact","RelationoftheRecordtoCase__c":"Person at Risk", "DeveloperName" :"Safeguarding"}]' 
        ,List<SourceMappingbyCaseRTandType__mdt>.class);
        SourceMappingByCaseRecordTypeAndType.mappingRecord = testSourceMappingConfig;
        List<SourceMappingByCaseRecordTypeAndType.Request> inputs = new List<SourceMappingByCaseRecordTypeAndType.Request>();
        SourceMappingByCaseRecordTypeAndType.Request input = new SourceMappingByCaseRecordTypeAndType.Request();
        input.recordId = UthContact.getAll()[0].Id;
        input.recordType = CaseDecorator.TYPE_SAFEGUARING;
        input.validateIdWithCreateFromSobject = true;
        inputs.add(input);
        Test.startTest();
        List<SourceMappingByCaseRecordTypeAndType.Response> outputs = SourceMappingByCaseRecordTypeAndType.fetchTheRelevantCaseSourceDetails(inputs);
        Test.stopTest();
        Assert.areEqual(outputs[0].isAllowedToCreateCaseFromRecord, true);
        Assert.isTrue(outputs[0].relationOfRecordToCase.contains(CaseDecorator.REPORTER_TYPE_PERSONATRISK));
   }

   @isTest
   static void testCheckWithRelationToRecordCaseSystem(){
    List<SourceMappingbyCaseRTandType__mdt> testSourceMappingConfig =
    (List<SourceMappingbyCaseRTandType__mdt>) JSON.deserialize('[{"RecordType":"Safeguarding","CreateFromSObject__c":"Contact","RelationoftheRecordtoCase__c":"System", "DeveloperName" :"Safeguarding"}]' 
        ,List<SourceMappingbyCaseRTandType__mdt>.class);
        SourceMappingByCaseRecordTypeAndType.mappingRecord = testSourceMappingConfig;
        List<SourceMappingByCaseRecordTypeAndType.Request> inputs = new List<SourceMappingByCaseRecordTypeAndType.Request>();
        SourceMappingByCaseRecordTypeAndType.Request input = new SourceMappingByCaseRecordTypeAndType.Request();
        input.recordId = UthContact.getAll()[0].Id;
        input.recordType = CaseDecorator.TYPE_SAFEGUARING;
        input.validateIdWithCreateFromSobject = true;
        inputs.add(input);
        Test.startTest();
        List<SourceMappingByCaseRecordTypeAndType.Response> outputs = SourceMappingByCaseRecordTypeAndType.fetchTheRelevantCaseSourceDetails(inputs);
        Test.stopTest();
        Assert.areEqual(outputs[0].createNotAllowedForRT, true);
        Assert.isTrue(outputs[0].relationOfRecordToCase.contains(SourceMappingbyCaseRTandTypeDecorator.RELATIONOFRECORDTOCASESYSTEM));
   }
}