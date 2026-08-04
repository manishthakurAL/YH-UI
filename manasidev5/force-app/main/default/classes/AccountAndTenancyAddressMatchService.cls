public without sharing class AccountAndTenancyAddressMatchService {

    private Map<String, List<Account>> accountsBySourceKeyMap;
    private List<Account> allAccounts = new List<Account>();
    private List<YH_Property__c> allproperties = new List<YH_Property__c>();
    private Map<Integer, Account> dummyAccountByIndex = new Map<Integer, Account>();

    public AccountAndTenancyAddressMatchService(Map<String, List<Account>> accountsBySourceKeyMap){
        this.accountsBySourceKeyMap = accountsBySourceKeyMap;
    }

    private Map<String, List<Integer>> accountIndexesBySourceId{
        get{
            if(this.accountIndexesBySourceId == null){
                this.accountIndexesBySourceId = new Map<String, List<Integer>>();
                Integer index = 0;
                for (string sourcekey : this.accountsBySourceKeyMap.keySet()) {
                    List<Integer> idxList = new List<Integer>();
                    for (Account acc : this.accountsBySourceKeyMap.get(sourcekey)) {
                        idxList.add(index);
                        this.allAccounts.add(acc);
                        this.dummyAccountByIndex.put(index, acc);
                        index++;
                    }
                    accountIndexesBySourceId.put(sourcekey, idxList);
                }             
             }
            return this.accountIndexesBySourceId;
        }   
        set;
    }
    private Map<Integer, Account> matchedAccountByIndexMap{
        get{
            if(this.matchedAccountByIndexMap == null){
                this.matchedAccountByIndexMap = new Map<Integer, Account>();
                if( !this.allAccounts.isEmpty() ){
                    List<List<Sobject>> matchingAccountRecords = new FindDuplicateSObjectService().findDuplicates(this.allAccounts);
                    Integer i = 0;
                    for(List<Sobject> matchingAccountRecordsList : matchingAccountRecords){
                        if(!matchingAccountRecordsList.isEmpty() && matchingAccountRecordsList.size() == 1){ 
                            this.matchedAccountByIndexMap.put(i,(Account)matchingAccountRecordsList[0]);
                        }
                        i++;
                    }
                }
            }
            return this.matchedAccountByIndexMap;
        }   
        set;
    }
    private Map<Integer, List<Id>>  matchedPropertiesByIndex{
        get{
            if(this.matchedPropertiesByIndex == null){
                this.matchedPropertiesByIndex = new Map<Integer, List<Id>>();
                for (Integer i : this.dummyAccountByIndex.keySet()) { 
                    YH_Property__c dummyProp = buildPropertyBasedOnAccAddress(this.dummyAccountByIndex.get(i));
                    this.allproperties.add(dummyProp);
                }
                if( !this.allproperties.isEmpty() ){
                    List<List<Sobject>> matchingPropertyRecords = new FindDuplicateSObjectService().findDuplicates(this.allproperties);
                    Integer i = 0;
                    for(List<Sobject> matchingPropertyRecordsList : matchingPropertyRecords){
                        List<Id> propertyIds = new List<Id>();
                        if(!matchingPropertyRecordsList.isEmpty()){
                            for(Sobject obj : matchingPropertyRecordsList){
                                propertyIds.add((Id)obj.get('Id'));
                            }
                            this.matchedPropertiesByIndex.put(i, propertyIds);
                        }
                        i++;
                    }
                }
            }
            return this.matchedPropertiesByIndex;
            
        }   
        set;
    }
   
    public Map<String, AccountAndAddressMatchingResponse> findMatch(){
        List<Account> allAccounts = new List<Account>();
        Map<String, AccountAndAddressMatchingResponse> responseMap = new Map<String, AccountAndAddressMatchingResponse>();
        Set<String> allSourceKeys = this.accountIndexesBySourceId.keySet();
        Map<Id, Member__c> memberByAccId = new Map<Id, Member__c>();
        memberByAccId = new TenancyService().getResidentialActiveMemberByAccount(this.matchedAccountByIndexMap.values());
        if(!allSourceKeys.isEmpty() && memberByAccId != null && this.matchedPropertiesByIndex != null){
          	for(String sourceKey : allSourceKeys){
                for(Integer accIdx : this.accountIndexesBySourceId.get(sourceKey)){
                    if(this.matchedAccountByIndexMap.containsKey(accIdx)){
                        Id accId= this.matchedAccountByIndexMap.get(accIdx)?.Id; 
                        if(memberByAccId.containsKey(accId) && memberByAccId.get(accId) != null){
                            Member__c memberRes = memberByAccId.get(accId);
                            if(this.matchedPropertiesByIndex.containsKey(accIdx) && this.matchedPropertiesByIndex.get(accIdx).contains(memberRes?.Tenancy__r?.Property__c)){
                                responseMap.put(sourceKey, new AccountAndAddressMatchingResponse(memberRes.Tenancy__r, accId, memberRes.contact__c));
                                break;
                            }
                        }
                    }        
                }
        	}  
        }
        return responseMap;
    }

    private static YH_Property__c buildPropertyBasedOnAccAddress(Account acc) {
        YH_Property__c property = new YH_Property__c();
        property.AddressStreet__c = acc.PersonMailingStreet;
        property.AddressCity__c = acc.PersonMailingCity;
        property.AddressPostalCode__c = acc.PersonMailingPostalCode?.deleteWhitespace();
        return property;
    }

    public class AccountAndAddressMatchingResponse{
        public YH_Tenancy__c tenancy;
        public Id accountId;
        public Id contactId;
        public AccountAndAddressMatchingResponse(YH_Tenancy__c tenancy, Id accountId, Id contactId){
            this.tenancy = tenancy;
            this.accountId = accountId;
            this.contactId = contactId;
        }
    }
}