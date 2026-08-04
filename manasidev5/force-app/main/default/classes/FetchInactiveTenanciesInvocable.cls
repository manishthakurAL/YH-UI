public with sharing class FetchInactiveTenanciesInvocable {
    @InvocableMethod(label='Fetch Inactive Tenancies')
    public static List<FetchInactiveTenanciesInvocable.Result> fetchInactiveTenancies(List<FetchInactiveTenanciesInvocable.Request> requests) {
        List<FetchInactiveTenanciesInvocable.Result> inactiveTenanciesIdList = new List<FetchInactiveTenanciesInvocable.Result>();
        List<Id> contactIds = new List<Id>();
        
        for (Request aRequest : requests) {
            contactIds.add(aRequest.contactId);
        }
        if(contactIds.size() > 1){
            throw new AuraHandledException('Only one contact is accepted as input based on current implementation');
        }
       
        if( !contactIds.isEmpty()){
            List<Member__c> members = [
                SELECT Id, Tenancy__r.Name, OccupancyEndDate__c, Tenancy__c,
                        Tenancy__r.TenancyEndDate__c,
                        AssetClass__c
                        FROM Member__c WHERE Contact__c in :contactIds 
                        AND ( Type__c =: MemberDecorator.TYPE_JOINT  OR Type__c=: MemberDecorator.TYPE_SOLO)
                        AND IsActive__c = false
                        ORDER BY CalculatedOccupancyEndDate__c DESC
            ];

            Id garageTenancyId;
            Id nonGarageTenancyId;
            if( !members.isEmpty() ){
                for(Member__c memberRecord: members){
                    if( !String.isBlank(memberRecord.AssetClass__c) && !memberRecord.AssetClass__c.containsIgnoreCase(PropertyDecorator.GARAGE_ASSET_CLASS)){
                        nonGarageTenancyId =memberRecord.Tenancy__c;
                        break;
                    }
                    garageTenancyId = memberRecord.Tenancy__c;
                    
                }
            }
            FetchInactiveTenanciesInvocable.Result aResult = new FetchInactiveTenanciesInvocable.Result();
            if(!String.isBlank(nonGarageTenancyId)){
                aResult.tenancyId = nonGarageTenancyId;
            }else if(!String.isBlank(garageTenancyId)){
                aResult.tenancyId = garageTenancyId;
            }
            inactiveTenanciesIdList.add(aResult);
        }
        return inactiveTenanciesIdList;
    }

    public class Request{
        @InvocableVariable(label='Contact ID' required=true)
        public Id contactId;
    }

    public class Result{
        @InvocableVariable(label='Inactive Tenancy Id' required=true)
        public Id tenancyId;
    }
}