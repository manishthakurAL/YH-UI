@isTest
public class UthGroup {
    public static Group build(String groupName){
        Group groupA = new Group(
            Name = groupName,
            DeveloperName = groupName,
            Type = 'Regular'
        );
        return groupA;
    }

    public static Group createGroup (String groupName){
        Group groupA = new Group(Name = groupName, Type = 'Regular');
        insert groupA;
        return groupA;
    }
    
    public static void createGroupMember (Id groupId, Id userId){
        insert new GroupMember(GroupId = groupId, UserOrGroupId = userId);
    }

    public static List<Group> getGroupUsingName(String groupName){
        return Database.query('SELECT '+
			String.join(new List<String>(Group.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM Group WHERE DeveloperName =: groupName '
		);
    }

    public static List<Group> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(Group.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM Group '
		);
    }
}