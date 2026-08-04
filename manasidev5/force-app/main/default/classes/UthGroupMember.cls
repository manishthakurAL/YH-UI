@isTest
public class UthGroupMember {
    public static GroupMember build(Id groupId, Id userId){
        GroupMember groupMember = new GroupMember(
            GroupId = groupId, 
            UserOrGroupId = userId
        );
        return groupMember;
    }

    public static List<GroupMember> getGroupMemberUsingId(Id groupId){
        return Database.query('SELECT '+
			String.join(new List<String>(GroupMember.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM GroupMember WHERE GroupId =: groupId'
		);
    }

    public static List<GroupMember> getGroupMemberUsingGroupName(String groupName){
        return Database.query('SELECT '+
			String.join(new List<String>(GroupMember.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM GroupMember WHERE Group.developername =: groupName'
		);
    }

    public static List<GroupMember> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(GroupMember.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM GroupMember '
		);
    }
}