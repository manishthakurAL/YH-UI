@isTest
public with sharing class UthEnforcementAction {
    public static List<EnforcementAction__c> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(EnforcementAction__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
                        //add more feilds from related object as and wehn required
			' FROM EnforcementAction__c '
		);
    }

    public static EnforcementAction__c build (Id caseId){
        EnforcementAction__c enfAction = new EnforcementAction__c(Case__c = caseId);
        return enfAction;
    }
}