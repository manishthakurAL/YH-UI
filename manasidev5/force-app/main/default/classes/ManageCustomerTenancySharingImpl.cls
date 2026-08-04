public with sharing class ManageCustomerTenancySharingImpl implements IManageCustomerDataSharing{

    private List<Id> recordIds;

    private List<YH_Tenancy__c> tenancies{
        get{
            if(this.tenancies == null){
                this.tenancies = new List<YH_Tenancy__c>();
                if(this.recordIds != null && !this.recordIds.isEmpty()){
                    for(YH_Tenancy__c tenancy : [SELECT Id, Name 
                                                    FROM YH_Tenancy__c 
                                                    WHERE Id IN : this.recordIds]) {
                        this.tenancies.add(tenancy);                            
                    }
                }
            }
            return this.tenancies;
        }
        set;
    }

    private Map<String, Id> tenancyIdByTenancyGroupNameMap{
        get{
            if(this.tenancyIdByTenancyGroupNameMap == null){
                this.tenancyIdByTenancyGroupNameMap = new Map<String, Id>();
                if(this.tenancies != null && !this.tenancies.isEmpty()){
                    for(YH_Tenancy__c t : this.tenancies){
                        String groupName = new TenancyService().getGroupName(t.name);
                        this.tenancyIdByTenancyGroupNameMap.put(groupName, t.Id);
                    }
                }
            }
            return this.tenancyIdByTenancyGroupNameMap;
        }
        set;
    }

    private Map<Id, Group> existingGroupsByIdMap{
        get{
            if(this.existingGroupsByIdMap == null){
                this.existingGroupsByIdMap = new Map<Id, Group>();
                if(this.tenancyIdByTenancyGroupNameMap != null && !this.tenancyIdByTenancyGroupNameMap.isEmpty()){
                    for(Group g : getGroups(this.tenancyIdByTenancyGroupNameMap.keySet())){
                        this.existingGroupsByIdMap.put(g.Id, g);                
                    }
                }
            }
            return this.existingGroupsByIdMap;
        }
        set;
    }

    private List<GroupMember> groupMembersOfDeactivatedTenancies{
        get{
            if(this.groupMembersOfDeactivatedTenancies == null){
                this.groupMembersOfDeactivatedTenancies = new List<GroupMember>();
                if(this.existingGroupsByIdMap != null && !this.existingGroupsByIdMap.isEmpty()){
                    for(GroupMember groupMember : [SELECT Id 
                                                FROM GroupMember
                                                WHERE GroupId IN: existingGroupsByIdMap.keySet()]){
                        this.groupMembersOfDeactivatedTenancies.add(groupMember);
                    }
                }
            }            
            return this.groupMembersOfDeactivatedTenancies;
        }
        set;
    }

    private List<YH_Tenancy__Share> tenancyShareOfDeactivatedTenancies{
        get{
            if(this.tenancyShareOfDeactivatedTenancies == null){
                this.tenancyShareOfDeactivatedTenancies = new List<YH_Tenancy__Share>();
                if(this.existingGroupsByIdMap != null && !this.existingGroupsByIdMap.isEmpty()){
                    for(YH_Tenancy__Share groupMember : [SELECT Id 
                                                FROM YH_Tenancy__Share
                                                WHERE UserOrGroupId IN: existingGroupsByIdMap.keySet()]){
                        this.tenancyShareOfDeactivatedTenancies.add(groupMember);
                    }
                }
            }
            return this.tenancyShareOfDeactivatedTenancies;
        }
        set;
    }

    private Map<Id, Id> tenancyIdByExistingGroupIdMap = this.tenancyIdByExistingGroupIdMap = new Map<Id, Id>();

    private List<Id> groupIdsWithoutTenancyShare{
        get{
            if(this.groupIdsWithoutTenancyShare == null){
                this.groupIdsWithoutTenancyShare = new List<Id>();
                if(!this.tenancyIdByExistingGroupIdMap.isEmpty()){
                    Set<Id> groupsWithShares = new Set<Id>();
                    for(YH_Tenancy__Share tenancyShare :  [SELECT UserOrGroupId
                                                            FROM YH_Tenancy__Share
                                                            WHERE UserOrGroupId IN : this.tenancyIdByExistingGroupIdMap.keySet() AND
                                                                RowCause =: Schema.YH_Tenancy__Share.RowCause.Tenancy__c]){
                        groupsWithShares.add(tenancyShare.UserOrGroupId);
                    }

                    for(Id gid : this.tenancyIdByExistingGroupIdMap.keySet()){
                        if (!groupsWithShares.contains(gid)) {
                            this.groupIdsWithoutTenancyShare.add(gid);
                        }
                    }
                }
            }
            return this.groupIdsWithoutTenancyShare;
        }
        set;
    }

    private List<Id> groupIdsForDelete{
        get{
            if(this.groupIdsForDelete == null){
                this.groupIdsForDelete = new List<Id>();
                if(!this.tenancyIdByTenancyGroupNameMap.isEmpty()){
                    for(Group g : getGroups(this.tenancyIdByTenancyGroupNameMap.keySet())){
                        this.groupIdsForDelete.add(g.Id);
                    }
                }
            }
            return this.groupIdsForDelete;
        } 
        set;
    }

    public void manageRecordSharing(List<Id> recordIds, ManageCustomerDataSharingService.CHANGE_TYPE changeType, 
                                    ManageCustomerDataSharingService.TRIGGER_CONTEXT triggerContext){
        this.recordIds = recordIds;
        if(!this.recordIds.isEmpty()){
            switch on changeType{
                when RECORD_ACTVIATED{
                    handleActivatedTenancy(recordIds);
                }
                when RECORD_DEACTIVATED{
                    handleDeactivatedTenancy(recordIds);
                }
                when else {
                    // TODO logger logic
                }
            }
        }
    }

    private void handleActivatedTenancy(List<Id> recordIds){
        List<Group> groupsToInsert = new List<Group>();
        List<YH_Tenancy__Share> tenancyShareToInsert = new List<YH_Tenancy__Share>();
        
        if(!this.existingGroupsByIdMap.isEmpty()){
            if(!this.tenancyIdByTenancyGroupNameMap.isEmpty()){
                for(Id key : this.existingGroupsByIdMap.keySet()){
                    Group g = this.existingGroupsByIdMap.get(key);
                    if(this.tenancyIdByTenancyGroupNameMap.containsKey(g.developerName)){
                        this.tenancyIdByExistingGroupIdMap.put(key, this.tenancyIdByTenancyGroupNameMap.get(g.developerName));
                        this.tenancyIdByTenancyGroupNameMap.remove(g.developerName);
                    }
                }
            }
        }

        if(!this.tenancyIdByTenancyGroupNameMap.isEmpty()){
            groupsToInsert.addAll(buildGroups(this.tenancyIdByTenancyGroupNameMap.keySet()));

            if (!groupsToInsert.isEmpty()) {
                Database.SaveResult[] srList = Database.insert(groupsToInsert, false);
            }
        }

        for(Id gId : this.groupIdsWithoutTenancyShare){
            if(this.tenancyIdByExistingGroupIdMap.containsKey(gid)){
                tenancyShareToInsert.add(
                    buildTenancyShare(
                        this.tenancyIdByExistingGroupIdMap.get(gId),
                        gId
                    )
                );
            }
        }

        for(Group g : getGroups(this.tenancyIdByTenancyGroupNameMap.keySet()) ){
            if(this.tenancyIdByTenancyGroupNameMap.containsKey(g.developerName)){
                tenancyShareToInsert.add(
                    buildTenancyShare(
                        this.tenancyIdByTenancyGroupNameMap.get(g.developerName),
                        g.Id
                    )
                );
            }
        }

        if(!tenancyShareToInsert.isEmpty()){
            Database.SaveResult[] srList = Database.insert(tenancyShareToInsert, false);
        }
    }

    private void handleDeactivatedTenancy(List<Id> recordIds){
        if(this.tenancyIdByTenancyGroupNameMap != null && !this.tenancyIdByTenancyGroupNameMap.isEmpty()){
            if(this.groupMembersOfDeactivatedTenancies != null && !this.groupMembersOfDeactivatedTenancies.isEmpty()){
                Database.DeleteResult[] srList = Database.delete(this.groupMembersOfDeactivatedTenancies, false);
                //TODO logic to handle failed delete records (Logger logic)
            }

            if(this.tenancyShareOfDeactivatedTenancies != null && !this.tenancyShareOfDeactivatedTenancies.isEmpty()){
                Database.DeleteResult[] srList = Database.delete(this.tenancyShareOfDeactivatedTenancies, false);
                //TODO logic to handle failed delete records (Logger logic)
            }

            if(!this.groupIdsForDelete.isEmpty()){
                ID jobID = System.enqueueJob(new ManageCustTenSharingDeactivationQueueable(this.groupIdsForDelete));
            }
        }
    }

    private List<Group> buildGroups(Set<String> groupNames){
        List<Group> groupsToInsert = new List<Group>();
        for(String groupName : groupNames){
            groupsToInsert.add(new Group(
                    Name = groupName,
                    DeveloperName = groupName,
                    Type = GroupDecorator.GROUP_TYPE_REGULAR
                ));
        }
        return groupsToInsert;
    }

    private List<Group> getGroups(Set<String> tenancyGroupNameList){
        return [SELECT Id, DeveloperName
                FROM Group
                WHERE DeveloperName IN : tenancyGroupNameList];
    }

    private YH_Tenancy__Share buildTenancyShare(Id recordId, Id groupId){
        YH_Tenancy__Share share = new YH_Tenancy__Share();
        share.ParentId = recordId;
        share.UserOrGroupId = groupId;
        share.AccessLevel = TenancyShareDecorator.ACCESSLEVEL_READ;
        share.RowCause = Schema.YH_Tenancy__Share.RowCause.Tenancy__c;
        return share;
    }
    public class ManageCustTenSharingDeactivationQueueable implements Queueable {
        private List<Id> groupRecordIds;

        public ManageCustTenSharingDeactivationQueueable(List<Id> groupRecordIds){
            this.groupRecordIds = groupRecordIds;
        }
        
        public void execute(QueueableContext context) {
            if(!this.groupRecordIds.isEmpty()){
                Database.DeleteResult[] srList = Database.delete(this.groupRecordIds, false);
            }
        }
    }
}