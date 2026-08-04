public without sharing class FindDuplicateExistsInvocable {

    public class FindDuplicateExistsInvocableException extends Exception {}
    @InvocableMethod(label='Find Duplicates')
    public static List<Response> findDuplicates(List<Request> requests){
        List<Response> responses = new List<Response>();
        List<Account> accList = new List<Account>();
        if( requests.isEmpty()  ){
            throw new FindDuplicateExistsInvocableException('No records to process');
        }else{
      
            for(Request aRequest : requests){
                accList.add(aRequest.accountRecord);
            }
            
            
            if( !accList.isEmpty() ){
                List<List<Sobject>> matchingAccountRecords = new FindDuplicateSObjectService().findDuplicates(accList);
                Integer i = 0;
                for(List<Sobject> matchingAccountRecordsList : matchingAccountRecords){
                    responses.add(new Response(accList[i], !matchingAccountRecordsList.isEmpty(),matchingAccountRecordsList));
                    i++;
                }
            }
        }
        return responses;
    }

    public class Request{
       @InvocableVariable(required=true)
       public Account accountRecord; 
    }

    public class Response{
        @InvocableVariable
        public Account inputAccountRecord;
        @InvocableVariable
        public Boolean isDuplicateFound;
        @InvocableVariable
        public List<Account> matchingRecords;
        @InvocableVariable
        public Integer matchingRecordcount;
        public Response(Account inputAccountRecord, Boolean isDuplicateFound, List<Account> matchingRecords){
            this.inputAccountRecord = inputAccountRecord;
            this.isDuplicateFound = isDuplicateFound;
            this.matchingRecords = matchingRecords;
            this.matchingRecordcount = matchingRecords?.size();
        }
    }
}