public with sharing class GroupUserFetcherInvocable {
    
    public class Request {
        @InvocableVariable(required=true)
        public Id groupId;
    }
    
    public class Response {
        @InvocableVariable
        public List<Id> userIds;
        
        @InvocableVariable
        public List<String> userEmails;
    }
    
    @InvocableMethod(
        label='Get All User IDs and Emails from a Group (Including Nested Groups and Roles)'
        description='Returns all user IDs and email addresses in a group, nested groups, or roles within it.'
    )
    public static List<Response> getGroupUserIdsFromFlow(List<Request> requests) {
        
        Set<Id> rootGroupIds = new Set<Id>();
        Map<Id, List<GroupMember>> groupMembersByGroup = new Map<Id, List<GroupMember>>();
        Map<Id, Group> groupsById = new Map<Id, Group>();
        Set<Id> potentialGroupIds = new Set<Id>();
        List<Group> groups = new List<Group>();
        Set<Id> collectedUserIds = new Set<Id>();
        Map<Id, User> userMap = new Map<Id, User>();
        List<Response> results = new List<Response>();
        
        for (Request req : requests) {
            if (req.groupId != null) {
                rootGroupIds.add(req.groupId);
            }
        }

        List<GroupMember> initialMembers = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId IN :rootGroupIds];

        for (GroupMember gm : initialMembers) {
            if (!groupMembersByGroup.containsKey(gm.GroupId)) {
                groupMembersByGroup.put(gm.GroupId, new List<GroupMember>());
            }
            groupMembersByGroup.get(gm.GroupId).add(gm);
        }

        for (GroupMember gm : initialMembers) {
            potentialGroupIds.add(gm.UserOrGroupId);
        }

        if (!potentialGroupIds.isEmpty()) {
            groups = [SELECT Id, Type, RelatedId FROM Group WHERE Id IN :potentialGroupIds];
            for (Group g : groups) {
                groupsById.put(g.Id, g);
            }
        }

        for (Request req : requests) {
            collectGroupUserIds(
                req.groupId,
                collectedUserIds,
                new Set<Id>(),
                groupMembersByGroup,
                groupsById
            );

            if (!collectedUserIds.isEmpty()) {
                userMap = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN :collectedUserIds AND IsActive = True]);
            }

            Response res = new Response();
            res.userIds = new List<Id>(collectedUserIds);
            res.userEmails = new List<String>();

            for (User u : userMap.values()) {
                if (String.isNotBlank(u.Email)) {
                    res.userEmails.add(u.Email);
                }
            }

            results.add(res);
        }

        return results;
    }

    private static void collectGroupUserIds(
        Id groupId,
        Set<Id> userIds,
        Set<Id> visitedGroups,
        Map<Id, List<GroupMember>> groupMembersByGroup,
        Map<Id, Group> groupsById
    ) {
        if (!(groupId == null || visitedGroups.contains(groupId))) {
            
            visitedGroups.add(groupId);

            if (!groupMembersByGroup.containsKey(groupId)) {
                List<GroupMember> gmList = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId = :groupId];
                groupMembersByGroup.put(groupId, gmList);
                
                Set<Id> nestedIds = new Set<Id>();
                for (GroupMember gm : gmList) {
                    nestedIds.add(gm.UserOrGroupId);
                }
                
                if (!nestedIds.isEmpty()) {
                    List<Group> groups = [SELECT Id, Type, RelatedId FROM Group WHERE Id IN :nestedIds];
                    for (Group g : groups) {
                        groupsById.put(g.Id, g);
                    }
                }
            }
    
            Set<Id> roleRelatedIds = new Set<Id>();

            for (GroupMember member : groupMembersByGroup.get(groupId)) {
                Id memberId = member.UserOrGroupId;
            
                if (groupsById.containsKey(memberId)) {
                    Group g = groupsById.get(memberId);
            
                    if (g.Type == FlowDecorator.ROLE_STRING || g.Type == FlowDecorator.ROLE_AND_SUBORDINATES) {
                        roleRelatedIds.add(g.RelatedId);
                    } else {
                        collectGroupUserIds(
                            g.Id,
                            userIds,
                            visitedGroups,
                            groupMembersByGroup,
                            groupsById
                        );
                    }
                } else {
                    userIds.add(memberId);
                }
            }
            
            if (!roleRelatedIds.isEmpty()) {
                List<User> Users = [SELECT Id, UserRoleId FROM User WHERE UserRoleId IN :roleRelatedIds AND IsActive = True];
                for (User u : Users) {
                    userIds.add(u.Id);
                }
            }
        }
     }
}