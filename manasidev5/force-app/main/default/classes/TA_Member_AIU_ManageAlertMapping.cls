public with sharing class TA_Member_AIU_ManageAlertMapping implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate{

    public void afterInsert(List<Member__c> newList){
        List<Id> activeMembersIdList = new List<Id>();
        for(Member__c memRec : newList){
            if(memRec.IsActiveValue__c && 
                    (memRec.Type__c == MemberDecorator.TYPE_SOLO || 
                    memRec.Type__c == MemberDecorator.TYPE_JOINT)){
                activeMembersIdList.add(memRec.Id);
            }
        }
        
        if(!activeMembersIdList.isEmpty()){
            new ManageAlertMappingService(
                activeMembersIdList, 
                ManageAlertMappingService.CHANGE_TYPE.RECORD_ACTVIATED,
                ManageAlertMappingService.TRIGGER_CONTEXT.INSERT_RECORD).createAlertMappingRecords();
        }
    }

    public void afterUpdate(List<Member__c> newList, List<Member__c> oldList){
        Map<Id, Member__c> oldMap = new Map<Id, Member__c>(oldList);
        List<Id> activeMembersIdList = new List<Id>();
        for(Member__c memRec : newList){
            if(memRec.IsActiveValue__c && 
                    memRec.IsActiveValue__c != oldMap.get(memRec.Id).IsActiveValue__c &&
                    (memRec.Type__c == MemberDecorator.TYPE_SOLO || 
                    memRec.Type__c == MemberDecorator.TYPE_JOINT)){
                activeMembersIdList.add(memRec.Id);
            }
        }
        
        if(!activeMembersIdList.isEmpty()){
            new ManageAlertMappingService(
                activeMembersIdList, 
                ManageAlertMappingService.CHANGE_TYPE.RECORD_ACTVIATED,
                ManageAlertMappingService.TRIGGER_CONTEXT.UPDATE_RECORD).createAlertMappingRecords();
        }
    }
}