@isTest
public with sharing class UthSocialValue {
    public static List<SocialValue__c> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(SocialValue__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
                        //add more feilds from related object as and wehn required
			' FROM SocialValue__c '
		);
    }

    public static SocialValue__c build (Id caseId){
        SocialValue__c asocval = new SocialValue__c(Case__c = caseId);
        return asocval;
    }
}