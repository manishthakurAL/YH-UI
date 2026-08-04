@isTest
public with sharing class UthCaseMilestone {
    
    public static List<CaseMilestone> getByMilestoneName(String milestoneName){
        return Database.query('SELECT '+
			String.join(new List<String>(CaseMilestone.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM CaseMilestone ' + 
            ' WHERE MilestoneType.Name = \''+milestoneName+'\'' +
			' ORDER BY Id'
		);
    }
    
    public static List<CaseMilestone> getAllByCaseId(String caseId){
        return Database.query('SELECT '+
			String.join(new List<String>(CaseMilestone.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM CaseMilestone ' + 
            ' WHERE CaseId =: caseId'+
			' ORDER BY Id'
		);
    }

}