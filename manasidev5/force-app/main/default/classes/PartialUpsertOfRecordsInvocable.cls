public inherited sharing class PartialUpsertOfRecordsInvocable {

    @InvocableMethod(label='Upsert records with allOrNone=false')
    public static List<PartialUpsertResult> upsertRecords(List<PartialUpsertInput> records) {
        List<PartialUpsertResult> results = new List<PartialUpsertResult>();
        List<SObject> recordsToUpsert = new List<SObject>();
        Database.DMLOptions dmlOption = new Database.DMLOptions();
        dmlOption.assignmentRuleHeader.useDefaultRule = true;
        
        if(records != null && !records.isEmpty()){
            for(PartialUpsertInput recList : records){
                if(recList.records != null && !recList.records.isEmpty()){
                    for(SObject sobj : recList.records){
                        if(recList.dmlOptionAssignmentRule != null && recList.dmlOptionAssignmentRule) {
                            sobj.setOptions(dmlOption);
                        }
                        recordsToUpsert.add(sobj);
                    }
                }
            }
        
            if(!recordsToUpsert.isEmpty()){
                Database.UpsertResult[] upsertResults = Database.upsert(recordsToUpsert, false);
                Integer index = 0;
                for(PartialUpsertInput recList : records){
                    PartialUpsertResult result = new PartialUpsertResult();
                    if(recList.records != null && !recList.records.isEmpty()){
                        for(Integer i = 0; i < recList.records.size(); i++){
                            Database.UpsertResult upsertResult = upsertResults[index];
                            if(upsertResult.isSuccess()){
                                result.recordId.add(upsertResult.getId());
                                result.isCreated.add(upsertResult.isCreated());
                                result.isSuccess.add(upsertResult.isSuccess());
                            } else {
                                result.isSuccess.add(upsertResult.isSuccess());
                                Error error= new Error();
                                for(Database.Error err : upsertResult.getErrors()){
                                    error.errors.add(err.getMessage());               
                                }
                                result.error.add(error);
                            }
                            index++;
                        }
                    }
                    results.add(result);
                }
            }
        }
        return results;
    }

    public class PartialUpsertInput{
        @InvocableVariable(label='List of SObject Records' required=true)
        public List<SObject> records;

        @InvocableVariable(label='Apply assignment rule' required=false)
        public Boolean dmlOptionAssignmentRule;
    }

    public class PartialUpsertResult{
        @InvocableVariable(label='Record Id' required=true)
        public List<Id> recordId;
 
        @InvocableVariable(label='Is Created' required=true)
        public List<Boolean> isCreated;
 
        @InvocableVariable(label='Is Successful' required=true)
        public List<Boolean> isSuccess;
 
        @InvocableVariable(label='Errors' required=true)
        public List<Error> error;

        public PartialUpsertResult(){
            this.recordId = new List<Id>();
            this.isCreated = new List<Boolean>();
            this.isSuccess = new List<Boolean>();
            this.error = new List<Error>();
        }
    }

    public class Error{
        public List<String> errors;

        public Error(){
            this.errors = new List<String>();
        }
    }
}