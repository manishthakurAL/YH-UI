@isTest
public with sharing class UthEventBusSubscriber {
    public static List<EventBusSubscriber> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(EventBusSubscriber.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM EventBusSubscriber ' + 
			' ORDER BY Id'
		);
    }

    public static List<EventBusSubscriber> getAllWithTopicAndName(String topic, String subName){
        return Database.query('SELECT '+
			String.join(new List<String>(EventBusSubscriber.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM EventBusSubscriber ' + 
            ' WHERE Topic = \''+topic+'\' AND Name = \''+subName+'\'' +
			' ORDER BY Id'
		);
    }
}