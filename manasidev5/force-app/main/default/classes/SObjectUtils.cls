public with sharing class SObjectUtils {
    public static String getSObjectTypeFromId(Id recordId) {
        String type;
        if (recordId != null) {
            type = recordId.getSObjectType().getDescribe().getName();
        }
        return type;
    }
}