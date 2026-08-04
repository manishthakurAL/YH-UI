public with sharing class UthDraftContainer {
    public static DraftContainer__C build(Id caseId, Id contactId){
        return new DraftContainer__c(
            Case__c = caseId,
            Contact__c = contactId
        );
    }

    public static DraftContainer__C buildWithTaskId(Id caseId, Id contactId, Id taskId){
        return new DraftContainer__c(
            Case__c = caseId,
            Contact__c = contactId,
            TaskId__c = taskId
        );
    }

    public static DraftContainer__c[] getAll() {
        return Database.query('SELECT '+
			String.join(new List<String>(DraftContainer__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM DraftContainer__c ' + 
			' ORDER BY Id'
		);
    }
}