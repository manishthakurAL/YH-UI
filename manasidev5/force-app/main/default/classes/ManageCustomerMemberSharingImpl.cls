public with sharing class ManageCustomerMemberSharingImpl implements IManageCustomerDataSharing{
    private List<Id> recordIds;

    private List<Member__c> members{
        get{
            if(this.members == null){
                this.members = new List<Member__c>();
                if(this.recordIds != null && !this.recordIds.isEmpty()){
                    for(Member__c member: [SELECT Id, Contact__c, Name, Tenancy__r.Name
                                            FROM Member__c 
                                            WHERE Id IN : this.recordIds]){
                        this.members.add(member);
                    }
                }
            }
            return this.members;
        }
        set;
    }

    private Map<Id, String> tenancyGrpNameByMemberIdMap{
        get{
            if(this.tenancyGrpNameByMemberIdMap == null){
                this.tenancyGrpNameByMemberIdMap= new Map<Id, String>();
                if(this.members != null && !this.members.isEmpty()){
                    for(Member__c member: this.members){
                        String groupName = new TenancyService().getGroupName(member.Tenancy__r.Name);
                        this.tenancyGrpNameByMemberIdMap.put(member.Id, groupName);
                    }
                }
            }
            return this.tenancyGrpNameByMemberIdMap;
        }
        set;
    }

    private Map<Id, Id> contactIdByMemberIdMap{
        get{
            if(this.contactIdByMemberIdMap == null){
                this.contactIdByMemberIdMap = new Map<Id, Id>();
                if(this.members != null && !this.members.isEmpty()){
                    for(Member__c member: this.members){
                        if(member.Contact__c != null){
                            this.contactIdByMemberIdMap.put(member.Id, member.Contact__c);
                        }
                    }
                }
            }
            
            return this.contactIdByMemberIdMap;
        }
        set;
    }

    private Map<Id, User> userByContactIdMap{
        get{
            if(this.userByContactIdMap == null){
                this.userByContactIdMap = new Map<Id, User>();
                if(!this.contactIdByMemberIdMap.isEmpty()){
                    for(User user : [SELECT Id, ContactId, IsActive
                                        FROM User 
                                        WHERE ContactId IN: this.contactIdByMemberIdMap.values() AND 
                                            Profile.Name =: UserDecorator.PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN]){
                        this.userByContactIdMap.put(user.ContactId, user);
                    }
                }
            }
            return this.userByContactIdMap;
        }
        set;
    }

    private Map<Id, Id> userIdByContactIdMap{
        get{
            if(this.userIdByContactIdMap == null){
                this.userIdByContactIdMap = new Map<Id, Id>();
                if(!this.userByContactIdMap.isEmpty()){
                    for(User user : this.userByContactIdMap.values()){
                        this.userIdByContactIdMap.put(user.ContactId, user.Id);
                    }
                }
            }
            
            return this.userIdByContactIdMap;
        }
        set;
    }

    private Map<Id, Group> groupByIdMap{
        get{
            if(this.groupByIdMap == null){
                if(this.tenancyGrpNameByMemberIdMap!= null && !this.tenancyGrpNameByMemberIdMap.isEmpty()){
                    this.groupByIdMap = new map<Id, Group>([SELECT Id, DeveloperName
                                                            FROM Group
                                                            WHERE DeveloperName IN: this.tenancyGrpNameByMemberIdMap.values()]);
                }
            }
            return this.groupByIdMap;
        }
        set;
    }

    private Map<String, Id> groupIdByGroupNameMap{
        get{
            if(this.groupIdByGroupNameMap == null){
                this.groupIdByGroupNameMap = new Map<String, Id>();
                if(!this.userByContactIdMap.isEmpty() && !this.groupByIdMap.isEmpty()){
                    for(Group g : this.groupByIdMap.values()){
                        this.groupIdByGroupNameMap.put(g.DeveloperName, g.Id);
                    }
                }
            }
            return this.groupIdByGroupNameMap;
        }
        set;
    }

    private Map<String, Id> groupMemberIdByGrpIdUsrIdMap{
        get{
            if(this.groupMemberIdByGrpIdUsrIdMap == null){
                this.groupMemberIdByGrpIdUsrIdMap = new Map<String, Id>();
                if(!this.groupByIdMap.isEmpty() && !this.userIdByContactIdMap.isEmpty()){
                    for(GroupMember groupMember : [SELECT Id, GroupId, UserOrGroupId
                                                FROM GroupMember
                                                WHERE GroupId IN : this.groupByIdMap.keySet() AND
                                                    UserOrGroupId IN : this.userIdByContactIdMap.values()]){
                        this.groupMemberIdByGrpIdUsrIdMap.put(groupMember.GroupId + '-' + groupMember.UserOrGroupId, groupMember.Id);
                    }
                }
            }
            return this.groupMemberIdByGrpIdUsrIdMap;
        }
        set;
    }
    
    public void manageRecordSharing(List<Id> recordIds, ManageCustomerDataSharingService.CHANGE_TYPE changeType, ManageCustomerDataSharingService.TRIGGER_CONTEXT triggerContext){
        this.recordIds = recordIds;
        if(!this.recordIds.isEmpty()){
            switch on changeType{
                when RECORD_ACTVIATED{
                    handleActivatedMembers(recordIds);
                }
                when RECORD_DEACTIVATED{
                    handleDeactivatedMembers(recordIds);
                }
                when else {
                    // TODO logger logic
                }
            }
        }
    }

    private void handleActivatedMembers(List<Id> recordIds){
        List<GroupMember> groupMembersToInsert = new List<GroupMember>();

        for(Member__c member : this.members){
            Id key = member.Id;
            if(this.tenancyGrpNameByMemberIdMap.containsKey(key)){
                String tenancyGroupName = this.tenancyGrpNameByMemberIdMap.get(key);
                if(this.contactIdByMemberIdMap.containsKey(key)){
                    Id contactId = this.contactIdByMemberIdMap.get(key);
                    if(this.userByContactIdMap.containsKey(contactId) && 
                            this.userByContactIdMap.get(contactId).IsActive &&
                            this.groupIdByGroupNameMap.containsKey(tenancyGroupName)){
                        Id userId = this.userByContactIdMap.get(contactId).Id; 
                        Id groupId = this.groupIdByGroupNameMap.get(this.tenancyGrpNameByMemberIdMap.get(key));
                        groupMembersToInsert.add(
                            buildGroupMember(
                                userId,
                                groupId
                            )
                        );
                    }
                }
            } else {
                // Group do not exist for the tenancy associated with this member
            }
        }

        if(!groupMembersToInsert.isEmpty()){
            Database.SaveResult[] srList = Database.insert(groupMembersToInsert, false);
        }
    }

    private void handleDeactivatedMembers(List<Id> recordIds){
        Set<Id> groupMemberToDeleteIds = new Set<Id>();
        for(Member__c member : this.members){
            Id key = member.Id;
            if(this.tenancyGrpNameByMemberIdMap.containsKey(key)){
                String tenancyGroupName = this.tenancyGrpNameByMemberIdMap.get(key);
                if(this.contactIdByMemberIdMap.containsKey(key)){
                    Id contactId = this.contactIdByMemberIdMap.get(key);
                    if(this.userByContactIdMap.containsKey(contactId) && this.groupIdByGroupNameMap.containsKey(tenancyGroupName)){
                        Id userId = this.userByContactIdMap.get(contactId).Id;
                        Id groupId = this.groupIdByGroupNameMap.get(this.tenancyGrpNameByMemberIdMap.get(key));
                        if(this.groupMemberIdByGrpIdUsrIdMap != null && this.groupMemberIdByGrpIdUsrIdMap.containsKey(groupId + '-' + userId)){
                            groupMemberToDeleteIds.add(this.groupMemberIdByGrpIdUsrIdMap.get(groupId + '-' + userId));
                        }
                    }
                }
            }
        }

        if(!groupMemberToDeleteIds.isEmpty()){
            Database.DeleteResult[] deleteResults = Database.delete(new List<Id>(groupMemberToDeleteIds), false);
        }
    }

    private GroupMember buildGroupMember(Id userId, Id groupId){
        GroupMember groupMember = new GroupMember();
        groupMember.GroupId = groupId;
        groupMember.UserOrGroupId = userId;
        return groupMember;
    }
}