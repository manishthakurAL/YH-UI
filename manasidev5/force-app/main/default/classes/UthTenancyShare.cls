@isTest
public class UthTenancyShare {

    public static YH_Tenancy__Share build(Id recordId, Id groupId){
        YH_Tenancy__Share share = new YH_Tenancy__Share(
            ParentId = recordId,
            UserOrGroupId = groupId,
            AccessLevel = TenancyShareDecorator.ACCESSLEVEL_READ,
            RowCause = Schema.YH_Tenancy__Share.RowCause.Tenancy__c
        );
        return share;
    }
    public static List<YH_Tenancy__Share> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(YH_Tenancy__Share.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM YH_Tenancy__Share '
		);
    }
}