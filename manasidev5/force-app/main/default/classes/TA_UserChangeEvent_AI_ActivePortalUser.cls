public class TA_UserChangeEvent_AI_ActivePortalUser implements TriggerAction.AfterInsert{
    
    @TestVisible
    private Set<Id> allUserIds = new Set<Id>();
    @TestVisible
    private Set<Id> contactIdsOfActiveUser = new Set<Id>();
    @TestVisible
    private Set<Id> contactIdsOfInActiveUser = new Set<Id>();

    public void afterInsert(List<UserChangeEvent> newList){
        for(UserChangeEvent eventRec : newList) {
            EventBus.ChangeEventHeader header = eventRec.ChangeEventHeader;
            if(header != null){
                for (String recId : header.recordIds) {
                     if((header.changeType == UserChangeEventDecorator.CHANGETYPE_CREATE) &&
                            eventRec.IsActive == TRUE && 
                            eventRec.ProfileId == UserService.customerPortalProfileId){
                        this.contactIdsOfActiveUser.add(eventRec.ContactId);
                     } else if(header.changeType == UserChangeEventDecorator.CHANGETYPE_UPDATE &&
                            header.changedFields.contains(UserChangeEventDecorator.CHANGED_FIELD_ACTIVE)){
                        this.allUserIds.add((Id) recId);
                    }
                }
            }
        }

        if(!this.allCustomerPortalUserMap.isEmpty()){
            for(User user : this.allCustomerPortalUserMap.values()){
                if(user.IsActive == true){
                    this.contactIdsOfActiveUser.add(user.ContactID);
                }else if(user.IsActive == false){
                    this.contactIdsOfInActiveUser.add(user.ContactID);
                }
            }
        }
 
        if(!this.activatedUserMemberIds.isEmpty()){
            new ManageCustomerDataSharingService(
                this.activatedUserMemberIds, 
                ManageCustomerDataSharingService.CHANGE_TYPE.RECORD_ACTVIATED,
                ManageCustomerDataSharingService.TRIGGER_CONTEXT.UPDATE_RECORD).shareRecords();
        }

        if(!this.recordSharingCaseIds.isEmpty()){
          ShareSObjectQueueable shareSObjectQueueable = new ShareSObjectQueueable(this.recordSharingCaseIds);
          System.enqueueJob(shareSObjectQueueable);
        }

        if(!this.deactivatedUserMemberIds.isEmpty()){
            new ManageCustomerDataSharingService(
                this.deactivatedUserMemberIds, 
                ManageCustomerDataSharingService.CHANGE_TYPE.RECORD_DEACTIVATED,
                ManageCustomerDataSharingService.TRIGGER_CONTEXT.UPDATE_RECORD).shareRecords();
        }

        if(!this.removeSharingCaseIds.isEmpty()){
            new ManageCustomerDataSharingService(
                this.removeSharingCaseIds, 
                ManageCustomerDataSharingService.CHANGE_TYPE.RECORD_REMOVE_SHARING,
                ManageCustomerDataSharingService.TRIGGER_CONTEXT.UPDATE_RECORD).shareRecords();
        }
    }

    private Map<Id, User> allCustomerPortalUserMap {
        get{
            if(this.allCustomerPortalUserMap == null){ 
                this.allCustomerPortalUserMap = new Map<Id, User>();
                if(!this.allUserIds.isEmpty()){
                        this.allCustomerPortalUserMap = new Map<Id, User>([SELECT Id, UserType, Profile.Name, ContactId, IsActive 
                                        FROM User 
                                        WHERE Id IN : this.allUserIds 
                                        AND Profile.Name =: UserDecorator.PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN]);
                }
            } 
            return this.allCustomerPortalUserMap; 
        } 
        set; 
    }

    private List<Id> activatedUserMemberIds{
        get{
            if(this.activatedUserMemberIds == null){
                this.activatedUserMemberIds = new List<Id>();
                if(!this.contactIdsOfActiveUser.isEmpty()){
                        for(Member__c member : [SELECT Id
                                                FROM Member__c 
                                                WHERE Contact__c IN: this.contactIdsOfActiveUser AND
                                                    IsActive__c = TRUE AND
                                                    (Type__c =: MemberDecorator.TYPE_SOLO OR 
                                                    Type__c =: MemberDecorator.TYPE_JOINT)]) {
                        this.activatedUserMemberIds.add(member.Id);
                    }
                }
            }
            return this.activatedUserMemberIds;
        }
        set;
    }

    private List<Id> recordSharingCaseIds{
        get{
            if(this.recordSharingCaseIds == null){
                this.recordSharingCaseIds = new List<Id>();
                if(!this.contactIdsOfActiveUser.isEmpty()){
                        for(Case caseRecord : [SELECT Id
                                        FROM Case 
                                        WHERE ContactID IN: this.contactIdsOfActiveUser AND CustomerSharingReasons__c != null]) {
                        this.recordSharingCaseIds.add(caseRecord.Id);
                    }
                }
            }
            return this.recordSharingCaseIds;
        }
        set;
    }

    private List<Id> deactivatedUserMemberIds{
        get{
            if(this.deactivatedUserMemberIds == null){
                this.deactivatedUserMemberIds = new List<Id>();
                if(!this.contactIdsOfInActiveUser.isEmpty()){
                        for(Member__c member : [SELECT Id
                                                FROM Member__c 
                                                WHERE Contact__c IN: this.contactIdsOfInActiveUser AND
                                                    (Type__c =: MemberDecorator.TYPE_SOLO OR 
                                                    Type__c =: MemberDecorator.TYPE_JOINT)]) {
                        this.deactivatedUserMemberIds.add(member.Id);
                    }
                }
            }
            return this.deactivatedUserMemberIds;
        }
        set;
    }

    private List<Id> removeSharingCaseIds{
        get{
            if(this.removeSharingCaseIds == null){
                this.removeSharingCaseIds = new List<Id>();
                if(!this.contactIdsOfInActiveUser.isEmpty()){
                    for(Case cse : [SELECT Id
                                        FROM Case 
                                        WHERE ContactID IN: this.contactIdsOfInActiveUser AND CustomerSharingReasons__c != null]) {
                        this.removeSharingCaseIds.add(cse.Id);
                    }
                }
            }
            return this.removeSharingCaseIds;
        }
        set;
    }
}