public with sharing class UthFeedItem {
    public static list<FeedItem> getAll(Id ParentId){
        return Database.query('SELECT '+
			String.join(new List<String>(FeedItem.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
                        //add more feilds from related object as and wehn required
			' FROM FeedItem ' + 
            ' WHERE ParentId = \'' + ParentId + '\'' +
			' ORDER BY Id'
		);
    }
}