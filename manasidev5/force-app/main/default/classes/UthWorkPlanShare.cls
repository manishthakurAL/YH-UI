@isTest
public with sharing class UthWorkPlanShare {

    public static list<WorkPlanShare> getAll(list<Id> parentId, list<Id> userId){
        return Database.query('SELECT '+
                String.join(new List<String>(WorkPlanShare.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM WorkPlanShare WHERE ParentId =: parentId AND UserOrGroupId =: userId');
    }
}