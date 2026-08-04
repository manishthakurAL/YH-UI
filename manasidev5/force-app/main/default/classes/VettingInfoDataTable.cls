public with sharing class VettingInfoDataTable {
    @AuraEnabled(Cacheable=true)
        public static List <VettingSupportInfoWrapper> getVettingSupportInfo(Id recordId) {
            Id vettingId;
            List<VettingSupportInfoWrapper> wrappers = new List<VettingSupportInfoWrapper>();
            List<VettingSupportingInfo__c> vettingSupportInfoRecords = [ SELECT Id, Name, LandlordName__c,
                                            TypeOfLandlord__c,
                                            LandlordPhone__c, LandlordEmail__c, Vetting__c
                                       FROM VettingSupportingInfo__c where Vetting__r.Applicant__c =:recordId
                                        ORDER BY Name];
            
            for(VettingSupportingInfo__c supportInfo: vettingSupportInfoRecords){
                VettingSupportInfoWrapper wrapper = new VettingSupportInfoWrapper();
                wrapper.Id = supportInfo.Id;
                wrapper.Name = supportInfo.Name;
                wrapper.link ='/' +  supportInfo.Id; 
                wrapper.typeOfLandlord = supportInfo.TypeOfLandlord__c;
                wrapper.landlordPhone = supportInfo.LandlordPhone__c;
                wrapper.landlordEmail = supportInfo.LandlordEmail__c;
                wrapper.landlordName = supportInfo.LandlordName__c;
                wrappers.add(wrapper);
            }
            return wrappers;
    }  
    
    @AuraEnabled(Cacheable=true)
    public static String getVettingId(Id applicantId){
        List<Vetting__c> vettings = [SELECT Id FROM Vetting__c WHERE Applicant__c =:applicantId];
        if( !vettings.isEmpty() ){
            return vettings[0].Id;
        }
        return null;
    }

    public class VettingSupportInfoWrapper{
        @AuraEnabled
        public string Id;
        @AuraEnabled
        public string Name;
        @AuraEnabled
        public string link;
        @AuraEnabled
        public string typeOfLandlord;
        @AuraEnabled
        public string landlordPhone;
        @AuraEnabled
        public string landlordEmail;
        @AuraEnabled
        public string landlordName;
    }
}