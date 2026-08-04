public with sharing class OrgWideEmailAddressService {

    private static final string DELIMITER = ';';
    private static final string TO_ADDRESSKEY = 'toAddress';
    private static final string CC_ADDRESSKEY = 'ccAddress';
    private List<String> allEmailList;

    private Map<String, OrgWideEmailAddress> orgWideEmailAddressByEmailMap{
        get{
            if(this.orgWideEmailAddressByEmailMap == null){
                if(!allEmailList.isEMpty()){
                    this.orgWideEmailAddressByEmailMap = new Map<String, OrgWideEmailAddress>();
                    for(OrgWideEmailAddress orgWideAddress : [SELECT Id, Address, DisplayName 
                            FROM OrgWideEmailAddress 
                            WHERE Address IN: allEmailList]){
                        this.orgWideEmailAddressByEmailMap.put(orgWideAddress.Address, orgWideAddress);
                    }
                }
            }
            return this.orgWideEmailAddressByEmailMap;
        }
        set;
    }
    
    public OrgWideEmailAddressService(){
        this.allEmailList = new List<String>();
    }

    @InvocableMethod(label='Gets OrgWideEmailAddress ' description='Gets OrgWideEmailAddress Using Email Collection.')
    public static List<Output> getOrgWideEmailAddress(List<Input> inputList) {
        OrgWideEmailAddressService orgWideService = new OrgWideEmailAddressService();
        return orgWideService.getOrgWideAddressResults(inputList);
    }

    private List<Output> getOrgWideAddressResults(List<Input> inputList){
        List<Output> results = new List<Output>();
        Map<Id, Map<String, List<String>>> emailIdToMapOfListOfAddresses = new Map<Id, Map<String, List<String>>>();
        if(inputList != null && !inputList.isEmpty()){
            for (Input input : inputList) {
                EmailMessage emailMessageRecord = input.emailMessageRecord;
                List<String> toAddressList = parseEmail(emailMessageRecord.ToAddress);
                emailIdToMapOfListOfAddresses.put(emailMessageRecord.Id, new Map<String, List<String>>{
                    TO_ADDRESSKEY => toAddressList
                });
                this.allEmailList.addAll(toAddressList);
                
                List<String> ccAddressList = parseEmail(emailMessageRecord.CcAddress);
                if(!ccAddressList.isEmpty()){
                    emailIdToMapOfListOfAddresses.get(emailMessageRecord.Id).put(
                        CC_ADDRESSKEY, ccAddressList
                    );
                    this.allEmailList.addAll(ccAddressList);
                }
            }

            for(Input input : inputList){
                Output output = new Output();
                output.orgWideEmailAddress = new OrgWideEmailAddress();
                String key = input.emailMessageRecord.Id;
                if(emailIdToMapOfListOfAddresses.containsKey(key)){
                    if(emailIdToMapOfListOfAddresses.get(key).containsKey(TO_ADDRESSKEY)){
                        Boolean owaExistInToAddress = false;
                        for(String email : emailIdToMapOfListOfAddresses.get(key).get(TO_ADDRESSKEY)){
                            if(this.orgWideEmailAddressByEmailMap.containsKey(email)){
                                output.orgWideEmailAddress = this.orgWideEmailAddressByEmailMap.get(email);
                                owaExistInToAddress = true;
                                break;
                            }
                        }
                        if(owaExistInToAddress == false){
                            if(emailIdToMapOfListOfAddresses.get(key).containsKey(CC_ADDRESSKEY)){
                                for(String email : emailIdToMapOfListOfAddresses.get(key).get(CC_ADDRESSKEY)){
                                    if(this.orgWideEmailAddressByEmailMap.containsKey(email)){
                                        output.orgWideEmailAddress = this.orgWideEmailAddressByEmailMap.get(email);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
                results.add(output);
            }
        }
        return results;
    }

    private static List<String> parseEmail(String emailAddresses){
        List<String> addressList = new List<String>();
        if(String.isNotBlank(emailAddresses)){
            emailAddresses = emailAddresses.trim();
            if(String.isNotBlank(emailAddresses)){
                addressList = emailAddresses.split(DELIMITER);
            }
        }
        return addressList;
    }

    public class Input {
        @InvocableVariable(required=true label='Email Message' description='Email Message Record')
        public EmailMessage emailMessageRecord;
    }

    public class Output {
        @InvocableVariable(required=true label='Output Collection' description='Org Wide Email Address Ids.')
        public OrgWideEmailAddress orgWideEmailAddress;
    }
}