public with sharing class TA_Case_AU_GeneralEnquiryOwnerFeedPost implements TriggerAction.AfterUpdate{

    public void afterUpdate(List<Case> newList, List<Case> oldList){
        List<FeedItem> feedItems = new List<FeedItem>();
        Map<Id, Case> oldCasesMap = new Map<Id, Case>(oldList);
        for(Case caseRecord: newList){            
            if (caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_GENERAL_ENQUIRY 
                    && caseRecord.OwnerId != oldCasesMap.get(caseRecord.Id).OwnerId) {
                String body = CaseDecorator.CASE_GENERAL_ENQUIRY_OWNER_FEED_MSG + oldCasesMap.get(caseRecord.Id).CaseReAssignmentReason__c;
                feedItems.add(new FeedItem(ParentId = caseRecord.Id, Body = body));
            }
        }
        if(!feedItems.isEmpty()){
            insert feedItems;
        }
    }
}