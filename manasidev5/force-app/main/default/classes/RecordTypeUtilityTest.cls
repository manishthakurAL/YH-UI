@IsTest
private class RecordTypeUtilityTest {

    @isTest 
    static void test_recordTypeDeveloperName_by_Id() {
        Test.startTest();
        Id recordTypeId = RecordTypeUtility.getRecordTypeIdByDeveloperName(CaseDecorator.SOBJECT_TYPE_CASE, CaseDecorator.RECORD_TYPE_COMPLAINTS);
        String recordTypeDeveloperName = RecordTypeUtility.getRecordTypeDeveloperNameById(CaseDecorator.SOBJECT_TYPE_CASE, recordTypeId);
        Assert.areEqual( CaseDecorator.RECORD_TYPE_COMPLAINTS, recordTypeDeveloperName,'Correct record Type developer name should be returned');
        Test.stopTest();
    }

    @isTest 
    static void test_recordTypeName_by_Id() {
        Test.startTest();
        Id expectedRecordTypeId = RecordTypeUtility.getRecordTypeIdByDeveloperName(CaseDecorator.SOBJECT_TYPE_CASE, CaseDecorator.RECORD_TYPE_COMPLAINTS);
        String recordTypeName = RecordTypeUtility.getRecordTypeNameById(CaseDecorator.SOBJECT_TYPE_CASE, expectedRecordTypeId);
        String actualRecordTypeId = RecordTypeUtility.getRecordTypeIdByName(CaseDecorator.SOBJECT_TYPE_CASE, recordTypeName);
        String expectedRecordTypeName = [SELECT Name FROM RecordType WHERE Id = :expectedRecordTypeId limit 1].Name;
        Assert.areEqual( expectedRecordTypeName, recordTypeName,'Correct record Type name should be returned');
        Assert.areEqual( expectedRecordTypeId, actualRecordTypeId,'Correct record Type Id should be returned');
        Test.stopTest();
    }
    
}