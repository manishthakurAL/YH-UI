@isTest
public class UthCongaMergeQuery {
    public static APXTConga4__Conga_Merge_Query__c build(String name, String key, String query){
        APXTConga4__Conga_Merge_Query__c cmq = new APXTConga4__Conga_Merge_Query__c(
            APXTConga4__Name__c = name,
            APXTConga4__Key__c = key,
            APXTConga4__Query__c = query
        );
        return cmq;
    }
}