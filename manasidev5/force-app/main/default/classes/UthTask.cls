@isTest
public with sharing class UthTask {
    
    public static Task build(Id caseId){
        Task taskRecord = new Task();
        taskRecord.WhatId = caseId;
        return taskRecord;
    }

    public static Task createTaskWithAllFields(Id caseId, Id contactId, String subject, String status){
        Task taskRecord = build(caseId);
        taskRecord.WhoId = contactId;
        taskRecord.Subject = subject;
        taskRecord.WhatId = caseId;
        taskRecord.Status = status;
        taskRecord.ActivityDate = Date.today().addDays(3);
        return taskRecord;
    }

    public static Task createTaskWithCreatedDate(Id caseId, Id contactId, String subject, Datetime createdDate, String status){
        Task taskRecord = createTaskWithAllFields(caseId, contactId, subject, status);
        taskRecord.ActivityDate = Date.today().addDays(3);
        insert taskRecord;
        Test.setCreatedDate(taskRecord.Id, createdDate);
        return taskRecord;
    }

    public static List<Task> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(Task.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM Task ' + 
			' ORDER BY Id'
		);
    }
}