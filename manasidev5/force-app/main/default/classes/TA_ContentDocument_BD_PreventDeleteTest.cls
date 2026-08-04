@isTest
public with sharing class TA_ContentDocument_BD_PreventDeleteTest {
    @testSetup
    static void setUpTestData(){
            TriggerBase.bypass('Account');
            TriggerBase.bypass('Contact');
            TriggerBase.bypass('Case');

            Account account = UthAccount.build();
            insert account;

            Contact contact = UthContact.build(account.Id);
            insert contact;

            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('Contact');
            TriggerBase.clearBypass('Case');
    }

    @isTest
    static void test_ContentDocumentDelete(){
        UthFeatureSwitches.enableSafeguardingRT();
        Exception myException;
        String expectedErrorMsg = TA_ContentDocument_BD_PreventDelete.ERROR_MESSAGE;
        String actualErrorMsg = '';
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_DELETE_CONTENT_DOCUMENT).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(UserInfo.getUserId(), permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet( UserInfo.getUserId(), permissionSetId);
            }
            PermissionEvaluator.permissionSetIds.add(permissionSetId);
            TriggerBase.bypass('Case');
            Case caseRecord = UthCase.buildSafeguardingCase(UthContact.getAll()[0].Id);
            caseRecord.ReporterType__c = CaseDecorator.REPORTER_TYPE_PERSONATRISK;
            insert caseRecord;
            UthCase.createCaseShareRecords(caseRecord.Id,  UserInfo.getUserId(), 'Edit','Manual');
            TriggerBase.clearBypass('Case');    
            ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = UthCase.getAll()[0].id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            Test.startTest();
            try {
                delete documents;
            }catch(Exception exp){
                actualErrorMsg = exp.getMessage();
                myException = exp;
            }
            Test.stopTest();
        }
        Assert.areEqual(false, actualErrorMsg.contains(expectedErrorMsg), 'Should not throw an error when owner assignment');
        Assert.areEqual(false, actualErrorMsg.contains(expectedErrorMsg), 'Should not throw an error when a document is deleted');
        Assert.isNull(myException, 'Permissions setup for file deletion');
    }
    
    @isTest
    static void test_ContentDocumentDeleteFailure(){
        UthFeatureSwitches.enableSafeguardingRT();
        Exception myException;
        String expectedErrorMsg = TA_ContentDocument_BD_PreventDelete.ERROR_MESSAGE;
        String actualErrorMsg = '';
        System.runAs(new User(Id = UserInfo.getUserId())){
            TriggerBase.bypass('Case');
            Case caseRecord = UthCase.buildSafeguardingCase(UthContact.getAll()[0].Id);
            caseRecord.ReporterType__c = CaseDecorator.REPORTER_TYPE_PERSONATRISK;
            insert caseRecord;
            UthCase.createCaseShareRecords(caseRecord.Id,  UserInfo.getUserId(), 'Edit','Manual');
            TriggerBase.clearBypass('Case');    
            ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = UthCase.getAll()[0].id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            Test.startTest();
            try {
                delete documents;
            }catch(Exception exp){
                actualErrorMsg = exp.getMessage();
                myException = exp;
            }
            Test.stopTest();
        }
        Assert.areEqual(true, actualErrorMsg.contains(expectedErrorMsg), 'Should throw an error when deleting document');
        Assert.isNotNull(myException, 'Delete document permission not assigned');
    }
}