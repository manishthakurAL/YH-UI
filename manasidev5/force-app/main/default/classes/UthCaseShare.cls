@isTest
public class UthCaseShare {
    public static CaseShare build(Id recordId, Id userId){
        CaseShare share = new CaseShare(
            CaseId = recordId,
            UserOrGroupId = userId,
            CaseAccessLevel = 'Read',
            RowCause = Schema.CaseShare.RowCause.Manual
        );
        return share;
    }
    
    public static List<CaseShare> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(CaseShare.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM CaseShare '
		);
    }

    public static List<CaseShare> getAllUsingCaseId(List<Id> caseIds){

        return Database.query('SELECT '+
			String.join(new List<String>(CaseShare.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM CaseShare WHERE CaseId IN: caseIds AND RowCause = \'Manual\''
		);
    }
}