public with sharing class WorkStepValidationInvocable {
    @InvocableMethod(label='Validate Work Step' description='Validate Work Step')
    public static List<ValidationResponse> validateWorkStep(List<ValidateRequest> requests){
        List<ValidationResponse> responseList = new List<ValidationResponse>();
        if( !requests.isEmpty() ){
            ValidateRequest request = requests[0];
            WorkStepValidationService service = new WorkStepValidationService(request.operativeId);
            String message = service.checkIfDailyActionsAreCompleted();
            responseList.add(
                new ValidationResponse(message, String.isBlank(message))
            );
        }
        return responseList;
    }


    public class ValidateRequest{
        @InvocableVariable
        public Id operativeId;
    }


    public class ValidationResponse{
        @InvocableVariable(label='responseMessage' required=false)
        public String message;
        @InvocableVariable(label='canProceed' required=true)
        public Boolean canProceed;
      

        public ValidationResponse(String message, Boolean canProceed){
            this.message = message;
            this.canProceed = canProceed;
        }
    }

}