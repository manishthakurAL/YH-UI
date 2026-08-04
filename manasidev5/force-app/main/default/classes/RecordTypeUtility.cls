public inherited Sharing class RecordTypeUtility {

    static Map<String, DescribeSObjectResult> SOBJECT_DESCRIBE_MAP;

    static {
        SOBJECT_DESCRIBE_MAP = new Map<String, DescribeSObjectResult>();
    }


    public static Id getRecordTypeIdByDeveloperName(String objectApiName, String recordTypeDeveloperName) {
        return getAllRecordTypeInfoByDeveloperName(objectApiName)
            .get(recordTypeDeveloperName)
            .getRecordTypeId();
    }

    public static Id getRecordTypeIdByName(String objectApiName, String recordTypeName) {
        return getAllRecordTypeInfoByName(objectApiName)
            .get(recordTypeName)
            .getRecordTypeId();
    }

    public static String getRecordTypeDeveloperNameById(String objectApiName, Id recordTypeId) {
        return getAllRecordTypeInfoById(objectApiName)
            .get(recordTypeId)
            .getDeveloperName();
    }

    public static String getRecordTypeNameById(String objectApiName, Id recordTypeId) {
        return getAllRecordTypeInfoById(objectApiName)
            .get(recordTypeId)
            .getName();
    }

    public static Map<String, RecordTypeInfo> getAllRecordTypeInfoByDeveloperName(String objectApiName) {
        return getDescribeSObjectResult(objectApiName)
            .getRecordTypeInfosByDeveloperName(); 
    }

    public static Map<String, RecordTypeInfo> getAllRecordTypeInfoByName(String objectApiName) {
        return getDescribeSObjectResult(objectApiName)
            .getRecordTypeInfosByName(); 
    }

    public static Map<Id, RecordTypeInfo> getAllRecordTypeInfoById(String objectApiName) {
        return getDescribeSObjectResult(objectApiName)
            .getRecordTypeInfosById();
    }

    private static DescribeSObjectResult getDescribeSObjectResult(String objectApiName) {

        if (!SOBJECT_DESCRIBE_MAP.containsKey(objectApiName)) {
            DescribeSObjectResult describeResult = (
                (SObject) Type.forName('Schema', objectApiName)
                  .newInstance()
                )
                .getSObjectType()
                .getDescribe();
            SOBJECT_DESCRIBE_MAP.put(objectApiName, describeResult);
        }
        return SOBJECT_DESCRIBE_MAP.get(objectApiName);
    }

}