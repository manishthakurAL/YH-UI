public without sharing class TA_Case_BIU_GeneralEnquiryTypeMapping implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate{
    
    public void beforeInsert(List<Case> newList){
        List<Case> newCaseList = new List<Case>();
        Id recordTypeId = CaseDecorator.RECORD_TYPE_ID_GENERAL_ENQUIRY;
        for(Case cRec : newList){
            if(cRec.RecordTypeId == recordTypeId){
                newCaseList.add(cRec);
            }
        }

        if(!newList.isEmpty()){
            new CaseGeneralEnquiryTypeMappingService(newList).execute();
        }
    }

    public void beforeUpdate(List<Case> newList, List<Case> oldList){
        List<Case> updateCaseList = new List<Case>();
        Map<Id, Case> oldCaseMap = new Map<Id, Case>(oldList);
        Id recordTypeId = CaseDecorator.RECORD_TYPE_ID_GENERAL_ENQUIRY;
        for(Case cRec : newList){
            if(cRec.RecordTypeId == recordTypeId && 
                    (cRec.CaseType__c != oldCaseMap.get(cRec.Id).CaseType__c ||
                    cRec.EnquiryType__c != oldCaseMap.get(cRec.Id).EnquiryType__c ||
                    cRec.CustomerCaseType__c != oldCaseMap.get(cRec.Id).CustomerCaseType__c ||
                    cRec.CustomerEnquiryType__c != oldCaseMap.get(cRec.Id).CustomerEnquiryType__c)
            ){
                updateCaseList.add(cRec);
            }
        }
        if(!updateCaseList.isEmpty()){
            new CaseGeneralEnquiryTypeMappingService(updateCaseList).execute();
        }
    }   
    
}