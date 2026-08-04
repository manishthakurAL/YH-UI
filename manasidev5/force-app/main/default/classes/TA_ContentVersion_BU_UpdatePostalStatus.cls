public with sharing class TA_ContentVersion_BU_UpdatePostalStatus implements TriggerAction.BeforeUpdate {

    public void beforeUpdate(List<ContentVersion> newList, List<Case> oldList){
        for (ContentVersion cv: newList) {

            if (String.isNotBlank(cv.CongaCustomField__c)) {

                String[] customfieldValues = EncodingUtil.urlDecode(cv.CongaCustomField__c,'UTF-8').split(';');

                if (customfieldValues.size() > 0) {
                    cv.PostalStatus__c = customfieldValues[0].trim();
                }

                if (customfieldValues.size() > 1) {
                    cv.MailClass__c = customfieldValues[1].trim();
                }

                cv.CongaCustomField__c = null;

            }
        }
    }
}